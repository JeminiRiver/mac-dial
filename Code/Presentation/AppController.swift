//
// AppController
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

class AppController: NSObject {
	@IBOutlet private var statusMenu: NSMenu!
	
	@IBOutlet private var menuShortMode: NSMenuItem!
	@IBOutlet private var menuShortModeLeft: NSMenuItem!
	@IBOutlet private var menuShortModeRight: NSMenuItem!
	@IBOutlet private var menuShortModePlayback: NSMenuItem!
	@IBOutlet private var menuShortModeLaunchpad: NSMenuItem!
	
	@IBOutlet private var menuLongMode: NSMenuItem!
	@IBOutlet private var menuLongModeLeft: NSMenuItem!
	@IBOutlet private var menuLongModeRight: NSMenuItem!
	@IBOutlet private var menuLongModeLaunchpad: NSMenuItem!
	@IBOutlet private var menuLongModeHoldAndDial: NSMenuItem!
	
	@IBOutlet private var menuDialControlMode: NSMenuItem!
	@IBOutlet private var menuDialControlModeScroll: NSMenuItem!
	@IBOutlet private var menuDialControlModeVolume: NSMenuItem!
	@IBOutlet private var menuDialControlModeBrightness: NSMenuItem!
	@IBOutlet private var menuDialControlModeKeyboard: NSMenuItem!
	@IBOutlet private var menuDialControlModeZoom: NSMenuItem!
	@IBOutlet private var menuDialControlModeSpaces: NSMenuItem!
	
	@IBOutlet private var menuHoldAndDialMode: NSMenuItem!
	@IBOutlet private var menuHoldAndDialModeScroll: NSMenuItem!
	@IBOutlet private var menuHoldAndDialModeVolume: NSMenuItem!
	@IBOutlet private var menuHoldAndDialModeBrightness: NSMenuItem!
	@IBOutlet private var menuHoldAndDialModeKeyboard: NSMenuItem!
	@IBOutlet private var menuHoldAndDialModeZoom: NSMenuItem!
	@IBOutlet private var menuHoldAndDialModeSpaces: NSMenuItem!
	
	@IBOutlet private var menuPressLength: NSMenuItem!
	@IBOutlet private var menuPressLengthShort: NSMenuItem!
	@IBOutlet private var menuPressLengthAvg: NSMenuItem!
	@IBOutlet private var menuPressLengthLong: NSMenuItem!
	
	@IBOutlet private var menuSensitivity: NSMenuItem!
	@IBOutlet private var menuSensitivityLow: NSMenuItem!
	@IBOutlet private var menuSensitivityMedium: NSMenuItem!
	@IBOutlet private var menuSensitivityHigh: NSMenuItem!
	
	@IBOutlet private var menuWheelRotation: NSMenuItem!
	@IBOutlet private var menuWheelRotationCW: NSMenuItem!
	@IBOutlet private var menuWheelRotationCCW: NSMenuItem!
	
	@IBOutlet private var menuScrollDirection: NSMenuItem!
	@IBOutlet private var menuScrollDirectionVert: NSMenuItem!
	@IBOutlet private var menuScrollDirectionHorz: NSMenuItem!
	
	@IBOutlet private var menuHaptics: NSMenuItem!
	
	@IBOutlet private var menuState: NSMenuItem!
	@IBOutlet private var menuQuit: NSMenuItem!
	
	private let statusItem: NSStatusItem
	
	private let settings: UserSettings = .init()
	
	private var dial: Dial?
	private var dialControl: DeviceControl?
	private var holdAndDialControl: DeviceControl?
	private var buttonControl: DeviceControl?
	private var longPressControl: DeviceControl?
	
	override init() {
		statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
		super.init()
		
		dial = Dial(connectionHandler: connected, disconnectionHandler: disconnected)
	}
	
