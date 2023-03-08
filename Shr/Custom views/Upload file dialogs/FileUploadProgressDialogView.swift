//
//  FileUploadProgressDialogView.swift
//  Shr
//
//  Created by Christopher Inegbedion on 27/02/2023.
//

import Cocoa

class FileUploadProgressDialogView: NSViewController {

    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var noUploadLabel: NSTextField!
    
    var allFilesUploading: [FileUploading] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        allFilesUploading = getFilesAlreadyUploading()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.usesAutomaticRowHeights = true
        tableView.register(NSNib(nibNamed: "UploadProgressNameCell", bundle: nil), forIdentifier: NSUserInterfaceItemIdentifier("UploadProgressNameCell"))

        listenForNewUploads()
        
        for u in allFilesUploading {
            listenForUploadEvents(notiTag: u.uploadMessageTag, cmpltTag: u.uploadCompleteTag, cancelTag: u.uploadCancelledTag, errTag: u.uploadErrorTag, fileName: u.name)
        }
    }
    
    func listenForUploadEvents(notiTag: String, cmpltTag: String, cancelTag: String, errTag: String, fileName: String) {
        
        // Listen for download messages
        NotificationCenter.default.addObserver(forName: NSNotification.Name(notiTag), object: nil, queue: nil) { nf in
            DispatchQueue.main.async {
                
                let msg = nf.object as! String
                var upload: FileUploading?
                
                var k = 0
                for i in self.allFilesUploading {
                    if i.uploadMessageTag == notiTag {
                        upload = i
                        break
                    }
                    k += 1
                }
                
                if upload != nil {
                    upload!.message = msg
                    
                    self.allFilesUploading[k] = upload!
                }
                
                self.tableView.reloadData()
            }
        }
        
        // Listen for download complete messages
        NotificationCenter.default.addObserver(forName: NSNotification.Name(cmpltTag), object: nil, queue: nil) { nf in
            DispatchQueue.main.async {
                var upload: FileUploading?

                var k = 0
                for i in self.allFilesUploading {
                    if i.uploadCompleteTag == cmpltTag {
                        upload = i
                        break
                    }
                    k += 1
                }
                
                if upload != nil {
                    upload!.isComplete = true
                    
                    self.allFilesUploading[k] = upload!
                }
                
                self.tableView.reloadData()
                
            }
        }
        
        // Listen for download error messages
        NotificationCenter.default.addObserver(forName: NSNotification.Name(errTag), object: nil, queue: nil) { nf in
            
            DispatchQueue.main.async {
                let err = nf.object as! String
                var upload: FileUploading?

                print("all", self.allFilesUploading)
                var k = 0
                for i in self.allFilesUploading {
                    
                    if i.uploadErrorTag == errTag {
                        upload = i
                        break
                    }
                    k += 1
                }
                
                if upload != nil {
                    upload!.message = err
                    upload!.hasError = true
                    
                    self.allFilesUploading[k] = upload!
                }
                
                self.tableView.reloadData()
                
            }
        }
        
        // Listen for download cancelled message
        NotificationCenter.default.addObserver(forName: NSNotification.Name(cancelTag), object: nil, queue: nil) { nf in
            DispatchQueue.main.async {
                var upload: FileUploading?
                
                var k = 0
                for i in self.allFilesUploading {
                    if i.uploadCancelledTag == cancelTag {
                        upload = i
                        break
                    }
                    k += 1
                }
                
                if upload != nil {
                    upload!.isCancelled = true
                    self.allFilesUploading.remove(at: k)
                    
                    
                    UploadManager.shared.removeUploadFromUserDefaults(fileName: fileName)
                    UploadManager.shared.removeUploadFromCurrentUploads(fileName: fileName)
                    
                    self.tableView.removeRows(at: IndexSet(integer: k), withAnimation: .effectFade)
                    
                    // These are the files that did not complete downloading
                    let allStoredUploads = self.getFilesAlreadyUploading()
                    
                    // Show the empty table label if no more downloads
                    if allStoredUploads.count == 0 && self.noUploadLabel.isHidden {
                        NSAnimationContext.runAnimationGroup({ context in
                            context.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
                            self.noUploadLabel.animator().isHidden = false
                        })
                    }
                    
                }
                
                //                DownloadManager.shared.removeDownloadFromUserDefaults(fileName: downloadObj.fileName)
            }
        }
    }
    
    func listenForNewUploads() {
        // Listen for a new upload starting
        NotificationCenter.default.addObserver(forName: NSNotification.Name("Upload start"), object: nil, queue: nil) { notification in
            DispatchQueue.main.async {
                let uploadTag = notification.object as! String
                let uploadObj = UploadManager.shared.getUploadByTag(uploadTag: uploadTag)
                
                guard uploadObj != nil else { return }
                
                // Listen for upload messages
                self.listenForUploadEvents(notiTag: uploadObj!.notificationTag, cmpltTag: uploadObj!.completeTag, cancelTag: uploadObj!.cancelledTag, errTag: uploadObj!.errorTag, fileName: uploadObj!.fileName)
                print("uploadObj?.errorTag")
                self.tableView.reloadData()
            }
        }
    }
    
    func getFilesAlreadyUploading() -> [FileUploading] {
        let currentlyUploading = UploadManager.shared.currentUploads
        let uploading = UserDefaults.standard.dictionary(forKey: Constants.NEW_UPLOAD_USERDEFAULTS) ?? [:]
        
        var result: [FileUploading] = []
        for (_, v) in uploading {
            let fileUploading = Common.convertDictionaryToObject(from: v as! [String:Any], to: FileUploading.self)
            var j = fileUploading.0
            let err = fileUploading.1
            
            guard err == nil else {
                print(err!)
                continue
            }
            
            
            j!.isCurrentlyUploading = currentlyUploading.contains(where: { upload in
                return upload.fileName == j?.name
            })
            
            result.append(j!)
        }
        
        if result.count > 0 && !noUploadLabel.isHidden {
            noUploadLabel.isHidden = true
        }
        
        return result
    }
    
    @IBAction func dismiss(_ sender: NSButton) {
        self.dismiss(self)
    }
}

