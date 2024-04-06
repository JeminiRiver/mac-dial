//
// Dial
// MacDial
//
// Created by Alex Babaev on 28 January 2022.
//
// Based on Andreas Karlsson sources
// https://github.com/andreasjhkarlsson/mac-dial
//
// License: MIT
//

import Foundation

private var _scrollDirection: ScrollDirection = .vertical

class Dial {
    var controls: [DeviceControl] = []

    var wheelSensitivity: Double {
        get { device.wheelSensitivity }
        set { device.wheelSensitivity = newValue }
    }

	var pressLength: Double {
		get { device.pressLength }
		set { device.pressLength = newValue }
	}

    var wheelRotation: WheelRotation {
        get { device.wheelRotation }
        set { device.wheelRotation = newValue }
    }

    var scrollDirection: ScrollDirection {
        get { _scrollDirection }
        set { _scrollDirection = newValue }
    }
    
    var isRotationClickEnabled: Bool {
        get { device.isRotationClickEnabled }
        set { device.isRotationClickEnabled = newValue }
    }
	
    private var device: DialDevice!

    init(
        connectionHandler: @escaping (_ serialNumber: String) -> Void,
        disconnectionHandler: @escaping () -> Void
    ) {
        device = DialDevice(
            buttonHandler: processButton,
            rotationHandler: processRotation,
            connectionHandler: connectionHandler,
            disconnectionHandler: disconnectionHandler
        )
    }

    deinit {
        device.disconnect()
    }

    private var lastButtonState: ButtonState = .released

	private func processButton(state: ButtonState, longPress: Bool) {
		let previousButtonState = self.lastButtonState
		self.lastButtonState = state
		
		switch (previousButtonState, state) {
			case (.released, .pressed):
				controls.forEach {
					$0.buttonPress()
				}
			case (.pressed, .released):
				controls.forEach {
					if(longPress) {
						$0.buttonHold()
					} else {
						$0.buttonRelease()
					}
				}
			default: break
		}
	}

	private func processRotation(state: RotationState, isPressed: Bool) -> Bool {
        var result = false
        controls.forEach { result = $0.rotationChanged(state, scrollDirection, isPressed) || result }
        return result
    }
}
