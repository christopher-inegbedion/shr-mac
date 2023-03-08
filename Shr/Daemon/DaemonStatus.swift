//
//  Common.swift
//  Shr
//
//  Created by Christopher Inegbedion on 23/02/2023.
//

import Foundation
import Cocoa

/// Call methods from this class to get information about the status of the Daemon.
class DaemonStatus {
    private init() {}
    
    static let shared = DaemonStatus()
    
    /// Call to check if the daemon is online. 
    func IsDaemonOnline(resultCallback: @escaping (Bool) -> Void) {
        WebsocketHandler.connectToAddress(addr: "ws://localhost:\(Constants.WS_PORT)/command/va") { data in
            let i = data as! [String:Any]
            
            let result = Common.convertDictionaryToObject(from: i, to: DaemonResponse.self)
            let error = result.1
            let daemonResponse = result.0
            
            if error != nil {
                resultCallback(false)
                return
            }
            
            resultCallback(!daemonResponse!.HasError)
        } onError: { error in
            resultCallback(false)
        }
    }
    
}

func RequestDataFromWSServer(path: String, dataToSend: [String], callback: (Any...) -> Void) {
    
}
