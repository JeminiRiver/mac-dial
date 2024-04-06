//
// ScrollControlMode
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

class DialZoomControl: DeviceControl {
	private let forPressed: Bool

	init(
		forPressed: Bool
	) {
		self.forPressed = forPressed
	}
	
    func buttonPress() {}
	func buttonHold() {}
    func buttonRelease() {}

    private var lastRotate: TimeInterval = Date().timeIntervalSince1970

	func rotationChanged(_ rotation: RotationState, _ axis: ScrollDirection, _ isPressed: Bool) -> Bool {
		guard self.forPressed == isPressed else { return false }
        guard rotation != .stationary else { return false }

        guard let plusKeyCode = CGKeyCode(character: "+") else { fatalError() }
        guard let minusKeyCode = CGKeyCode(character: "-") else { fatalError() }
		
        let key : CGKeyCode = (rotation.amount > 0) ? plusKeyCode : ( (rotation.amount < 0) ? minusKeyCode : 55 )

		KeyPress(key, true, [CGEventFlags.maskCommand])
        KeyPress(key, false, [CGEventFlags.maskCommand])
        
		return true;
    }
    
    
}
