//
//  DevToolsDialog.swift
//  Shr
//
//  Created by Christopher Inegbedion on 10/03/2023.
//

import Cocoa

class DevToolsDialog: NSViewController {
    
    @IBOutlet weak var tableView: NSTableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(NSNib(nibNamed: "RecentBlockTableCell", bundle: nil), forIdentifier: NSUserInterfaceItemIdentifier("RecentBlockTableCell"))
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    @IBAction func cancel(_ sender: NSButton) {
        self.dismiss(self)
    }
}

extension DevToolsDialog: NSTableViewDelegate, NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return DevToolItem.items.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        var item: DevToolItem = DevToolItem.items[row]
        
        if tableColumn?.identifier == NSUserInterfaceItemIdentifier(rawValue: "toolButtonCol") {
            guard let cellView = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier("button"), owner: self) as? RecentBlockTableCell else {
                return nil
            }
            
            var labelTitle = ""
            
            cellView.button.title = item.buttonName
            cellView.action = {
                item.buttonAction(DevToolItem.items[row])
                tableView.reloadData()
            }
            
            return cellView
        } else if tableColumn?.identifier == NSUserInterfaceItemIdentifier(rawValue: "toolStringCol") {
            let view = self.tableView.makeView(withIdentifier: tableColumn!.identifier, owner: self)! as! NSTableCellView
            
            view.textField?.stringValue = item.stringValue
            return view
        }
        
        return nil
    }
}
