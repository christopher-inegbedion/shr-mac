//
//  FileDownloadDialogView.swift
//  Shr
//
//  Created by Christopher Inegbedion on 01/03/2023.
//

import Cocoa

class FileDownloadDialogView: NSViewController {
    

    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var notDownloadingLabel: NSTextField!
    
    var allFilesDownloading: [FileDownloading] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        allFilesDownloading = getFilesAlreadyDownloading()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.usesAutomaticRowHeights = true
        tableView.register(NSNib(nibNamed: "UploadProgressNameCell", bundle: nil), forIdentifier: NSUserInterfaceItemIdentifier("UploadProgressNameCell"))
        
        listenForNewDownloads()
        
        for d in allFilesDownloading {
            listenForDownloadEvents(notiTag: d.downloadMessageTag, cmpltTag: d.downloadCompleteTag, cancelTag: d.downloadCancelledTag, errTag: d.downloadErrorTag, fileName: d.name)
        }
    }
    
    func listenForDownloadEvents(notiTag: String, cmpltTag: String, cancelTag: String, errTag: String, fileName: String) {
        // Listen for download messages
        NotificationCenter.default.addObserver(forName: NSNotification.Name(notiTag), object: nil, queue: nil) { nf in
            print("download")
            DispatchQueue.main.async {
                
                let msg = nf.object as! String
                var download: FileDownloading?
                
                var k = 0
                for i in self.allFilesDownloading {
                    if i.downloadMessageTag == notiTag {
                        download = i
                        break
                    }
                    k += 1
                }
                
                if download != nil {
                    download!.message = msg
                    
                    self.allFilesDownloading[k] = download!
                }
                
                self.tableView.reloadData()
            }
        }
        
        // Listen for download complete messages
        NotificationCenter.default.addObserver(forName: NSNotification.Name(cmpltTag), object: nil, queue: nil) { nf in
            DispatchQueue.main.async {
                var download: FileDownloading?
                
                var k = 0
                for i in self.allFilesDownloading {
                    if i.downloadCompleteTag == cmpltTag {
                        download = i
                        break
                    }
                    k += 1
                }

                if download != nil {
                    download!.isComplete = true
                    
                    self.allFilesDownloading[k] = download!
                    self.tableView.reloadData()
                }
                
                
            }
        }
        
        // Listen for download error messages
        NotificationCenter.default.addObserver(forName: NSNotification.Name(errTag), object: nil, queue: nil) { nf in
            DispatchQueue.main.async {
                let err = nf.object as! String
                var download: FileDownloading?
                
                var k = 0
                for i in self.allFilesDownloading {
                    if i.downloadErrorTag == errTag {
                        download = i
                        break
                    }
                    k += 1
                }
                
                if download != nil {
                    download!.message = err
                    download!.hasError = true
                    
                    self.allFilesDownloading[k] = download!
                }
                
                self.tableView.reloadData()
                
            }
        }
        
        // Listen for download cancelled message
        NotificationCenter.default.addObserver(forName: NSNotification.Name(cancelTag), object: nil, queue: nil) { nf in
            DispatchQueue.main.async {
                var download: FileDownloading?
                

                var k = 0
                for i in self.allFilesDownloading {
                    if i.downloadCancelledTag == cancelTag {
                        download = i
                        break
                    }
                    k += 1
                }
                
                if download != nil {
                    download!.isCancelled = true
                    self.allFilesDownloading.remove(at: k)
                    
                    DownloadManager.shared.removeDownloadFromUserDefaults(fileName: fileName)
                    DownloadManager.shared.removeDownloadFromCurrentDownloads(fileName: fileName)
                    
                    self.tableView.removeRows(at: IndexSet(integer: k), withAnimation: .effectFade)
                    
                    // These are the files that did not complete downloading
                    let allStoredDownloads = self.getFilesAlreadyDownloading()
                    
                    // Show the empty table label if no more downloads
                    if allStoredDownloads.count == 0 && self.notDownloadingLabel.isHidden {
                        NSAnimationContext.runAnimationGroup({ context in
                            context.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
                            self.notDownloadingLabel.animator().isHidden = false
                        })
                    }
                    
                }
                
//                DownloadManager.shared.removeDownloadFromUserDefaults(fileName: downloadObj.fileName)
            }
        }
    }
    
    func listenForNewDownloads() {
        // Listen for a new download starting
        NotificationCenter.default.addObserver(forName: NSNotification.Name("Download start"), object: nil, queue: nil) { notification in
            DispatchQueue.main.async {
                let downloadTag = notification.object as! String
                
                let downloadObj = DownloadManager.shared.getDownloadByTag(downloadTag: downloadTag)
                
                guard downloadObj != nil else { return }
                
                // Listen for download messages
                self.listenForDownloadEvents(notiTag: downloadObj!.downloadNotificationTag, cmpltTag: downloadObj!.downloadCompleteTag, cancelTag: downloadObj!.downloadCancelledTag, errTag: downloadObj!.downloadErrorTag, fileName: downloadObj!.fileName)
                
                self.tableView.reloadData()
            }
        }
        
//        for download in allFilesDownloading {
//            let downloadObj = DownloadManager.shared.getDownloadByTag(downloadTag: download.downloadNotificationTag)
//
//            if downloadObj != nil {
//                // Listen for download messages
//                self.listenForDownloadEvents(notiTag: downloadObj!.downloadNotificationTag, cmpltTag: downloadObj!.downloadCompleteTag, cancelTag: downloadObj!.downloadCancelledTag, errTag: downloadObj!.downloadErrorTag, fileName: downloadObj!.fileName)
//
//            }
//        }
        
    }
    
    func getFilesAlreadyDownloading() -> [FileDownloading] {
        let currentlyDownloading = DownloadManager.shared.currentDownloads
        let downloading = UserDefaults.standard.dictionary(forKey: Constants.NEW_DOWNLOAD_USERDEFAULTS) ?? [:]
        
        var result: [FileDownloading] = []
        for (_, v) in downloading {
            let fileDownloading = Common.convertDictionaryToObject(from: v as! [String:Any], to: FileDownloading.self)
            var j = fileDownloading.0
            let err = fileDownloading.1
            
            guard err == nil else {
                continue
            }
            
            j!.isCurrentlyDownloading = currentlyDownloading.contains(where: { download in
                return download.fileName == j?.name
            })
            
            result.append(j!)
        }
        
        if result.count > 0 && !notDownloadingLabel.isHidden {
            notDownloadingLabel.isHidden = true
        }
        
        return result
    }
    
    @IBAction func dismiss(_ sender: NSButton) {
        self.dismiss(self)
    }
}