	override func awakeFromNib() {
		statusItem.menu = statusMenu
		
		resetTitles()
		
		switch settings.buttonMode {
			case .leftClick:
				buttonModeSelect(item: menuShortModeLeft)
			case .rightClick:
				buttonModeSelect(item: menuShortModeRight)
			case .playback:
				buttonModeSelect(item: menuShortModePlayback)
			case .launchpad:
				buttonModeSelect(item: menuShortModeLaunchpad)
		}
		switch settings.longPressMode {
			case .leftClick:
				longPressModeSelect(item: menuLongModeLeft)
			case .rightClick:
				longPressModeSelect(item: menuLongModeRight)
			case .launchpad:
				longPressModeSelect(item: menuLongModeLaunchpad)
			case .holdanddial:
				longPressModeSelect(item: menuLongModeHoldAndDial)
		}
		switch settings.dialMode {
			case .scrolling:
				dialModeSelect(item: menuDialControlModeScroll)
			case .volume:
				dialModeSelect(item: menuDialControlModeVolume)
			case .brightness:
				dialModeSelect(item: menuDialControlModeBrightness)
			case .keyboard:
				dialModeSelect(item: menuDialControlModeKeyboard)
			case .zoom:
				dialModeSelect(item: menuDialControlModeZoom)
			case .spaces:
				dialModeSelect(item: menuDialControlModeSpaces)
		}
		switch settings.holdAndDialMode {
			case .scrolling:
				holdAndDialModeSelect(item: menuHoldAndDialModeScroll)
			case .volume:
				holdAndDialModeSelect(item: menuHoldAndDialModeVolume)
			case .brightness:
				holdAndDialModeSelect(item: menuHoldAndDialModeBrightness)
			case .keyboard:
				holdAndDialModeSelect(item: menuHoldAndDialModeKeyboard)
			case .zoom:
				holdAndDialModeSelect(item: menuHoldAndDialModeZoom)
			case .spaces:
				holdAndDialModeSelect(item: menuHoldAndDialModeSpaces)
		}
		switch settings.pressLength {
			case .short:
				pressLengthSelect(item: menuPressLengthShort)
			case .avg:
				pressLengthSelect(item: menuPressLengthAvg)
			case .long:
				pressLengthSelect(item: menuPressLengthLong)
		}
		switch settings.sensitivity {
			case .low:
				sensitivitySelect(item: menuSensitivityLow)
			case .medium:
				sensitivitySelect(item: menuSensitivityMedium)
			case .high:
				sensitivitySelect(item: menuSensitivityHigh)
		}
		switch settings.wheelRotation {
			case .clockwise:
				rotationSelect(item: menuWheelRotationCW)
			case .anticlockwise:
				rotationSelect(item: menuWheelRotationCCW)
		}
		switch settings.scrollDirection {
			case .vertical:
				directionSelect(item: menuScrollDirectionVert)
			case .horizontal:
				directionSelect(item: menuScrollDirectionHorz)
		}
		updateRotationClickSetting(newValue: settings.isRotationClickEnabled)
	}
	
	func terminate() {
		dial = nil
	}
	
	private func connected(_ serialNumber: String) {
		menuState.title = String(format: NSLocalizedString("dial.connected", comment: ""), serialNumber)
	}
	
