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
    func buttonPress() {
    }

    func buttonRelease() {
    }

    private var lastRotate: TimeInterval = Date().timeIntervalSince1970

    func rotationChanged(_ rotation: RotationState, _ axis: ScrollDirection) -> Bool {
        guard rotation != .stationary else { return false }

        guard let plusKeyCode = CGKeyCode(character: "+") else { fatalError() }
        guard let minusKeyCode = CGKeyCode(character: "-") else { fatalError() }
        let key : CGKeyCode = (rotation.amount > 0) ? plusKeyCode : ( (rotation.amount < 0) ? minusKeyCode : 55 )
        KeyPress(key, true, true)
        KeyPress(key, false, true)
        return true;
    }
    
    func KeyPress(_ key: CGKeyCode, _ down: Bool, _ command: Bool) {
        if
            let source = CGEventSource( stateID: .privateState ),
            let event = CGEvent( keyboardEventSource: source, virtualKey: key, keyDown: down ) {
            if(command) {
                event.flags = CGEventFlags.maskCommand
            }
            event.type = down ? .keyDown : .keyUp
            event.post( tap: .cghidEventTap )
        }
    }
}