extension FileDownloadDialogView: NSTableViewDelegate, NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return allFilesDownloading.count
    }
    
//    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
//        return 80
//    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let fileDownloading = allFilesDownloading[row]
        guard let identifier = tableColumn?.identifier else {
            return nil
        }
        
        if identifier == NSUserInterfaceItemIdentifier(rawValue: "nameColumn") {
            guard let cellView = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier("test"), owner: self) as? UploadProgressNameCell else {
                return nil
            }
            
            
            cellView.closeAction = {
                DownloadManager.shared.cancelDownload(downloadTag: fileDownloading.downloadNotificationTag, cancelTag: fileDownloading.downloadCancelledTag, fileName: fileDownloading.name)
            }
            cellView.fileNameLabel.stringValue = fileDownloading.name
            cellView.progressMessageLabel.stringValue = fileDownloading.message
            
            if fileDownloading.hasError {
                cellView.progressMessageLabel.textColor = .red
            }
            
            if fileDownloading.isComplete {
                cellView.progressMessageLabel.stringValue = "✓ Download Complete"
                cellView.progressMessageLabel.textColor = .systemGreen
                cellView.actionButton.isHidden = false
                cellView.actionButtonAction = {
                    let folderURL = URL(fileURLWithPath: "/Users/chrisineg/Downloads/shr")
                    NSWorkspace.shared.open(folderURL)
                }
            } else {
                if !fileDownloading.isCurrentlyDownloading {
                    cellView.progressMessageLabel.stringValue = "Not downloading"
                    cellView.progressMessageLabel.textColor = .systemGray
                }
            }
            return cellView
        } else {
            return nil
        }
    }
}

struct FileDownloading: Codable {
    var name: String
    var progress: CGFloat
    var message: String
    var hasError: Bool
    var isComplete: Bool
    var isCurrentlyDownloading: Bool
    var isCancelled: Bool = false
    var downloadNotificationTag: String {
        "\(name)-download"
    }
    var downloadProgressTag: String {
        "\(name)-progress"
    }
    var downloadMessageTag: String {
        "\(name)-message"
    }
    var downloadCompleteTag: String {
        "\(name)-complete"
    }
    var downloadErrorTag: String {
        "\(name)-error"
    }
    var downloadCancelledTag: String {
        "\(name)-cancelled"
    }
}
