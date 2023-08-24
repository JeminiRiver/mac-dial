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

    @IBOutlet private var menuButtonControlMode: NSMenuItem!
    @IBOutlet private var menuButtonControlModeLeftClick: NSMenuItem!
    @IBOutlet private var menuButtonControlModePlayback: NSMenuItem!

    @IBOutlet private var menuDialControlMode: NSMenuItem!
    @IBOutlet private var menuDialControlModeScroll: NSMenuItem!
    @IBOutlet private var menuDialControlModeVolume: NSMenuItem!
    @IBOutlet private var menuDialControlModeBrightness: NSMenuItem!
    @IBOutlet private var menuDialControlModeKeyboard: NSMenuItem!
    @IBOutlet private var menuDialControlModeZoom: NSMenuItem!

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
    private var buttonControl: DeviceControl?

    override init() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        super.init()

        dial = Dial(connectionHandler: connected, disconnectionHandler: disconnected)
    }

    override func awakeFromNib() {
        statusItem.menu = statusMenu

        menuButtonControlMode.title = NSLocalizedString("menu.buttonMode", comment: "")
        menuButtonControlModeLeftClick.title = NSLocalizedString("menu.buttonMode.leftClick", comment: "")
        menuButtonControlModePlayback.title = NSLocalizedString("menu.buttonMode.playback", comment: "")

        menuDialControlMode.title = NSLocalizedString("menu.dialMode", comment: "")
        menuDialControlModeScroll.title = NSLocalizedString("menu.dialMode.scroll", comment: "")
        menuDialControlModeZoom.title = NSLocalizedString("menu.dialMode.zoom", comment: "")
        menuDialControlModeVolume.title = NSLocalizedString("menu.dialMode.music", comment: "")
        menuDialControlModeBrightness.title = NSLocalizedString("menu.dialMode.brightness", comment: "")
        menuDialControlModeKeyboard.title = NSLocalizedString("menu.dialMode.keyboard", comment: "")

        // TODO: Does not work for now, so disabling
        //if let menu = menuDialControlModeZoom.menu, let index = menu.items.firstIndex(of: menuDialControlModeZoom) {
        //    menu.items.remove(at: index)
        //}

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
        }
        switch settings.buttonMode {
            case .leftClick:
                buttonModeSelect(item: menuButtonControlModeLeftClick)
            case .playback:
                buttonModeSelect(item: menuButtonControlModePlayback)
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

    private func updateMenuBarItem(from: NSMenuItem) {
        let selectedImage = from.image ?? NSImage(named: "icon-scroll-small")!
        statusItem.button?.image = selectedImage
        statusItem.button?.image?.size = .init(width: 18, height: 18)
        statusItem.button?.imagePosition = .imageLeft
        statusItem.button?.toolTip = from.title
    }

    @IBAction
    private func dialModeSelect(item: NSMenuItem) {
        menuDialControlModeScroll.state = .off
        menuDialControlModeVolume.state = .off
        menuDialControlModeBrightness.state = .off
        menuDialControlModeKeyboard.state = .off
        menuDialControlModeZoom.state = .off
        item.state = .on
        menuDialControlMode.image = item.image
        switch item.identifier {
            //Scroll
            case menuDialControlModeScroll.identifier:
                dialControl = DialScrollControl()
                settings.dialMode = .scrolling
            //Zoom
            case menuDialControlModeZoom.identifier:
                dialControl = DialZoomControl()
                settings.dialMode = .zoom
                break;
            //Volume
            case menuDialControlModeVolume.identifier:
                dialControl = DialKeysUpDownControl(
                    buttonUpKeyCode: NX_KEYTYPE_SOUND_UP,
                    buttonDownKeyCode: NX_KEYTYPE_SOUND_DOWN,
                    modifiers: [ .shift, .option ]
                )
                settings.dialMode = .volume
            //Brightness
            case menuDialControlModeBrightness.identifier:
                dialControl = DialKeysUpDownControl(
                    buttonUpKeyCode: NX_KEYTYPE_BRIGHTNESS_UP,
                    buttonDownKeyCode: NX_KEYTYPE_BRIGHTNESS_DOWN,
                    modifiers: [ .control ],
                    useModifiersWhenExternalDisplayIsMain: true
                )
                settings.dialMode = .brightness
            //Keyboard
            case menuDialControlModeKeyboard.identifier:
                dialControl = DialKeysUpDownControl(
                    buttonUpKeyCode: NX_KEYTYPE_ILLUMINATION_UP,
                    buttonDownKeyCode: NX_KEYTYPE_ILLUMINATION_DOWN
                )
                settings.dialMode = .keyboard
            default:
                break
        }
        dial?.controls = (dialControl.map { [ $0 ] } ?? []) + (buttonControl.map { [ $0 ] } ?? [])
        updateMenuBarItem(from: item)
    }

    @IBAction
    private func buttonModeSelect(item: NSMenuItem) {
        menuButtonControlModeLeftClick.state = .off
        menuButtonControlModePlayback.state = .off
        item.state = .on
        menuButtonControlMode.image = item.image
        switch item.identifier {
            case menuButtonControlModeLeftClick.identifier:
                buttonControl = ButtonPressControl(eventDownType: .leftMouseDown, eventUpType: .leftMouseUp)
                settings.buttonMode = .leftClick
            case menuButtonControlModePlayback.identifier:
                buttonControl = ButtonPlaybackControl()
                settings.buttonMode = .playback
            default:
                break
        }
        dial?.controls = (dialControl.map { [ $0 ] } ?? []) + (buttonControl.map { [ $0 ] } ?? [])
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