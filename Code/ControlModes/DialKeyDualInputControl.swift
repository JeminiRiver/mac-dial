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
import Carbon

class DialKeysDualInputControl: DeviceControl {
	private let modifiers: [CGEventFlags]
	private let forPressed: Bool

    private let buttonClockwiseKeyCode: CGKeyCode!
    private let buttonCounterKeyCode: CGKeyCode!

    init(
		forPressed: Bool,
		buttonClockwiseKeyCode: CGKeyCode!,
		buttonCounterKeyCode: CGKeyCode!,
        modifiers: [CGEventFlags]
    ) {
        self.buttonClockwiseKeyCode = buttonClockwiseKeyCode
        self.buttonCounterKeyCode = buttonCounterKeyCode
		self.modifiers = modifiers
		self.forPressed = forPressed
    }

    func buttonPress() {}
	func buttonHold() {}
    func buttonRelease() {}

	private var degreesRotated: Double = 0
    private var accumulator: Double = 0
    private var lastSentValue: Double = 0
    private var lastRotationDirection: RotationState = .stationary

    func rotationChanged(_ rotation: RotationState, _ axis: ScrollDirection, _ isPressed: Bool) -> Bool {
		guard self.forPressed == isPressed else { return false }

		log(tag: "DualInputControl", "Processing Rotation.")

		let degrees: Double = 4
        let step: Double = 1
		let coefficient = 0.2

        var key: CGKeyCode = buttonClockwiseKeyCode
        switch rotation {
            case .clockwise:
                key = buttonClockwiseKeyCode
                if lastRotationDirection.amount <= 0 {
                    lastSentValue = accumulator + rotation.amount * coefficient - step
                }
                lastRotationDirection = .clockwise(1)
            case .anticlockwise:
                key = buttonCounterKeyCode
                if lastRotationDirection.amount >= 0 {
                    lastSentValue = accumulator + rotation.amount * coefficient + step
                }
                lastRotationDirection = .anticlockwise(1)
            case .stationary:
                lastRotationDirection = .stationary
                return false
        }
        accumulator += rotation.amount * coefficient

        let valueDiff = abs(accumulator - lastSentValue)
        let clicks = floor(valueDiff / step)

        if valueDiff >= step {
			if( degreesRotated >= degrees ) {
				let sentValue = lastSentValue + (isClock(key) ? 1 : -1) * (clicks * step)
				lastSentValue = sentValue
				
				KeyPress(key, true, modifiers)
				KeyPress(key, false, modifiers)
				log(tag: "DualInputControl", "\(key.description) was sent \(modifiers.map{ $0.rawValue }.description).")
				
				degreesRotated = 0
				return true
			}
			degreesRotated += 1
		}
		return false
    }

    private func isClock(_ key: CGKeyCode) -> Bool {
        key == buttonClockwiseKeyCode
    }
}
