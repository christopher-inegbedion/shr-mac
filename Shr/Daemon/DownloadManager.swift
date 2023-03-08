//
//  DownloadManager.swift
//  Shr
//
//  Created by Christopher Inegbedion on 27/02/2023.
//

import Foundation

/// This class handles starting downloads, tracking downlad progress, notifying listeners when a download has completed, and other functions related to downloading a file
class DownloadManager {
    private let downloadWSAddr = "ws://localhost:\(Constants.WS_PORT)/command/download_file"
    var currentDownloads: [Download] = []
    
    static let shared = DownloadManager()
    
    private init() {}
    
    func startDownload(fileHash: String, fileName: String) -> Download {
        var newDownload = Download()
        
        newDownload.fileName = fileName
        let worker = { [self] in
            
            WebsocketHandler.sendMessage(addr: downloadWSAddr, d: [fileHash]) { response in
                if !newDownload.alertedListenersOfStart {
                    newDownload.alertedListenersOfStart = true
                    self.alertListenersOfNewDownload(downloadTag: newDownload.downloadNotificationTag, fileName: fileName)
                }
                
                if response.HasError {
                    self.sendDownloadErrorToListeners(errTag: newDownload.downloadErrorTag, fileName: fileName, msg: response.Error)
                    return true
                } else {
                    
                    switch response.Message {
                        case "file saved":
                            self.alertListenersOfDownloadCompletion(compTag: newDownload.downloadCompleteTag, fileName: fileName)
                            return true
                        default:
                            self.sendDownloadMessageToListeners(messageTag: newDownload.downloadMessageTag, msg: response.Message)
                    }
                }
                
                return false
            } onError: { err in
                newDownload.hasError = true
                newDownload.errorMsg = err.localizedDescription
                self.sendDownloadErrorToListeners(errTag: newDownload.downloadErrorTag, fileName: fileName, msg: newDownload.errorMsg)
            }
        }
        
        newDownload.worker = worker
        currentDownloads.append(newDownload)
        
        DispatchQueue.main.async {
            newDownload.worker()
        }
    
        return newDownload
    }
    
    func getDownloadByFilename(fileName: String) -> Download? {
        return currentDownloads.first { download in
            download.fileName == fileName
        }
    }
    
    func getDownloadByTag(downloadTag: String) -> Download? {
        return currentDownloads.first { download in
            download.downloadNotificationTag == downloadTag
        }
    }
    
    private func alertListenersOfNewDownload(downloadTag: String, fileName: String) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "Download start"), object: downloadTag)
        
        let fileDownloading = FileDownloading(name: fileName, progress: 0, message: "", hasError: false, isComplete: false, isCurrentlyDownloading: false)
        let dict = Common.convertObjectToDictionary(from: fileDownloading)
        
        var currentDownloads: [String:Any] = UserDefaults.standard.dictionary(forKey: Constants.NEW_DOWNLOAD_USERDEFAULTS) ?? [:]
        currentDownloads[fileName] = dict
        
        UserDefaults.standard.set(currentDownloads, forKey: Constants.NEW_DOWNLOAD_USERDEFAULTS)
    }
    
    private func sendDownloadMessageToListeners(messageTag: String, msg: String) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: messageTag), object: msg)
    }
    
    private func sendDownloadErrorToListeners(errTag: String, fileName: String, msg: String) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: errTag), object: msg)
//        removeDownloadFromUserDefaults(fileName: fileName)
//        removeDownloadFromCurrentDownloads(fileName: fileName)
    }
    
    private func alertListenersOfDownloadCompletion(compTag: String, fileName: String) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: compTag), object: nil)
        
        removeDownloadFromUserDefaults(fileName: fileName)
        removeDownloadFromCurrentDownloads(fileName: fileName)
    }
    
    private func alertListenersOfDownloadCancelled(cancelTag: String, fileName: String) {
        // TODO: File download isn't actually being cancelled. It's just removed from th list of files being downloaded. FIX IT. The connection to the daemon should be ended before removing the file from view
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: cancelTag), object: fileName)
    }
    
    func removeDownloadFromCurrentDownloads(fileName: String) {
        self.currentDownloads.removeAll { download in
            return download.fileName == fileName
        }
    }
    
    func removeDownloadFromUserDefaults(fileName: String) {
        var currentDownloads: [String:Any] = UserDefaults.standard.dictionary(forKey: Constants.NEW_DOWNLOAD_USERDEFAULTS) ?? [:]
        currentDownloads.removeValue(forKey: fileName)
        UserDefaults.standard.set(currentDownloads, forKey: Constants.NEW_DOWNLOAD_USERDEFAULTS)
    }
    
    func cancelDownload(downloadTag: String, cancelTag: String, fileName: String) {
        
        // File is being downloaded
        alertListenersOfDownloadCancelled(cancelTag: cancelTag, fileName: fileName)
    }
    
    func endDownload() {}
    
    func getAllDownloads() {}
    
    func restoreDownloads() {}
}

class Download {
    var fileName: String = ""
    var worker: () -> Void = {}
    var isDone: Bool = false
    var startTime: Date?
    var endTime: Date?
    var savePath: String?
    var progress: CGFloat = 0
    
    var isCancelled: Bool = false
    
    var alertedListenersOfStart: Bool = false
    
    var downloadNotificationTag: String {
        "\(fileName)-download"
    }
    var downloadProgressTag: String {
        "\(fileName)-progress"
    }
    var downloadMessageTag: String {
        "\(fileName)-message"
    }
    var downloadCompleteTag: String {
        "\(fileName)-complete"
    }
    var downloadErrorTag: String {
        "\(fileName)-error"
    }
    var downloadCancelledTag: String {
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
