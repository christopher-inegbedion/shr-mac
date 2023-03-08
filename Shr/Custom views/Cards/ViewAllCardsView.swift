//
//  ViewAllCardsView.swift
//  Shr
//
//  Created by Christopher Inegbedion on 24/02/2023.
//

import Cocoa

class ViewAllCardsView: NSView {
    @IBOutlet var contentView: NSView!
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var headerView: NSTableHeaderView!
    
    var blocks: [Block] = []
    var parentView: CardCollectionView!
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        contentView.frame.size = self.frame.size
    }
    
    func setParentView(parentView: CardCollectionView) {
        self.parentView = parentView
    }
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        initialise()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initialise()
    }
    
    private func initialise() {
        Bundle.main.loadNibNamed("ViewAllCardsView", owner: self, topLevelObjects: nil)
        
        addSubview(contentView)
        
        self.loadBlocksIntoTable()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsColumnReordering = false
    }
    
    func loadBlocksIntoTable() {
        DaemonHandler.getAllBlocks { [self] blocks in
            guard let allBlocks = blocks else { return }
            self.blocks = allBlocks
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        } errorCallback: { err in
            print(err)
        }
        
    }
    
    func isInteractionEnabled(_ val: Bool) {
        self.tableView.isEnabled = val
    }
    
}

extension ViewAllCardsView: NSTableViewDelegate, NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return blocks.count
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        let block = blocks[row]
        
        DispatchQueue.main.asyncAfter(deadline: .now()+0.125) {
            self.parentView.showCard(type: .file, data: block)
            RecentBlocksHandler.shared.addBlockToRecents(block: block)
        }
        return true
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let dataForRow = blocks[row]
        
        switch tableColumn!.identifier {
            case NSUserInterfaceItemIdentifier(rawValue: "nameColumn"):
                let view: NSTableCellView = self.tableView.makeView(withIdentifier: tableColumn!.identifier, owner: self)! as! NSTableCellView
                
                view.imageView?.image = NSImage(systemSymbolName: "doc.fill", accessibilityDescription: nil)
                view.textField?.stringValue = dataForRow.FileName
                
                return view
                
            // date uploaded column
            case NSUserInterfaceItemIdentifier(rawValue: "dateUploadedColumn"):
                let view = self.tableView.makeView(withIdentifier: tableColumn!.identifier, owner: self)! as! NSTableCellView
                
                view.textField!.font = NSFont(name: "BasisGrotesqueMonoPro-Regular", size: 10)
                view.textField?.textColor = .lightGray
                view.textField?.stringValue = Common.convertUnixTimestampToStringDate(Double(dataForRow.CreationTime))
                return view
                
            // size column
            case NSUserInterfaceItemIdentifier(rawValue: "sizeColumn"):
                let view = self.tableView.makeView(withIdentifier: tableColumn!.identifier, owner: self)! as! NSTableCellView
                view.textField!.font = NSFont(name: "BasisGrotesqueMonoPro-Regular", size: 10)
                view.textField?.textColor = .lightGray
                view.textField?.stringValue = Common.convertBytesToString(dataForRow.UBlock.FileSizeBytes)
                return view
                
            // kind column
            case NSUserInterfaceItemIdentifier(rawValue: "kindColumn"):
                let view = self.tableView.makeView(withIdentifier: tableColumn!.identifier, owner: self)! as! NSTableCellView
                
                view.textField!.font = NSFont(name: "BasisGrotesqueMonoPro-Regular", size: 10)
                view.textField?.textColor = .lightGray
                view.textField?.stringValue = "File"
                return view
                
            default:
                return nil
        }
        
    }
}
