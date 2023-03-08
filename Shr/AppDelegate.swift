//
//  AppDelegate.swift
//  Shr
//
//  Created by Christopher Inegbedion on 13/02/2023.
//

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationDidFinishLaunching(_ aNotification: Notification) {
//        WebsocketHandler.sendMessage(addr: "ws://localhost:\(Constants.WS_PORT)/command/isno", d: ["awsnode1"]) { response in
//            if response.Message == "value" {
//                let value = Common.decodeBase64ToObject(from: response.Value, to: IsUserOnlineModel.self, isFromDaemon: false)
//                print(value?.online)
//                return true
//            } else {
//                return false
//            }
//        } onError: { err in
//            print("error happend")
//            print(err)
////            return true
//        }


    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }


}

