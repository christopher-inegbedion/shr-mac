//
//  DevToolItems.swift
//  Shr
//
//  Created by Christopher Inegbedion on 11/03/2023.
//

import Foundation

class DevToolItem {
    var buttonName: String
    var buttonAction: (DevToolItem) -> Void
    var stringValue: String
    
    init(buttonName: String, buttonAction: @escaping (DevToolItem) -> Void, stringValue: String) {
        self.buttonName = buttonName
        self.buttonAction = buttonAction
        self.stringValue = stringValue
    }
    
    static var items: [DevToolItem] = [
        DevToolItem(buttonName: "Start daemon", buttonAction: { devItem in
            runAppleScript(appleScript: AppleScripts.startDaemon, successMessage: "Daemon started", devItem: devItem)
        }, stringValue: ""),
        DevToolItem(buttonName: "Stop daemon", buttonAction: { devItem in
            runAppleScript(appleScript: AppleScripts.stopDaemon, successMessage: "Daemon stopped", devItem: devItem)
        }, stringValue: ""),
    ]
    
}


func runAppleScript(appleScript: String, successMessage: String, devItem: DevToolItem) {
    // Create an AppleScript instance and compile the script
    var error: NSDictionary?
    let script = NSAppleScript(source: appleScript)
    
    let compiledScript = script?.executeAndReturnError(&error)
    
    // Check for errors in the script compilation
    guard error == nil else {
        print("Error compiling AppleScript: \(error!)")
        devItem.stringValue = error!["NSAppleScriptErrorBriefMessage"] as! String
        return
    }
    
    if compiledScript?.stringValue == "" {
        devItem.stringValue = successMessage
    }
}
