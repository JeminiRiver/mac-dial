//
// AppDelegate
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
import SwiftUI

let logsEnabled: Bool = true

#if DEBUG
func log(tag: String, _ message: @autoclosure () -> String) {
    guard logsEnabled else { return }

    print("\(Date()) [\(tag)] \(message())")
}
#else
func log(tag: String, _ message: @autoclosure () -> String) {
}
#endif

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    @IBOutlet private var controller: AppController!
    
	private var statusItem: NSStatusItem
	
	override init() {
		statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
		super.init()
	}
	
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        //check if the process is trusted for accessibility. This is important for us to listen for keyboard events system wide.
        let checkOptPrompt = kAXTrustedCheckOptionPrompt.takeUnretainedValue() as NSString
        
        let options = [checkOptPrompt: true]
        let isAppTrusted = AXIsProcessTrustedWithOptions(options as CFDictionary?);
        log(tag: "Accessibility", "Accessibility access [\(isAppTrusted)]");
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            _ = DialZoomControl().rotationChanged(.clockwise(5), .vertical)
        }
		
		buildStatusMenu()
    }
	
	func buildStatusMenu() {
		// SwiftUI content view & a hosting view
		// Don't forget to set the frame, otherwise it won't be shown.
		//
		let contentViewSwiftUI = VStack {
			Color.blue
			Text("Test Text")
			Color.white
		}
		let contentView = NSHostingView(rootView: contentViewSwiftUI)
		contentView.frame = NSRect(x: 0, y: 0, width: 200, height: 200)
		
		// Status bar icon SwiftUI view & a hosting view.
		let iconSwiftUI = ZStack(alignment:.center) {
			Rectangle()
				.fill(Color.green)
				.cornerRadius(5)
				.padding(2)
			
			Text("3")
				.background(
					Circle()
						.fill(Color.blue)
						.frame(width: 15, height: 15)
				)
				.frame(maxWidth: .infinity, maxHeight: .infinity,  alignment: .bottomTrailing)
				.padding(.trailing, 5)
		}
		let iconView = NSHostingView(rootView: iconSwiftUI)
		iconView.frame = NSRect(x: 0, y: 0, width: 40, height: 22)
		
		// Creating a menu item & the menu to add them later into the status bar
		//
		let menuItem = NSMenuItem()
		menuItem.view = contentView
		let menu = NSMenu()
		menu.addItem(menuItem)
		
		// Adding content view to the status bar
		//
		let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
		statusItem.menu = menu
		
		// Adding the status bar icon
		//
		statusItem.button?.addSubview(iconView)
		statusItem.button?.frame = iconView.frame
		
		// StatusItem is stored as a property.
		self.statusItem = statusItem
	}
    
    func applicationWillTerminate(_ aNotification: Notification) {
        controller.terminate()
    }
}
