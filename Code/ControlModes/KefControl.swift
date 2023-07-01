//
// DialKefControl
// MacDial
//
// Created by Alex Babaev on 28 June 2023.
// Copyright © 2023 Alex Babaev. All rights reserved.
//

import Foundation

class KefControl: DeviceControl {
    enum Problem: Error {
        case url(URL)
    }

    #if DEBUG
    private let isDebug: Bool = true
    #else
    private let isDebug: Bool = false
    #endif

    enum PlaybackCommand {
        case playPause
        case forward
        case rewind
    }

    private enum PlaybackSource {
        case wifi
        case bluetooth
        case tv
        case optical
        case usb
        case aux

        var isStream: Bool {
            switch self {
                case .wifi, .bluetooth: return true
                case .tv, .optical, .usb, .aux: return false
            }
        }
    }

    private var systemPlaybackControl: ButtonPlaybackControl!
    private var kefStreamingPlaybackControl: ButtonPlaybackControl!

    private let host: String
    private let scale: Double

    init(host: String, scale: Double = 1) {
        self.host = host
        self.scale = scale
        systemPlaybackControl = .init(name: "Music")
        kefStreamingPlaybackControl = .init(
            name: "KEF",
            playPauseHandler: { [unowned self] in Task { try await send(playbackCommand: .playPause) } },
            forwardHandler:  { [unowned self] in Task { try await send(playbackCommand: .forward) } },
            rewindHandler:  { [unowned self] in Task { try await send(playbackCommand: .rewind) } }
        )
    }

    func buttonPress() {
        // this does nothing here
    }

    func buttonRelease() {
        Task {
            let control: DeviceControl = try await currentSource().isStream
                ? kefStreamingPlaybackControl
                : systemPlaybackControl
            control.buttonRelease()
        }
    }

    private var lastVolumeSent: Double = -1

    func rotationChanged(_ rotation: RotationState) -> Bool {
        Task {
            if lastVolumeSent < 0 {
                do {
                    lastVolumeSent = Double(try await currentVolume())
                } catch {
                    print("\(error)")
                }
            }

            do {
                lastVolumeSent = lastVolumeSent + rotation.amount * scale
                try await set(volume: Int(round(lastVolumeSent)))
            } catch {
                print("\(error)")
            }
        }

        return true
    }

    private let session = URLSession.shared
    private lazy var urlGetVolume = URL(string: "http://\(host)/api/getData?roles=value&path=player:volume")!
    private lazy var urlGetSource = URL(string: "http://\(host)/api/getData?roles=value&path=settings:/kef/play/physicalSource")!
    private lazy var urlSetData = URL(string: "http://\(host)/api/setData")!

    // MARK: - Getting Information

    private func currentVolume() async throws -> Int {
        let (data, _) = try await session.data(from: urlGetVolume)
        if isDebug {
            log(tag: "KEF", "\(String(data: data, encoding: .utf8) ?? "nil")")
        }
        let volumeData = try JSONDecoder().decode([I32Value].self, from: data)
        return Int(volumeData.first?.i32_ ?? 0)
    }

    private var lastSource: PlaybackSource?
    private var lastSourceGotAt: Date = Date()

    private func currentSource() async throws -> PlaybackSource {
        let currentTime = Date()
        guard lastSource == nil || currentTime.timeIntervalSince(lastSourceGotAt) > 15 else { return lastSource ?? .aux }

        let (data, _) = try await session.data(from: urlGetSource)
        if isDebug {
            log(tag: "KEF", "\(String(data: data, encoding: .utf8) ?? "nil")")
        }
        let sourceData = try JSONDecoder().decode([KefPhysicalSourceValue].self, from: data)
        switch sourceData.first?.kefPhysicalSource {
            case "usb": lastSource = .usb
            case "wifi": lastSource = .wifi
            case "bluetooth": lastSource = .bluetooth
            case "tv": lastSource = .tv
            case "optical": lastSource = .optical
            case "aux": lastSource = .aux
            default: lastSource = .aux
        }
        lastSourceGotAt = currentTime
        return lastSource ?? .aux
    }

    // MARK: - Updating Information

    private func set(volume: Int) async throws {
        var request = URLRequest(url: urlSetData)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(SetVolumeData(value: Int32(volume)))
        _ = try await session.data(for: request)
    }

    private func send(playbackCommand: PlaybackCommand) async throws {
        guard var urlComponents = URLComponents(url: urlSetData, resolvingAgainstBaseURL: false) else { throw Problem.url(urlSetData) }

        let commandString: String
        switch playbackCommand {
            case .playPause: commandString = "pause"
            case .forward: commandString = "next"
            case .rewind: commandString = "previous"
        }
        urlComponents.queryItems = [
            URLQueryItem(name: "path", value: "player:player/control"),
            URLQueryItem(name: "roles", value: "activate"),
            URLQueryItem(name: "value", value: "{\"control\":\"\(commandString)\"}"),
        ]
        guard let url = urlComponents.url else { throw Problem.url(urlSetData) }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        _ = try await session.data(for: request)
    }

    // MARK: - Data Models

    private struct I32Value: Codable {
        var type: String = "i32_"
        var i32_: Int32
    }

    private struct KefPhysicalSourceValue: Codable {
        var type: String = "kefPhysicalSource"
        var kefPhysicalSource: String
    }

    private struct SetVolumeData: Encodable {
        var path: String = "player:volume"
        var roles: String = "value"
        var value: I32Value

        init(value: Int32) {
            self.value = I32Value(i32_: value)
        }
    }
}
