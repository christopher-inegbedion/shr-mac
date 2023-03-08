//
//  WebsocketHandler.swift
//  Shr
//
//  Created by Christopher Inegbedion on 23/02/2023.
//

import Foundation

class WebsocketHandler {
    /// Connect to a websocket address and receive the message from the websocket server
    static func connectToAddress(addr: String, onSuccess : @escaping (URLSessionWebSocketTask.Message) -> Void, onError: @escaping (Error) -> Void, timeout: CGFloat = 10.0) {
        guard let url = URL(string: addr) else {
            let error = NSError(domain: "Incorrect URL", code: 0, userInfo: nil)
            onError(error)
            return
        }
        
        let configuration = URLSessionConfiguration.default
        let websocketTask = URLSession(configuration: configuration).webSocketTask(with: url)
        websocketTask.resume()
        
        let timeoutItem = DispatchWorkItem {
            websocketTask.cancel(with: .abnormalClosure, reason: Data("Timeout".utf8))
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + timeout, execute: timeoutItem)
        
        websocketTask.receive { result in
            timeoutItem.cancel()
            switch result {
                case .success(let message):
                    onSuccess(message)
                    
                case .failure(let error):
                    onError(error)
            }
        }
    }
    
    /// Connect to a websocket address and receive the JSON data
    static func connectToAddress(addr: String, onSuccessJSONResult : @escaping (Any) -> Void, onError: @escaping (Error) -> Void, timeout: CGFloat = 20.0) {
        
        guard let url = URL(string: addr) else {
            let error = NSError(domain: "Incorrect URL", code: 0, userInfo: nil)
            onError(error)
            return
        }
        
        let websocketTask = URLSession.shared.webSocketTask(with: url)
        websocketTask.resume()
        //        sleep(UInt32(0.5))
        
        let timeoutItem = DispatchWorkItem {
            print("Websocket timeout for address: \(addr)")
            websocketTask.cancel(with: .abnormalClosure, reason: Data("Timeout".utf8))
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + timeout, execute: timeoutItem)
        
        websocketTask.receive { result in
            timeoutItem.cancel()
            
            switch result {
                case .success(let message):
                    switch message {
                        case .string(let text):
                            if let jsonData = text.data(using: .utf8) {
                                do {
                                    let jsonObject = try JSONSerialization.jsonObject(with: jsonData)
                                    onSuccessJSONResult(jsonObject)
                                    websocketTask.cancel()
                                } catch {
                                    onError(error)
                                }
                            }
                               
                        case .data(_):
                            break
                            //                        print("data", data)
                        @unknown default:
                            break
                    }
                    
                case .failure(let error):
                    onError(error)
            }
        }
        
    }
    
    static func sendMessage(addr: String, d: [String], onSuccessDaemonResponse: @escaping (DaemonResponse) -> Bool, onError: @escaping (Error) -> Void) {
        guard let url = URL(string: addr) else {
            let error = NSError(domain: "Incorrect URL", code: 0, userInfo: nil)
            onError(error)
            return
        }
        
        let websocketTask = URLSession.shared.webSocketTask(with: url)
        
        let message = URLSessionWebSocketTask.Message.string(d.description)
        websocketTask.send(message) { err in
            guard err == nil else {
                onError(err!)
                return
            }
        }
        
        websocketTask.resume()
        receiveMessages(from: websocketTask, onSuccess: onSuccessDaemonResponse, onError: onError)
    }
    
    static func receiveMessages(from websocketTask: URLSessionWebSocketTask, onSuccess: @escaping (DaemonResponse) -> Bool, onError: @escaping (Error) -> Void) {
        websocketTask.receive { result in
            switch result {
                case .success(let message):
                    switch message {
                        case .string(let data):
//                            print("Received message: \(data)")
                            if let jsonData = data.data(using: .utf8),
                               let jsonObject = try? JSONSerialization.jsonObject(with: jsonData),
                               let dict = jsonObject as? [String: Any],
                               let response = Common.convertDictionaryToObject(from: dict, to: DaemonResponse.self).0 {
                                if onSuccess(response) {
                                    // If onSuccess returns true, we're done receiving messages.
                                    websocketTask.cancel(with: .normalClosure, reason: nil)
                                    return
                                }
                            }
                            // If we're not done, call the recursive function again to receive the next message.
                            receiveMessages(from: websocketTask, onSuccess: onSuccess, onError: onError)
                        case .data(_):
                            // Handle binary data if needed
                            print("Received binary data")
                            websocketTask.cancel(with: .normalClosure, reason: nil)
                        @unknown default:
                            // Handle unknown message types
                            print("Received unknown message type")
                            websocketTask.cancel(with: .normalClosure, reason: nil)
                    }
                case .failure(let error):
                    onError(error)
            }
        }
    }

}
