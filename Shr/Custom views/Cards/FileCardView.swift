//
//  FileCardView.swift
//  Shr
//
//  Created by Christopher Inegbedion on 21/02/2023.
//

import Cocoa

class FileCardView: NSView {
    @IBOutlet var contentView: NSView!
    
    @IBOutlet weak var fileThumbnail: NSImageView!
    @IBOutlet weak var fileName: NSTextField!
    @IBOutlet weak var fileSize: NSTextField!
    @IBOutlet weak var fileID: NSTextField!
    
    @IBOutlet weak var downloadButton: NSButton!
    @IBOutlet weak var shareButton: NSButton!
    @IBOutlet weak var addToGroupButton: NSButton!
    @IBOutlet weak var createLinkButton: NSButton!
    
    @IBOutlet weak var dateUploadedTitleLabel: NSTextField!
    @IBOutlet weak var dateUploadedLabel: NSTextField!
    
    var block: Block!
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        contentView.frame.size = self.frame.size
    }
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        initialise()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initialise()
    }
    
    func initialise() {
        Bundle.main.loadNibNamed("FileCardView", owner: self, topLevelObjects: nil)
        addSubview(contentView)
    }
    
    func setBlock(block: Block) {
        self.block = block
        
        self.fileName.stringValue = self.block.FileName
        self.fileID.stringValue = self.block.Hash
        self.fileSize.stringValue = Common.convertBytesToString(self.block.UBlock.FileSizeBytes)
        self.dateUploadedLabel.stringValue = Common.convertUnixTimestampToStringDate(Double(self.block.CreationTime))
    }
    
    @IBAction func downloadFileAction(_ sender: NSButton) {
        _ = DownloadManager.shared.startDownload(fileHash: block.Hash, fileName: block.FileName)
    }
    
}