extension FileUploadProgressDialogView: NSTableViewDelegate, NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return allFilesUploading.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let fileUploading = allFilesUploading[row]
        guard let identifier = tableColumn?.identifier else {
            return nil
        }
        
        if identifier == NSUserInterfaceItemIdentifier(rawValue: "nameColumn") {
            guard let cellView = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier("test"), owner: self) as? UploadProgressNameCell else {
                return nil
            }
            
            cellView.closeAction = {
                UploadManager.shared.cancelUpload(cancelTag: fileUploading.uploadCancelledTag, fileName: fileUploading.name)
            }
            cellView.fileNameLabel.stringValue = fileUploading.name
            cellView.progressMessageLabel.stringValue = fileUploading.message
            
            if fileUploading.hasError {
                cellView.progressMessageLabel.textColor = .red
            }
            
            if fileUploading.isComplete {
                cellView.progressMessageLabel.stringValue = "✓ Upload Complete"
                cellView.progressMessageLabel.textColor = .systemGreen
            } else {
                if !fileUploading.isCurrentlyUploading {
                    cellView.progressMessageLabel.stringValue = "Not uploading"
                    cellView.progressMessageLabel.textColor = .systemGray
                }
            }
            
            return cellView
        } else {
            return nil
        }
    }
}

struct FileUploading: Codable {
    var name: String
    var progress: CGFloat
    var message: String
    var hasError: Bool
    var isComplete: Bool
    var isCurrentlyUploading: Bool
    var isCancelled: Bool = false
    var uploadNotificationTag: String {
        "\(name)-notification"
    }
    var uploadProgressTag: String {
        "\(name)-progress"
    }
    var uploadMessageTag: String {
        "\(name)-message"
    }
    var uploadCompleteTag: String {
        "\(name)-complete"
    }
    var uploadErrorTag: String {
        "\(name)-error"
    }
    var uploadCancelledTag: String {
        "\(name)-cancelled"
    }
}