	private func disconnected() {
		menuState.title = NSLocalizedString("dial.disconnected", comment: "")
	}
	
	
	private func resetTitles() {
		menuShortMode.title = NSLocalizedString("menu.shortMode", comment: "")
		menuShortModeLeft.title = NSLocalizedString("menu.shortMode.leftClick", comment: "")
		menuShortModeRight.title = NSLocalizedString("menu.shortMode.rightClick", comment: "")
		menuShortModePlayback.title = NSLocalizedString("menu.shortMode.playback", comment: "")
		menuShortModeLaunchpad.title = NSLocalizedString("menu.shortMode.launchpad", comment: "")
		
		menuLongMode.title = NSLocalizedString("menu.longMode", comment: "")
		menuLongModeLeft.title = NSLocalizedString("menu.longMode.leftClick", comment: "")
		menuLongModeRight.title = NSLocalizedString("menu.longMode.rightClick", comment: "")
		menuLongModeLaunchpad.title = NSLocalizedString("menu.longMode.launchpad", comment: "")
		menuLongModeHoldAndDial.title = NSLocalizedString("menu.longMode.holdAndDial", comment: "")
		
		menuDialControlMode.title = NSLocalizedString("menu.dialMode", comment: "")
		menuDialControlModeScroll.title = NSLocalizedString("menu.dialMode.scroll", comment: "")
		menuDialControlModeZoom.title = NSLocalizedString("menu.dialMode.zoom", comment: "")
		menuDialControlModeVolume.title = NSLocalizedString("menu.dialMode.music", comment: "")
		menuDialControlModeBrightness.title = NSLocalizedString("menu.dialMode.brightness", comment: "")
		menuDialControlModeKeyboard.title = NSLocalizedString("menu.dialMode.keyboard", comment: "")
		menuDialControlModeSpaces.title = NSLocalizedString("menu.dialMode.spaces", comment: "")
		
		menuHoldAndDialMode.title = NSLocalizedString("menu.holdAndDialMode", comment: "")
		menuHoldAndDialModeScroll.title = NSLocalizedString("menu.dialMode.scroll", comment: "")
		menuHoldAndDialModeZoom.title = NSLocalizedString("menu.dialMode.zoom", comment: "")
		menuHoldAndDialModeVolume.title = NSLocalizedString("menu.dialMode.music", comment: "")
		menuHoldAndDialModeBrightness.title = NSLocalizedString("menu.dialMode.brightness", comment: "")
		menuHoldAndDialModeKeyboard.title = NSLocalizedString("menu.dialMode.keyboard", comment: "")
		menuHoldAndDialModeSpaces.title = NSLocalizedString("menu.dialMode.spaces", comment: "")
		
		menuPressLength.title = NSLocalizedString("menu.pressLength", comment: "")
		menuPressLengthShort.title = NSLocalizedString("menu.pressLength.short", comment: "")
		menuPressLengthAvg.title = NSLocalizedString("menu.pressLength.avg", comment: "")
		menuPressLengthLong.title = NSLocalizedString("menu.pressLength.long", comment: "")
		
		menuSensitivity.title = NSLocalizedString("menu.rotationSensitivity", comment: "")
		menuSensitivityLow.title = NSLocalizedString("menu.rotationSensitivity.low", comment: "")
		menuSensitivityMedium.title = NSLocalizedString("menu.rotationSensitivity.medium", comment: "")
		menuSensitivityHigh.title = NSLocalizedString("menu.rotationSensitivity.high", comment: "")
		
		menuWheelRotation.title = NSLocalizedString("menu.rotation", comment: "")
		menuWheelRotationCW.title = NSLocalizedString("menu.rotation.cw", comment: "")
		menuWheelRotationCCW.title = NSLocalizedString("menu.rotation.ccw", comment: "")
		
		menuScrollDirection.title = NSLocalizedString("menu.direction", comment: "")
		menuScrollDirectionVert.title = NSLocalizedString("menu.direction.vert", comment: "")
		menuScrollDirectionHorz.title = NSLocalizedString("menu.direction.horz", comment: "")
		
		menuHaptics.title = NSLocalizedString("menu.rotationFeedback", comment: "")
		menuQuit.title = NSLocalizedString("menu.quit", comment: "")
	}
	
	
	private func updateMenuBarItem(from: NSMenuItem) {
		let selectedImage = from.image ?? NSImage(named: "icon-scroll-small")!
		statusItem.button?.image = selectedImage
		statusItem.button?.image?.size = .init(width: 18, height: 18)
		statusItem.button?.imagePosition = .imageLeft
		statusItem.button?.toolTip = from.title
	}
	
