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

class ButtonMouseClickControl: DeviceControl {
	private var pressType: PressType = .short
	private var mouseButton: CGMouseButton = .left
	private var eventDownType: CGEventType = .leftMouseDown
	private var eventUpType: CGEventType = .leftMouseUp

	init(
		pressType: PressType,
		mouseButton: CGMouseButton
	) {
		self.pressType = pressType
		self.mouseButton = mouseButton

		switch( self.mouseButton) {
			case .right:
				eventDownType = .rightMouseDown
				eventUpType = .rightMouseUp
				break;
			case .left:
				eventDownType = .leftMouseDown
				eventUpType = .leftMouseUp
				break;
			default:
				eventDownType = .leftMouseDown
				eventUpType = .leftMouseUp
				break;
		}
    }

    func buttonPress() {}
	func buttonHold() {
		if( self.pressType == .short ) { return }
		sendMouseClick(eventDownType)
		sendMouseClick(eventUpType)
	}
	func buttonRelease() {
		if( self.pressType == .long ) { return }
		sendMouseClick(eventDownType)
		sendMouseClick(eventUpType)
    }

	private func sendMouseClick(_ eventType: CGEventType) {
        //let mouseOriginal = NSEvent.mouseLocation
        var mouseLocation = NSEvent.mouseLocation
        
        //let screens = NSScreen.screens;
        
        //Multi monitor setups
		//NSScreen.main is the focused display NOT the Menu Bar display
        //If what you want is the primary display, the one at (0, 0), just use NSScreen.screens[0].
        let screenMain = NSScreen.screens[0];
        //let screenWithMouse = (screens.first { NSMouseInRect(mouseLocation, $0.frame, false) })
        let frameFromMain = screenMain.frame
        //let frameFromScreen = screenWithMouse!.frame
        
        //X is a straight translation from the farthest left screen starting at 0
        //mouseLocation.x -= frameFromScreen.origin.x;
        //Expected Y input is the hight of the Primary (menu bar) Display minus recieved Y location
        //Anything else and it breaks multi monitor setups or makes the cursor jump everywhere
        mouseLocation.y = frameFromMain.height - mouseLocation.y
        
        let event = CGEvent(
            mouseEventSource: nil,
            mouseType: eventType,
            mouseCursorPosition: mouseLocation,
			mouseButton: self.mouseButton
        )
        
        event?.post(tap: .cghidEventTap)
    }

    func rotationChanged(_ rotation: RotationState, _ axis: ScrollDirection, _ isPressed: Bool) -> Bool {
        return false
    }
}
