//
// DialKefVolumeControl
// MacDial
//
// Created by Alex Babaev on 28 June 2023.
// Copyright © 2023 Alex Babaev. All rights reserved.
//

import Foundation

class DialKefVolumeControl: DeviceControl {
    #if DEBUG
    private let isDebug: Bool = true
    #else
    private let isDebug: Bool = false
    #endif

    private let host: String
    private let scale: Double

    init(host: String, scale: Double = 1) {
        self.host = host
        self.scale = scale
    }

    func buttonPress() {
    }

    func buttonRelease() {
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
    private lazy var urlGetData = URL(string: "http://\(host)/api/getData?roles=value&path=player:volume")!
    private lazy var urlSetData = URL(string: "http://\(host)/api/setData")!

    private func currentVolume() async throws -> Int {
        let (data, _) = try await session.data(from: urlGetData)
        if isDebug {
            log(tag: "KEF", "\(String(data: data, encoding: .utf8) ?? "nil")")
        }
        let volumeData = try JSONDecoder().decode([I32Value].self, from: data)
        return Int(volumeData.first?.i32_ ?? 0)
    }

    private func set(volume: Int) async throws {
        var request = URLRequest(url: urlSetData)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(SetVolumeData(value: Int32(volume)))
        _ = try await session.data(for: request)
    }

    // MARK: - Data Models

    private struct I32Value: Codable {
        var type: String = "i32_"
        var i32_: Int32
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
