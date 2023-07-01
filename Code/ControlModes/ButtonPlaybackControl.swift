//
// PlaybackControlMode
// MacDial
//
// Created by Alex Babaev on 28 January 2022.
//
// Based on Andreas Karlsson sources
// https://github.com/andreasjhkarlsson/mac-dial
//
// License: MIT
//

import AppKit

class ButtonPlaybackControl: DeviceControl {
    #if DEBUG
    private let isDebug: Bool = true
    #else
    private let isDebug: Bool = false
    #endif

    private let name: String
    private var playPauseHandler: () -> Void = {}
    private var forwardHandler: () -> Void = {}
    private var rewindHandler: () -> Void = {}

    init(name: String, playPauseHandler: (() -> Void)? = nil, forwardHandler: (() -> Void)? = nil, rewindHandler: (() -> Void)? = nil) {
        self.name = name
        self.playPauseHandler = playPauseHandler ?? { [unowned self] in
            send(key: NX_KEYTYPE_PLAY)
            log(tag: "Media:\(name)", "sent «Play/Pause»")
        }
        self.forwardHandler = forwardHandler ?? { [unowned self] in
            send(key: NX_KEYTYPE_NEXT)
            log(tag: "Media:\(name)", "sent «Play Next»")
        }
        self.rewindHandler = rewindHandler ?? { [unowned self] in
            send(key: NX_KEYTYPE_PREVIOUS)
            log(tag: "Media:\(name)", "sent «Play Previous»")
        }
    }

    func buttonPress() {
        log(tag: "Media:\(name)", "button press (ignored)")
    }

    private var numberOfClicks: Int = 0
    private var accumulator: Double = 0
    private var lastSentValue: Double = 0
    private var lastClickTime: TimeInterval = Date.timeIntervalSinceReferenceDate

    func buttonRelease() {
        let currentNumberOfClicks = numberOfClicks + 1
        numberOfClicks = currentNumberOfClicks
        lastClickTime = Date.timeIntervalSinceReferenceDate
        log(tag: "Media:\(name)", "button release. Counting clicks: \(numberOfClicks)")

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [self] in
            guard currentNumberOfClicks == numberOfClicks else { return }

            switch numberOfClicks {
                case 1: playPauseHandler()
                case 2: forwardHandler()
                case 3 ... 1000: rewindHandler()
                default: break
            }

            numberOfClicks = 0
        }
    }

    private func send(key: Int32, repeatCount: Int = 1) {
        guard !isDebug else { return }

        HIDPostAuxKey(key: key, modifiers: [], repeatCount: repeatCount)
    }

    func rotationChanged(_ rotation: RotationState) -> Bool {
        false
    }
}
