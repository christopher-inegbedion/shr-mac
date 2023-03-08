//
//  CompactButton.swift
//  Shr
//
//  Created by Christopher Inegbedion on 17/02/2023.
//

import Cocoa

class ContractButton: NSButton {
    @IBInspectable var buttonTitle: String! = ""
    @IBInspectable var indicatorNumber: NSInteger = 0
    
    func initialise() {
        // Title
        let styledString = NSMutableAttributedString(string: "\(buttonTitle!)   \(indicatorNumber)")
        let indicatorRange = NSString(string: styledString.string).range(of: indicatorNumber.description)
        
        styledString.addAttributes([.font: NSFont.systemFont(ofSize: 12, weight: .bold)], range: indicatorRange)
        self.attributedTitle = styledString
        
        // Background gradient
        self.bezelColor = NSColor(rgb: 0xFF4D00)
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        self.initialise()
    }
    
}
