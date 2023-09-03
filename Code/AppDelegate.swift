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
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        controller.terminate()
    }
}
