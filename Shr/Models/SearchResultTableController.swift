//
//  SearchResultTableController.swift
//  Shr
//
//  Created by Christopher Inegbedion on 04/03/2023.
//

import Cocoa

class SearchResultTableController: NSObject, NSTableViewDelegate, NSTableViewDataSource {
    var parent: HomePage!
    var searchResults: [SearchResults] = []
    
    init(parent: HomePage, results: [SearchResults]) {
        self.parent = parent
        self.searchResults = results
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return searchResults.count
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        let result = searchResults[row]
        
        if result.resultType == .block {
            let block = result.data as! Block
            self.searchResults = []
            
            parent.hideAndClearSearchBar()
            parent.cardCollectionsView.showCard(type: .file, data: block)
        }
        
        return true
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let result = searchResults[row]
        guard let identifier = tableColumn?.identifier else {
            return nil
        }
        
        if identifier == NSUserInterfaceItemIdentifier(rawValue: "resultColumn") {
            guard let cellView = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier("searchCell"), owner: self) as? SearchResultTableCell else {
                return nil
            }
            
            if result.resultType == .block {
                let block = result.data as! Block
                cellView.iconImageView.image = NSImage(systemSymbolName: "doc", accessibilityDescription: nil)
                cellView.resultName.stringValue = block.FileName
                cellView.resultSubName.stringValue = Common.convertBytesToString(block.UBlock.FileSizeBytes)
                cellView.resultExtraLabel.stringValue = ""
                
                return cellView
            }
        }
        
        return nil
    }
}
