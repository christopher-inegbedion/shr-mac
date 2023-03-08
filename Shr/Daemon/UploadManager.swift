//
//  UploadManager.swift
//  Shr
//
//  Created by Christopher Inegbedion on 03/03/2023.
//

import Foundation

/// This class handles uploading files, tracking upload progress, notifying listeners when an upload has completed, and other functions related to uploading a file
class UploadManager {
    private let uploadWSAddr =  "ws://localhost:\(Constants.WS_PORT)/command/upload_file"
    var currentUploads: [Upload] = []
    
    static let shared = UploadManager()
    
    private init() {}
    
    func startUpload(blockVisible: Bool,filePath: String, fileName: String) -> Upload {
        var newUpload = Upload()
        
        newUpload.fileName = fileName
        let worker = { [self] in
            WebsocketHandler.sendMessage(addr: uploadWSAddr, d: [blockVisible.description, filePath]) { response in
                if !newUpload.alertListenersOfStart {
                    newUpload.alertListenersOfStart = true
                    self.alertListenersOfNewUpload(notiTag: newUpload.notificationTag, fileName: fileName)
                }
                
                // This delay is mostly for errors. If an immediately, it is possible for the upload dialog to come into display quick enough to handle the error. So we just add a fake pause to let the dialog be ready before listening for events from the daemon
                sleep(1)
                
                if response.HasError {
                    self.sendUploadErrorToListeners(errTag: newUpload.errorTag, fileName: fileName, msg: response.Error)
                    return true
                } else {
                    switch response.Message {
                        case "block created":
                            self.alertListenersOfUploadCompletion(compTag: newUpload.completeTag, fileName: fileName)
                            return true
                        default:
                            self.sendUploadMessageToListeners(messageTag: newUpload.messageTag, msg: response.Message)
                    }
                }
                
                return false
            } onError: { err in
                newUpload.hasError = true
                newUpload.errorMsg = err.localizedDescription
                self.sendUploadErrorToListeners(errTag: newUpload.errorTag, fileName: fileName, msg: newUpload.errorMsg)
            }
            
        }
        
        newUpload.worker = worker
        currentUploads.append(newUpload)
        
        DispatchQueue.main.async {
            newUpload.worker()
        }
        
        return newUpload
    }
    
    func getUploadByTag(uploadTag: String) -> Upload? {
        return currentUploads.first { upload in
            upload.notificationTag == uploadTag
        }
    }
    
    private func alertListenersOfNewUpload(notiTag: String, fileName: String) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "Upload start"), object: notiTag)
        
        let fileUploading = FileUploading(name: fileName, progress: 0, message: "", hasError: false, isComplete: false, isCurrentlyUploading: false)
        let dict = Common.convertObjectToDictionary(from: fileUploading)
        
        var currentUploads: [String:Any] = UserDefaults.standard.dictionary(forKey: Constants.NEW_UPLOAD_USERDEFAULTS) ?? [:]
        currentUploads[fileName] = dict
        
        UserDefaults.standard.set(currentUploads, forKey: Constants.NEW_UPLOAD_USERDEFAULTS)
    }
    
    private func sendUploadMessageToListeners(messageTag: String, msg: String) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: messageTag), object: msg)
    }
    
    private func sendUploadErrorToListeners(errTag: String, fileName: String, msg: String) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: errTag), object: msg)
        print("all", errTag)
    }
    
    private func alertListenersOfUploadCompletion(compTag: String, fileName: String) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: compTag), object: nil)
        
        removeUploadFromUserDefaults(fileName: fileName)
        removeUploadFromCurrentUploads(fileName: fileName)
    }
    
    private func alertListenersOfUploadCancelled(cancelTag: String, fileName: String) {
        // TODO: File download isn't actually being cancelled. It's just removed from th list of files being downloaded. FIX IT. The connection to the daemon should be ended before removing the file from view
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: cancelTag), object: fileName)
    }
    
    func removeUploadFromCurrentUploads(fileName: String) {
        self.currentUploads.removeAll { upload in
            return upload.fileName == fileName
        }
    }
    
    func removeUploadFromUserDefaults(fileName: String) {
        var currentUploads: [String:Any] = UserDefaults.standard.dictionary(forKey: Constants.NEW_UPLOAD_USERDEFAULTS) ?? [:]
        currentUploads.removeValue(forKey: fileName)
        UserDefaults.standard.set(currentUploads, forKey: Constants.NEW_UPLOAD_USERDEFAULTS)
    }
    
    func cancelUpload(cancelTag: String, fileName: String) {
        // File is being downloaded
        alertListenersOfUploadCancelled(cancelTag: cancelTag, fileName: fileName)
    }
}

class Upload {
    var fileName: String = ""
    var worker: () -> Void = {}
    var isDone: Bool = false
    var startTime: Date?
    var endTime: Date?
    var progress: CGFloat = 0
    
    var isCancelled: Bool = false
    var alertListenersOfStart: Bool = false
    var notificationTag: String {
        "\(fileName)-notification"
    }
    var progressTag: String {
        "\(fileName)-progress"
    }
    var messageTag: String {
        "\(fileName)-message"
    }
    var completeTag: String {
        "\(fileName)-complete"
    }
    var errorTag: String {
        "\(fileName)-error"
    }
    var cancelledTag: String {
        "\(fileName)-cancelled"
    }
    
    var hasError: Bool = false {
        didSet {
            isDone = true
        }
    }
    var errorMsg: String = ""
    
    init() {}
}
