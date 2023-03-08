//
//  UploadProgressNameCell.swift
//  Shr
//
//  Created by Christopher Inegbedion on 27/02/2023.
//

import Cocoa

class UploadProgressNameCell: NSTableCellView {

    @IBOutlet weak var iconImageView: NSImageView!
    @IBOutlet weak var fileNameLabel: NSTextField!
    @IBOutlet weak var progressMessageLabel: NSTextField!
    @IBOutlet weak var closeButton: NSButton!
    @IBOutlet var contentView: NSView!
    
    var closeAction: () -> Void = {}
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        Bundle.main.loadNibNamed("UploadProgressNameCell", owner: self, topLevelObjects: nil)
        addSubview(contentView)
    }
    
    @IBAction func closeAction(_ sender: NSButton) {
        closeAction()
    }
}