	@IBAction
	private func buttonModeSelect(item: NSMenuItem) {
		menuShortModeLeft.state = .off
		menuShortModeRight.state = .off
		menuShortModePlayback.state = .off
		menuShortModeLaunchpad.state = .off
		item.state = .on
		menuShortMode.image = item.image
		switch item.identifier {
			case menuShortModeLeft.identifier:
				buttonControl = ButtonMouseClickControl(pressType: .short, mouseButton: .left)
				settings.buttonMode = .leftClick
			case menuShortModeRight.identifier:
				buttonControl = ButtonMouseClickControl(pressType: .short, mouseButton: .right)
				settings.buttonMode = .rightClick
			case menuShortModePlayback.identifier:
				buttonControl = ButtonPlaybackControl()
				settings.buttonMode = .playback
			case menuShortModeLaunchpad.identifier:
				buttonControl = DialKeyInputControl(pressType: .short, keyCode: .init(160), keyFlags: [])
				settings.buttonMode = .launchpad
			default:
				break
		}
		dial?.controls =
		(dialControl.map { [ $0 ] } ?? []) +
		(holdAndDialControl.map { [ $0 ] } ?? []) +
		(buttonControl.map { [ $0 ] } ?? []) +
		(longPressControl.map { [ $0 ] } ?? [])	}
	
	@IBAction
	private func longPressModeSelect(item: NSMenuItem) {
		menuLongModeLeft.state = .off
		menuLongModeRight.state = .off
		menuLongModeLaunchpad.state = .off
		menuLongModeHoldAndDial.state = .off
		
		menuHoldAndDialMode.isEnabled = false;
		
		item.state = .on
		menuLongMode.image = item.image
		
		switch item.identifier {
			case menuLongModeLeft.identifier:
				longPressControl = ButtonMouseClickControl(pressType: .long, mouseButton: .left)
				settings.longPressMode = .leftClick
				break;
			case menuLongModeRight.identifier:
				longPressControl = ButtonMouseClickControl(pressType: .long, mouseButton: .right)
				settings.longPressMode = .rightClick
				break;
			case menuLongModeLaunchpad.identifier: //Launchpad
				longPressControl = DialKeyInputControl(pressType: .long, keyCode: .init(130), keyFlags: [])
				settings.longPressMode = .launchpad
				break;
			case menuLongModeHoldAndDial.identifier: //HoldAndDial
				//longPressControl = DialKeyInputControl(pressType: .long, keyCode: .init(130), keyFlags: [])
				settings.longPressMode = .holdanddial
				menuHoldAndDialMode.isEnabled = true;
				break;
				//case menuLongModeLaunchpad.identifier: //Expose/Mission Control
				//longPressControl = DialKeyInputControl(pressType: .long, keyCode: .init(160), keyFlags: [])
				//settings.longPressMode = .launchpad
			default:
				break
		}
		dial?.controls =
		(dialControl.map { [ $0 ] } ?? []) +
		(holdAndDialControl.map { [ $0 ] } ?? []) +
		(buttonControl.map { [ $0 ] } ?? []) +
		(longPressControl.map { [ $0 ] } ?? [])	}
	
