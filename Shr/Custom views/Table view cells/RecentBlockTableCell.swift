//
//  RecentBlockTableCell.swift
//  Shr
//
//  Created by Christopher Inegbedion on 08/03/2023.
//

import Cocoa

class RecentBlockTableCell: NSTableCellView {

    @IBOutlet var contentView: NSView!
    @IBOutlet weak var button: NSButton!
    
    var action: () -> Void = {}
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        Bundle.main.loadNibNamed("RecentBlockTableCell", owner: self, topLevelObjects: nil)
        
        addSubview(contentView)
        
        contentView.frame.size = self.frame.size
    }
    
    @IBAction func buttonAction(_ sender: NSButton) {
        self.action()
    }
    
}
