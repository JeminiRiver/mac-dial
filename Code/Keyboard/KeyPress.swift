//
//  KeyPress.swift
//  MacDial 2
//
//  Created by Jemini Willis on 8/27/23.
//

import Foundation
import AppKit
import Carbon

func KeyPress(_ key: CGKeyCode, _ down: Bool, _ keyFlags: [CGEventFlags]) {
	if
		let source = CGEventSource( stateID: .privateState ),
		let event = CGEvent( keyboardEventSource: source, virtualKey: key, keyDown: down ) {
		for keyFlag in keyFlags {
			event.flags.insert(keyFlag);
			//event.flags = CGEventFlags.maskCommand
		}
		event.type = down ? .keyDown : .keyUp
		event.post( tap: .cghidEventTap )
	}
}
