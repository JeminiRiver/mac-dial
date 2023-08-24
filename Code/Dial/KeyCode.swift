//
//  KeyCode.swift
//  MacDial 2
//
//  Created by Jemini Willis on 8/23/23.
//

import Foundation
import CoreGraphics
import AppKit

extension NSEvent.ModifierFlags: Hashable { }

extension CGKeyCode {
    public init?(character: String) {
        if let keyCode = Initializers.shared.characterKeys[character] {
            self = keyCode
        } else {
            return nil
        }
    }

    public init?(modifierFlag: NSEvent.ModifierFlags) {
        if let keyCode = Initializers.shared.modifierFlagKeys[modifierFlag] {
            self = keyCode
        } else {
            return nil
        }
    }

    public init?(specialKey: NSEvent.SpecialKey) {
        if let keyCode = Initializers.shared.specialKeys[specialKey] {
            self = keyCode
        } else {
            return nil
        }
    }

    private struct Initializers {
        let specialKeys: [NSEvent.SpecialKey:CGKeyCode]
        let characterKeys: [String:CGKeyCode]
        let modifierFlagKeys: [NSEvent.ModifierFlags:CGKeyCode]

        static let shared = Initializers()

        init() {
            var specialKeys = [NSEvent.SpecialKey:CGKeyCode]()
            var characterKeys = [String:CGKeyCode]()
            var modifierFlagKeys = [NSEvent.ModifierFlags:CGKeyCode]()

            for keyCode in (0..<128).map({ CGKeyCode($0) }) {
                guard let cgevent = CGEvent(keyboardEventSource: nil, virtualKey: CGKeyCode(keyCode), keyDown: true) else { continue }
                guard let nsevent = NSEvent(cgEvent: cgevent) else { continue }

                var hasHandledKeyCode = false
                if nsevent.type == .keyDown {
                    if let specialKey = nsevent.specialKey {
                        hasHandledKeyCode = true
                        specialKeys[specialKey] = keyCode
                    } else if let characters = nsevent.charactersIgnoringModifiers, !characters.isEmpty && characters != "\u{0010}" {
                        hasHandledKeyCode = true
                        characterKeys[characters] = keyCode
                    }
                } else if nsevent.type == .flagsChanged {
                    switch(nsevent.modifierFlags) {
                    case .capsLock:
                        modifierFlagKeys[.capsLock] = keyCode
                    case .capsLock:
                        modifierFlagKeys[.shift] = keyCode
                    case .capsLock:
                        modifierFlagKeys[.control] = keyCode
                    case .capsLock:
                        modifierFlagKeys[.option] = keyCode
                    case .capsLock:
                        modifierFlagKeys[.command] = keyCode
                    case .capsLock:
                        modifierFlagKeys[.help] = keyCode
                    case .capsLock:
                        modifierFlagKeys[.function] = keyCode
                    default:
                        hasHandledKeyCode = true
                        break
                    }
                }
                if !hasHandledKeyCode {
                    #if DEBUG
                    print("Unhandled keycode \(keyCode): \(nsevent)")
                    #endif
                }
            }
            self.specialKeys = specialKeys
            self.characterKeys = characterKeys
            self.modifierFlagKeys = modifierFlagKeys
        }
    }

}