	@IBAction
	private func dialModeSelect(item: NSMenuItem) {
		menuDialControlModeScroll.state = .off
		menuDialControlModeVolume.state = .off
		menuDialControlModeBrightness.state = .off
		menuDialControlModeKeyboard.state = .off
		menuDialControlModeZoom.state = .off
		menuDialControlModeSpaces.state = .off
		
		menuScrollDirection.isEnabled = false;
		
		item.state = .on
		menuDialControlMode.image = item.image
		
		switch item.identifier {
				//Scroll
			case menuDialControlModeScroll.identifier:
				dialControl = DialScrollControl(forPressed: false)
				settings.dialMode = .scrolling
				menuScrollDirection.isEnabled = true;
				break;
				//Zoom
			case menuDialControlModeZoom.identifier:
				dialControl = DialZoomControl(forPressed: false)
				settings.dialMode = .zoom
				break;
				//Volume
			case menuDialControlModeVolume.identifier:
				dialControl = DialKeysUpDownControl(
					forPressed: false,
					buttonUpKeyCode: NX_KEYTYPE_SOUND_UP,
					buttonDownKeyCode: NX_KEYTYPE_SOUND_DOWN,
					modifiers: [ .shift, .option ]
				)
				settings.dialMode = .volume
				break;
				//Brightness
			case menuDialControlModeBrightness.identifier:
				dialControl = DialKeysUpDownControl(
					forPressed: false,
					buttonUpKeyCode: NX_KEYTYPE_BRIGHTNESS_UP,
					buttonDownKeyCode: NX_KEYTYPE_BRIGHTNESS_DOWN,
					modifiers: [ .control ],
					useModifiersWhenExternalDisplayIsMain: true
				)
				settings.dialMode = .brightness
				break;
				//Keyboard
			case menuDialControlModeKeyboard.identifier:
				dialControl = DialKeysUpDownControl(
					forPressed: false,
					buttonUpKeyCode: NX_KEYTYPE_ILLUMINATION_UP,
					buttonDownKeyCode: NX_KEYTYPE_ILLUMINATION_DOWN
				)
				settings.dialMode = .keyboard
				break;
				//Spaces
			case menuDialControlModeSpaces.identifier:
				dialControl = DialKeysDualInputControl(
					forPressed: false,
					buttonClockwiseKeyCode: CGKeyCode(specialKey: .leftArrow),
					buttonCounterKeyCode: CGKeyCode(specialKey: .rightArrow),
					modifiers: [ .maskControl ]
				)
				settings.dialMode = .spaces
				break;
			default:
				break
		}
		dial?.controls =
		(dialControl.map { [ $0 ] } ?? []) +
		(holdAndDialControl.map { [ $0 ] } ?? []) +
		(buttonControl.map { [ $0 ] } ?? []) +
		(longPressControl.map { [ $0 ] } ?? [])
		updateMenuBarItem(from: item)
	}
	
	@IBAction
	private func holdAndDialModeSelect(item: NSMenuItem) {
		menuHoldAndDialModeScroll.state = .off
		menuHoldAndDialModeVolume.state = .off
		menuHoldAndDialModeBrightness.state = .off
		menuHoldAndDialModeKeyboard.state = .off
		menuHoldAndDialModeZoom.state = .off
		menuHoldAndDialModeSpaces.state = .off
		
		item.state = .on
		menuHoldAndDialMode.image = item.image
		
		switch item.identifier {
				//Scroll
			case menuHoldAndDialModeScroll.identifier:
				holdAndDialControl = DialScrollControl(forPressed: true)
				settings.holdAndDialMode = .scrolling
				break;
				//Zoom
			case menuHoldAndDialModeZoom.identifier:
				holdAndDialControl = DialZoomControl(forPressed: true)
				settings.holdAndDialMode = .zoom
				break;
				//Volume
			case menuHoldAndDialModeVolume.identifier:
				holdAndDialControl = DialKeysUpDownControl(
					forPressed: true,
					buttonUpKeyCode: NX_KEYTYPE_SOUND_UP,
					buttonDownKeyCode: NX_KEYTYPE_SOUND_DOWN,
					modifiers: [ .shift, .option ]
				)
				settings.holdAndDialMode = .volume
				break;
				//Brightness
			case menuHoldAndDialModeBrightness.identifier:
				holdAndDialControl = DialKeysUpDownControl(
					forPressed: true,
					buttonUpKeyCode: NX_KEYTYPE_BRIGHTNESS_UP,
					buttonDownKeyCode: NX_KEYTYPE_BRIGHTNESS_DOWN,
					modifiers: [ .control ],
					useModifiersWhenExternalDisplayIsMain: true
				)
				settings.holdAndDialMode = .brightness
				break;
				//Keyboard
			case menuHoldAndDialModeKeyboard.identifier:
				holdAndDialControl = DialKeysUpDownControl(
					forPressed: true,
					buttonUpKeyCode: NX_KEYTYPE_ILLUMINATION_UP,
					buttonDownKeyCode: NX_KEYTYPE_ILLUMINATION_DOWN
				)
				settings.holdAndDialMode = .keyboard
				break;
				//Spaces
			case menuHoldAndDialModeSpaces.identifier:
				holdAndDialControl = DialKeysDualInputControl(
					forPressed: true,
					buttonClockwiseKeyCode: CGKeyCode(specialKey: .leftArrow),
					buttonCounterKeyCode: CGKeyCode(specialKey: .rightArrow),
					modifiers: [ .maskControl ]
				)
				settings.holdAndDialMode = .spaces
				break;
			default:
				break
		}
		dial?.controls =
		(dialControl.map { [ $0 ] } ?? []) +
		(holdAndDialControl.map { [ $0 ] } ?? []) +
		(buttonControl.map { [ $0 ] } ?? []) +
		(longPressControl.map { [ $0 ] } ?? [])
		//updateMenuBarItem(from: item)
	}
	
	
	
	
	@IBAction
	private func pressLengthSelect(item: NSMenuItem) {
		menuPressLengthShort.state = .off
		menuPressLengthAvg.state = .off
		menuPressLengthLong.state = .off
		switch item.identifier {
			case menuPressLengthShort.identifier:
				menuPressLengthShort.state = .on
				dial?.pressLength = 0.5
				settings.pressLength = .short
			case menuPressLengthAvg.identifier:
				menuPressLengthAvg.state = .on
				dial?.pressLength = 1
				settings.pressLength = .avg
			case menuPressLengthLong.identifier:
				menuPressLengthLong.state = .on
				dial?.pressLength = 1.5
				settings.pressLength = .long
			default:
				break
		}
	}
	
