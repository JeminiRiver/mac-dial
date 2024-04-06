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
import Foundation
import CoreGraphics

class DialScrollControl: DeviceControl {
    private let withControl: Bool
	private let forPressed: Bool
    
	init(
		forPressed: Bool,
		withControl: Bool = false
	) {
        self.withControl = withControl
		self.forPressed = forPressed
    }
    
    func buttonPress() {}
	func buttonHold() {}
    func buttonRelease() {}
    
    private var lastRotate: TimeInterval = Date().timeIntervalSince1970
    
	func rotationChanged(_ rotation: RotationState, _ axis: ScrollDirection, _ isPressed: Bool) -> Bool {
		guard self.forPressed == isPressed else { return false }
        guard rotation != .stationary else { return false }
		
        var amount = rotation.amount
        
        //MacOS Inverts vertical & horizontal scrolling by default
        if( axis == .vertical || axis == .horizontal ) {
            amount = -amount
        }
        
        let diff = (Date().timeIntervalSince1970 - lastRotate) * 1000
        let multiplier = Double(1.0 + ((150.0 - min(diff, 150.0)) / 40.0))
        let steps: Int32 = Int32(floor(amount * multiplier))
        
        let scrollEvent = CGEvent(
            scrollWheelEvent2Source: nil,
            units: withControl ? .pixel : .line,
            wheelCount: 2,
            wheel1: axis == .vertical ? steps : 0,
            wheel2: axis == .horizontal ? steps : 0,
            wheel3: 0 //DOES NOT WORK FOR ZOOM CONTROL
        )
        if withControl {
            scrollEvent?.flags = .maskControl
        }
        scrollEvent?.post(tap: .cghidEventTap)
        log(tag: "Scroll", "sent scroll event [\(axis)]: \(steps) steps\(withControl ? " with Control" : "")")
        log(tag: "Scrolling", "Wheel 1: \(axis == .vertical) | Wheel 2: \(axis == .horizontal)");
        
        lastRotate = Date().timeIntervalSince1970
        return true
    }
    
}
