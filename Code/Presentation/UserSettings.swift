//
// UserSettings
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

extension SettingsValueKey {
	
	static let buttonMode: SettingsValueKey = "settings.buttonMode"
	static let longPressMode: SettingsValueKey = "settings.longPressMode"
	static let dialMode: SettingsValueKey = "settings.dialMode"
	static let holdAndDialMode: SettingsValueKey = "settings.holdAndDialMode"
	static let pressLength: SettingsValueKey = "settings.pressLength"
	static let sensitivity: SettingsValueKey = "settings.sensitivity"
	static let rotationClick: SettingsValueKey = "settings.isRotationClickEnabled"
	static let wheelRotation: SettingsValueKey = "settings.wheelRotation"
	static let scrollDirection: SettingsValueKey = "settings.scrollDirection"
}

class UserSettings {
	
	enum ButtonOperationMode {
		case leftClick
		case rightClick
		case playback
		case launchpad
	}
	
	enum LongPressOperationMode {
		case leftClick
		case rightClick
		case launchpad
		case holdanddial
	}
	
	enum DialOperationMode {
		case scrolling
		case volume
		case brightness
		case keyboard
		case zoom
		case spaces
	}
	
	enum HoldAndDialOperationMode {
		case scrolling
		case volume
		case brightness
		case keyboard
		case zoom
		case spaces
	}
	
	enum PressLength {
		case short
		case avg
		case long
	}
	
	enum WheelSensitivity {
		case low
		case medium
		case high
	}
	
	
	@FromUserDefaults(key: .buttonMode, defaultValue: 1)
	private var buttonModeSetting: Int
	
	@FromUserDefaults(key: .longPressMode, defaultValue: 2)
	private var longPressModeSetting: Int
	
	@FromUserDefaults(key: .dialMode, defaultValue: 1)
	private var dialModeSetting: Int
	
	@FromUserDefaults(key: .holdAndDialMode, defaultValue: 1)
	private var holdAndDialModeSetting: Int
	
	@FromUserDefaults(key: .pressLength, defaultValue: 2)
	private var pressLengthSetting: Double
	
	@FromUserDefaults(key: .sensitivity, defaultValue: 2)
	private var sensitivitySetting: Int
	
	@FromUserDefaults(key: .rotationClick, defaultValue: true)
	private var isRotationClickEnabledSetting: Bool
	
	@FromUserDefaults(key: .wheelRotation, defaultValue: 1)
	private var wheelRotationSetting: Int
	
	@FromUserDefaults(key: .scrollDirection, defaultValue: 1)
	private var scrollDirectionSetting: Int
	
	var buttonMode: ButtonOperationMode {
		get {
			switch buttonModeSetting {
				case 1: return .leftClick
				case 2: return .rightClick
				case 3: return .playback
				case 4: return .launchpad
				default: return .leftClick
			}
		}
		set {
			switch newValue {
				case .leftClick: buttonModeSetting = 1
				case .rightClick: buttonModeSetting = 2
				case .playback: buttonModeSetting = 3
				case .launchpad: buttonModeSetting = 4
			}
		}
	}
	
	var longPressMode: LongPressOperationMode {
		get {
			switch longPressModeSetting {
				case 1: return .leftClick
				case 2: return .rightClick
				case 3: return .launchpad
				case 4: return .holdanddial
				default: return .rightClick
			}
		}
		set {
			switch newValue {
				case .leftClick: longPressModeSetting = 1
				case .rightClick: longPressModeSetting = 2
				case .launchpad: longPressModeSetting = 3
				case .holdanddial: longPressModeSetting = 4
			}
		}
	}
	
	var dialMode: DialOperationMode {
		get {
			switch dialModeSetting {
				case 2: return .volume
				case 1: return .scrolling
				case 5: return .zoom
				case 3: return .brightness
				case 4: return .keyboard
				case 6: return .spaces
				default: return .scrolling
			}
		}
		set {
			switch newValue {
				case .volume: dialModeSetting = 2
				case .scrolling: dialModeSetting = 1
				case .zoom: dialModeSetting = 5
				case .brightness: dialModeSetting = 3
				case .keyboard: dialModeSetting = 4
				case .spaces: dialModeSetting = 6
			}
		}
	}
	
	var holdAndDialMode: HoldAndDialOperationMode {
		get {
			switch holdAndDialModeSetting {
				case 2: return .volume
				case 1: return .scrolling
				case 5: return .zoom
				case 3: return .brightness
				case 4: return .keyboard
				case 6: return .spaces
				default: return .scrolling
			}
		}
		set {
			switch newValue {
				case .volume: holdAndDialModeSetting = 2
				case .scrolling: holdAndDialModeSetting = 1
				case .zoom: holdAndDialModeSetting = 5
				case .brightness: holdAndDialModeSetting = 3
				case .keyboard: holdAndDialModeSetting = 4
				case .spaces: holdAndDialModeSetting = 6
			}
		}
	}
	
	var pressLength: PressLength {
		get {
			switch pressLengthSetting {
				case 0.5: return .short
				case 1.0: return .avg
				case 1.5: return .long
				default: return .avg
			}
		}
		set {
			switch newValue {
				case .short: pressLengthSetting = 0.5
				case .avg: pressLengthSetting = 1.0
				case .long: pressLengthSetting = 1.5
			}
		}
	}
	
	var sensitivity: WheelSensitivity {
		get {
			switch sensitivitySetting {
				case 1: return .low
				case 2: return .medium
				case 3: return .high
				default: return .low
			}
		}
		set {
			switch newValue {
				case .low: sensitivitySetting = 1
				case .medium: sensitivitySetting = 2
				case .high: sensitivitySetting = 3
			}
		}
	}
	
	var isRotationClickEnabled: Bool {
		get {
			isRotationClickEnabledSetting
		}
		set {
			isRotationClickEnabledSetting = newValue
		}
	}
	
	var wheelRotation: WheelRotation {
		get {
			wheelRotationSetting < 0 ? .anticlockwise : .clockwise
		}
		set {
			wheelRotationSetting = newValue == .clockwise ? 1 : -1
		}
	}
	
	var scrollDirection: ScrollDirection {
		get {
			switch scrollDirectionSetting {
				case 1: return .vertical
				case 2: return .horizontal
				default: return .vertical
			}
		}
		set {
			switch newValue {
				case .vertical: scrollDirectionSetting = 1
				case .horizontal: scrollDirectionSetting = 2
			}
		}
	}
	
}

struct SettingsValueKey: ExpressibleByStringLiteral {
	var name: String
	
	init(stringLiteral value: StringLiteralType) {
		name = value
	}
}

@propertyWrapper
struct FromUserDefaults<Value> {
	private let key: String
	private let defaultValue: Value
	private let userDefaults: UserDefaults
	
	init(key: SettingsValueKey, userDefaults: UserDefaults = UserDefaults.standard, defaultValue: Value) {
		self.key = key.name
		self.defaultValue = defaultValue
		self.userDefaults = userDefaults
	}
	
	var wrappedValue: Value {
		get {
			userDefaults.object(forKey: key) as? Value ?? defaultValue
		}
		set {
			userDefaults.set(newValue, forKey: key)
		}
	}
}
