//
//  DialKeyInputControl.swift
//  MacDial 2
//
//  Created by Jemini Willis on 8/27/23.
//

import AppKit
import Carbon

class DialKeyInputControl: DeviceControl {
	private var pressType: PressType = .short
	private var keyCode: CGKeyCode;
	private var keyFlags: [CGEventFlags];
	private let eventDownType: CGEventType = .keyDown
	private let eventUpType: CGEventType = .keyUp

	init(pressType: PressType, keyCode: CGKeyCode, keyFlags: [CGEventFlags]) {
		self.pressType = pressType
		self.keyCode = keyCode
		self.keyFlags = keyFlags
	}
	
	func buttonPress() {}

	func buttonHold() {
		if( self.pressType == .short ) { return }
		KeyPress(self.keyCode, true, self.keyFlags)
		KeyPress(self.keyCode, false, self.keyFlags)
	}
	
	func buttonRelease() {
		if( self.pressType == .long ) { return }
		KeyPress(self.keyCode, true, self.keyFlags)
		KeyPress(self.keyCode, false, self.keyFlags)
	}

	func rotationChanged(_ rotation: RotationState, _ axis: ScrollDirection) -> Bool {
		return true;
	}
	
	
}
