//
//  DaemonHandler.swift
//  Shr
//
//  Created by Christopher Inegbedion on 24/02/2023.
//

import Foundation

class DaemonHandler {
    static func getAllBlocks(successCallback: @escaping ([Block]?) -> Void, errorCallback: @escaping (Error) -> Void) {
        WebsocketHandler.connectToAddress(addr: "ws://localhost:\(Constants.WS_PORT)/command/vab") { data in
            guard let i = data as? [String:Any] else {
                let err = NSError(domain: "Could not cast data to [String:Any]", code: 0)
                errorCallback(err)
                return
            }
            
            guard let daemonResponse = Common.convertDictionaryToObject(from: i, to: DaemonResponse.self).0 else {
                let err = NSError(domain: "Could not convert dictionary to DaemonResponse", code: 0)
                errorCallback(err)
                return
            }
            
            guard let blocks = Common.decodeBase64ToObject(from: daemonResponse.Value!, to: [Block].self, isFromDaemon: true) else {
                let err = NSError(domain: "Could not decode Base64 string to [Block]", code: 0)
                errorCallback(err)
                return
            }
            
            successCallback(blocks)
        } onError: { err in
            errorCallback(err)
        }
    }
}
