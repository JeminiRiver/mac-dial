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

class ButtonPressControl: DeviceControl {
    private let eventDownType: CGEventType
    private let eventUpType: CGEventType
    private var lastButtonState: ButtonState?

    init(eventDownType: CGEventType, eventUpType: CGEventType) {
        self.eventDownType = eventDownType
        self.eventUpType = eventUpType
    }

    func buttonPress() {
        if lastButtonState != .pressed {
            lastButtonState = .pressed
            sendMouse(eventType: eventDownType)
        }
    }

    func buttonRelease() {
        if lastButtonState != .released {
            lastButtonState = .released
            sendMouse(eventType: eventUpType)
        }
    }

    private func sendMouse(eventType: CGEventType) {
        let mouseOriginal = NSEvent.mouseLocation
        var mouseLocation = NSEvent.mouseLocation
        
        let screens = NSScreen.screens;
        
        //Multi monitor setups
        
        //NSScreen.main is the focused display NOT the Menu Bar display
        //let screenMain = NSScreen.main;
        
        //Anyway, if what you want is the primary display, the one at (0, 0), just use NSScreen.screens[0].
        let screenMain = NSScreen.screens[0];
        
        let screenWithMouse = (screens.first { NSMouseInRect(mouseLocation, $0.frame, false) })
        
        let frameFromMain = screenMain.frame
        let frameFromScreen = screenWithMouse!.frame
        
        //X is a straight translation from the farthest left screen starting at 0
        //mouseLocation.x -= frameFromScreen.origin.x;
        
        //Expected Y input is the hight of the Primary (menu bar) Display minus recieved Y location
        //Anything else and it breaks multi monitor setups or makes the cursor jump everywhere
        mouseLocation.y = frameFromMain.height - mouseLocation.y
        
        let event = CGEvent(
            mouseEventSource: nil,
            mouseType: eventType,
            mouseCursorPosition: mouseLocation,
            mouseButton: .left
        )
        
        event?.post(tap: .cghidEventTap)
    }

    func rotationChanged(_ rotation: RotationState, _ axis: ScrollDirection) -> Bool {
        return false
    }
}
