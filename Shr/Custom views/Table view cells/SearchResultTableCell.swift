//
//  SearchResultTableCell.swift
//  Shr
//
//  Created by Christopher Inegbedion on 04/03/2023.
//

import Cocoa

class SearchResultTableCell: NSTableCellView {

    @IBOutlet var contentView: NSView!
    @IBOutlet weak var iconImageView: NSImageView!
    @IBOutlet weak var resultName: NSTextField!
    @IBOutlet weak var resultSubName: NSTextField!
    @IBOutlet weak var resultExtraLabel: NSTextField!
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        Bundle.main.loadNibNamed("SearchResultTableCell", owner: self, topLevelObjects: nil)
        addSubview(contentView)
        
        contentView.frame.size = self.frame.size
        
    }
    
}
