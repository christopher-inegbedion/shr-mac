//
//  UploadFileView.swift
//  Shr
//
//  Created by Christopher Inegbedion on 22/02/2023.
//

import Cocoa

class UploadFileView: NSViewController {

    @IBOutlet weak var cancelButton: NSButton!
    @IBOutlet weak var uploadButton: NSButton!
    
    @IBOutlet weak var fileUploadingLabel: NSTextField!
    @IBOutlet weak var fileUploadingSizeLabel: NSTextField!
    var fileUploadingPath: String = ""
    var fileUploadingName: String = ""
    var fileUploadingSize: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.fileUploadingLabel.stringValue = "Upload '\(fileUploadingName)'"
        self.fileUploadingSizeLabel.stringValue = Common.convertBytesToString(fileUploadingSize)
    }
    
    func setFileUploadingDetails(path: String, name: String, size: Int) {
        self.fileUploadingPath = path
        self.fileUploadingName = name
        self.fileUploadingSize = size
    }
    
    @IBAction func uploadButton(_ sender: NSButton) {
        self.dismiss(self)
        
        _ = UploadManager.shared.startUpload(blockVisible: true, filePath: fileUploadingPath, fileName: fileUploadingName)
    }
    
    @IBAction func cancelButton(_ sender: NSButton) {
        self.dismiss(self)
    }
}