	@IBAction
	private func sensitivitySelect(item: NSMenuItem) {
		menuSensitivityLow.state = .off
		menuSensitivityMedium.state = .off
		menuSensitivityHigh.state = .off
		switch item.identifier {
			case menuSensitivityLow.identifier:
				menuSensitivityLow.state = .on
				dial?.wheelSensitivity = 1
				settings.sensitivity = .low
			case menuSensitivityMedium.identifier:
				menuSensitivityMedium.state = .on
				dial?.wheelSensitivity = 2
				settings.sensitivity = .medium
			case menuSensitivityHigh.identifier:
				menuSensitivityHigh.state = .on
				dial?.wheelSensitivity = 3
				settings.sensitivity = .high
			default:
				break
		}
	}
	
	@IBAction
	private func rotationClickSelect(item: NSMenuItem) {
		updateRotationClickSetting(newValue: !settings.isRotationClickEnabled)
	}
	
	@IBAction
	private func rotationSelect(item: NSMenuItem) {
		menuWheelRotationCW.state = .off
		menuWheelRotationCCW.state = .off
		switch item.identifier {
			case menuWheelRotationCW.identifier:
				menuWheelRotationCW.state = .on
				dial?.wheelRotation = .clockwise
				settings.wheelRotation = .clockwise
			case menuWheelRotationCCW.identifier:
				menuWheelRotationCCW.state = .on
				dial?.wheelRotation = .anticlockwise
				settings.wheelRotation = .anticlockwise
			default:
				break
		}
	}
	
	@IBAction
	private func directionSelect(item: NSMenuItem) {
		menuScrollDirectionVert.state = .off
		menuScrollDirectionHorz.state = .off
		switch item.identifier {
			case menuScrollDirectionVert.identifier:
				menuScrollDirectionVert.state = .on
				dial?.scrollDirection = .vertical
				settings.scrollDirection = .vertical
			case menuScrollDirectionHorz.identifier:
				menuScrollDirectionHorz.state = .on
				dial?.scrollDirection = .horizontal
				settings.scrollDirection = .horizontal
			default:
				break
		}
	}
	
	private func updateRotationClickSetting(newValue: Bool) {
		settings.isRotationClickEnabled = newValue
		dial?.isRotationClickEnabled = newValue
		menuHaptics.state = newValue ? .on : .off
	}
	
	@IBAction
	private func quitTap(_ item: NSMenuItem) {
		NSApplication.shared.terminate(self)
	}
}
