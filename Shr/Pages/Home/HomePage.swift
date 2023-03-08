//
//  HomePage.swift
//  Shr
//
//  Created by Christopher Inegbedion on 16/02/2023.
//

import Cocoa

class HomePage: NSViewController {
    var userAccount: Account!
    var allBlocks: [Block] = []
    
    @IBOutlet weak var usernameLabel: NSTextField!
    @IBOutlet weak var additionStorageInfoMessageLabel: NSTextField!
    @IBOutlet weak var primaryStorageInfoMessageLabel: NSTextField!
    @IBOutlet weak var topPanelView: NSBox!
    @IBOutlet weak var cardCollectionsView: CardCollectionView!
    @IBOutlet weak var primaryStorageProgressView: NSBox!
    
    @IBOutlet weak var searchFIeld: NSSearchField!
    @IBOutlet weak var searchFieldCenterConstraint: NSLayoutConstraint!
    @IBOutlet weak var primaryStorageWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var viewAllUploadsButton: NSButton!
    @IBOutlet weak var viewAllDownloadsButton: NSButton!
    @IBOutlet weak var uploadFileButton: NSButton!
    
    @IBOutlet weak var searchResultsContainer: NSScrollView!
    @IBOutlet weak var searchResultsTableView: NSTableView!
    
    @IBOutlet weak var recentsSection: NSBox!
    @IBOutlet weak var recentBlocksTableView: NSTableView!
    
    var searchHandler: SearchHandler!
    var searchTableController: SearchResultTableController!
    
    let progressBarWidth = 250
    
    var allFilesDownloading: [FileDownloading] = []
    var allFilesUploading: [FileUploading] = []
    
    var recentBlocksTableController: RecentBlocksTableController!
    override func viewDidLoad() {
        super.viewDidLoad()
        recentBlocksTableController = RecentBlocksTableController(allBlocks: self.allBlocks, cardCollectionView: self.cardCollectionsView)
        recentBlocksTableView.delegate = recentBlocksTableController
        recentBlocksTableView.dataSource = recentBlocksTableController
        
        // Get the vertical scroller of the table view
//        recentBlocksTableView.enclosingScrollView?.horizontalScroller = OpaqueScroller()
        let verticalScroller = recentBlocksTableView.enclosingScrollView?.horizontalScroller
        
        // Set the height of the vertical scroller
        verticalScroller?.controlSize = .small
        verticalScroller?.scrollerStyle = .overlay
        verticalScroller?.knobStyle = .light
        
        verticalScroller?.frame.size.height = 20
        
        recentBlocksTableView.register(NSNib(nibNamed: "RecentBlockTableCell", bundle: nil), forIdentifier: NSUserInterfaceItemIdentifier("RecentBlockTableCell"))

        allFilesDownloading = getFilesAlreadyDownloading()
        allFilesUploading = getFilesAlreadyUploading()
        
        listenForNewUploads()
        listenForNewDownloads()
        listenForRecentBlockEvents()
        
        setupRecentsTable()
        
        cardCollectionsView.delegate = self
        cardCollectionsView.alphaValue = 0
        
        setupAccountDetailsAndStorageView()
        setupSearch()
        
        searchFIeld.delegate = self
        
        self.view.wantsLayer = true
        self.view.layer?.backgroundColor = .white
    }
    
    func listenForRecentBlockEvents() {
        NotificationCenter.default.addObserver(forName: NSNotification.Name("recent-block-added"), object: nil, queue: nil) { notification in
            let allBlocks = RecentBlocksHandler.shared.getRecentBlocks()
            self.displayRecentBlocks()
            
            if allBlocks.count == 1 {
                NSAnimationContext.runAnimationGroup { context in
                    context.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
                    self.recentsSection.alphaValue = 1
                }
            }
            
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name("recent-block-cleared"), object: nil, queue: nil) { notification in
            self.recentBlocksTableController.blocks = []
            self.recentBlocksTableView.delegate = self.recentBlocksTableController
            self.recentBlocksTableView.dataSource = self.recentBlocksTableController
            self.recentBlocksTableView.reloadData()
            
            NSAnimationContext.runAnimationGroup { context in
                context.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
                self.recentsSection.alphaValue = 0
            }
        }
    }
    
    @IBAction func clearRecentsList(_ sender: NSButton) {
        RecentBlocksHandler.shared.clearRecents()
    }
    
    func setupRecentsTable() {
        let allBlocks = RecentBlocksHandler.shared.getRecentBlocks()
        var i = 0
        
        for _ in allBlocks {
            i += 1
            self.recentBlocksTableView.addTableColumn(NSTableColumn(identifier: NSUserInterfaceItemIdentifier(rawValue: i.description)))
        }
        
        displayRecentBlocks()
    }
    
    func displayRecentBlocks() {
        let allBlocks = RecentBlocksHandler.shared.getRecentBlocks()
        self.recentBlocksTableController.blocks = allBlocks
        
        self.recentBlocksTableView.delegate = self.recentBlocksTableController
        self.recentBlocksTableView.dataSource = self.recentBlocksTableController
        self.recentBlocksTableView.reloadData()
        
    }
    
    func listenForNewUploads() {
        // Listen for a new upload starting
        NotificationCenter.default.addObserver(forName: NSNotification.Name("Upload start"), object: nil, queue: nil) { notification in
            let uploadTag = notification.object as! String
            let uploadObj = UploadManager.shared.getUploadByTag(uploadTag: uploadTag)
            
            guard uploadObj != nil else { return }
            
            DispatchQueue.main.async {
                self.showUploadsDialog()
            }
            
            self.listenForUploadEvents(uploadObj: uploadObj!)
        }
    }
    
    func listenForNewDownloads() {
        // Listen for a new download starting
        NotificationCenter.default.addObserver(forName: NSNotification.Name("Download start"), object: nil, queue: nil) { notification in
            
            
            let downloadTag = notification.object as! String
            
            let downloadObj = DownloadManager.shared.getDownloadByTag(downloadTag: downloadTag)
            
            guard downloadObj != nil else { return }
            
            DispatchQueue.main.async {
                self.showDownloadsDialog()
            }
            // Listen for download messages
            self.listenForDownloadEvents(downloadObj: downloadObj!)
        }
    }
    
    func getFilesAlreadyDownloading() -> [FileDownloading] {
        let downloading = UserDefaults.standard.dictionary(forKey: Constants.NEW_DOWNLOAD_USERDEFAULTS) ?? [:]
        
        var result: [FileDownloading] = []
        for (_, v) in downloading {
            let fileDownloading = Common.convertDictionaryToObject(from: v as! [String:Any], to: FileDownloading.self)
            let j = fileDownloading.0
            let err = fileDownloading.1
            
            guard err == nil else {
                continue
                
            }
            
            result.append(j!)
        }
        
        
        return result
    }
    
    func getFilesAlreadyUploading() -> [FileUploading] {
        let uploading = UserDefaults.standard.dictionary(forKey: Constants.NEW_UPLOAD_USERDEFAULTS) ?? [:]
        
        var result: [FileUploading] = []
        for (_, v) in uploading {
            let fileUploading = Common.convertDictionaryToObject(from: v as! [String:Any], to: FileUploading.self)
            let j = fileUploading.0
            let err = fileUploading.1
            
            guard err == nil else {
                continue
            }
            
            result.append(j!)
        }
        
        return result
    }
    
    func listenForDownloadEvents(downloadObj: Download) {
        // Listen for download messages
//        NotificationCenter.default.addObserver(forName: NSNotification.Name(downloadObj.downloadMessageTag), object: nil, queue: nil) { nf in
//            print(downloadObj.downloadMessageTag)
//            DispatchQueue.main.async {
//
//                let msg = nf.object as! String
//                var download: FileDownloading?
//
//                var k = 0
//                for i in self.allFilesDownloading {
//                    if i.downloadMessageTag == downloadObj.downloadMessageTag {
//                        download = i
//                        break
//                    }
//                    k += 1
//                }
//
//                if download != nil {
//                    download!.message = msg
//
//                    self.allFilesDownloading[k] = download!
//                }
//            }
//        }
        
        // Listen for download complete messages
        NotificationCenter.default.addObserver(forName: NSNotification.Name(downloadObj.downloadCompleteTag), object: nil, queue: nil) { nf in
            print(downloadObj.downloadCompleteTag)
            DispatchQueue.main.async {
                var download: FileDownloading?
                
                var k = 0
                for i in self.allFilesDownloading {
                    if i.downloadMessageTag == downloadObj.downloadMessageTag {
                        download = i
                        break
                    }
                    k += 1
                }
                
                if download != nil {
                    download!.isComplete = true
                    
                    self.allFilesDownloading[k] = download!
                    
                    self.viewAllDownloadsButton.title = "\(download!.name) has been downloaded"
                }
                
            }
        }
        
        // Listen for download error messages
//        NotificationCenter.default.addObserver(forName: NSNotification.Name(downloadObj.downloadErrorTag), object: nil, queue: nil) { nf in
//            print(downloadObj.downloadErrorTag)
//            DispatchQueue.main.async {
//                let err = nf.object as! String
//                var download: FileDownloading?
//
//                var k = 0
//                for i in self.allFilesDownloading {
//                    if i.downloadErrorTag == downloadObj.downloadErrorTag {
//                        download = i
//                        break
//                    }
//                    k += 1
//                }
//
//                if download != nil {
//                    download!.message = err
//                    download?.hasError = true
//
//                    self.allFilesDownloading[k] = download!
//
//                    self.viewAllDownloadsButton.title = "An error occured downloading: \(download!.name)"
//                    DispatchQueue.main.asyncAfter(deadline: .now()+2, execute: {
//                        if self.allFilesDownloading.count == 0 {
//                            self.viewAllDownloadsButton.isHidden = true
//                        }
//                    })
//                }
//
//            }
//        }
    }
    
    func listenForUploadEvents(uploadObj: Upload) {
        // Listen for upload complete messages
        NotificationCenter.default.addObserver(forName: NSNotification.Name(uploadObj.completeTag), object: nil, queue: nil) { nf in
            DispatchQueue.main.async {
                var upload: FileUploading?
                
                var k = 0
                for i in self.allFilesUploading {
                    if i.uploadCompleteTag == uploadObj.completeTag {
                        upload = i
                        break
                    }
                    k += 1
                }
                
                if upload != nil {
                    upload!.isComplete = true
                    
                    self.allFilesUploading[k] = upload!
                    
                    self.viewAllUploadsButton.title = "\(upload!.name) has been uploaded"
                }
                
            }
        }
    }
    
    private func showDownloadsDialog() {
        let downloadsDialogView = FileDownloadDialogView(nibName: "FileDownloadDialogView", bundle: nil)
        self.presentAsSheet(downloadsDialogView)
    }
    
    private func showUploadsDialog() {
        let uploadsDialogView = FileUploadProgressDialogView(nibName: "FileUploadProgressDialogView", bundle: nil)
        self.presentAsSheet(uploadsDialogView)
    }
    
    private func loadUserAccountDetails() {
        userAccount = Account()
        _ = userAccount.Load()
    }
    
    func setupAccountDetailsAndStorageView() {
        DispatchQueue.main.async { [self] in
            loadUserAccountDetails()

            usernameLabel.stringValue = userAccount.UserName
        }
        
        DispatchQueue.main.async {
            WebsocketHandler.connectToAddress(addr: "ws://localhost:\(Constants.WS_PORT)/command/capacity") { data in
                let result = data as! [String:Any]
                let response = Common.convertDictionaryToObject(from: result, to: DaemonResponse.self)
                let daemonResponse = response.0
                let error = response.1
                
                if error != nil {
                    print(error!)
                    return
                }
                
                if daemonResponse?.Value == nil {
                    print("nil daemonresponse value: setupAccountDetailsAndStorageView")
                    return
                }
                
                let userDetails = Common.decodeBase64ToObject(from: daemonResponse!.Value!, to: User.self, isFromDaemon: true)
                
                let storageCapacityUsed = (userDetails!.AwsCapacityUsed+userDetails!.SpoolCapacityUsed / Double(Constants.TIER_1_MAX_STORAGE) * 1000).rounded() / 1000
                let storageCapacityUsedText = "You have used \(storageCapacityUsed)% of your primary storage"
                DispatchQueue.main.async {
                    self.primaryStorageInfoMessageLabel.stringValue = storageCapacityUsedText
                    self.primaryStorageWidthConstraint.constant = Double(self.progressBarWidth)*storageCapacityUsed
                    // TODO: Display the additional storage used
                }
            } onError: { err in
                print(err)
            }
        }

    }
    
    func setupSearch() {
        DispatchQueue.main.async {
            DaemonHandler.getAllBlocks { [self] blocks in
                guard let allBlocks = blocks else { return }
                self.recentBlocksTableController.allBlocks = allBlocks
                self.searchHandler = SearchHandler(possibleResultObjects: allBlocks)
                
                DispatchQueue.main.async { [self] in
                    searchResultsContainer.isHidden = true
                    searchResultsTableView.register(NSNib(nibNamed: "SearchResultTableCell", bundle: nil), forIdentifier: NSUserInterfaceItemIdentifier("SearchResultTableCell"))
                }
            } errorCallback: { err in
                print(err)
            }
        }
        
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        
        
        self.view.window?.setFrame(NSRect(origin: (self.view.window?.frame.origin)!, size: CGSize(width: 1500, height: 800)), display: false, animate: true)
    }
    
    @IBAction func uploadAction(_ sender: NSButton) {
        let openPanel = NSOpenPanel()
        openPanel.canChooseFiles = true
        openPanel.canChooseDirectories = false
        openPanel.begin { response in
            if (response == .OK) {
                let url = openPanel.url!
                let path = url.relativePath
                let fileName = url.lastPathComponent
                
                let fileManager = FileManager.default
                
                do {
                    let fileAttributes = try fileManager.attributesOfItem(atPath: path)
                    let fileSize = fileAttributes[.size] as! Int64 // size of file in bytes
                    
                    let uploadFileView = UploadFileView(nibName: "UploadFileView", bundle: nil)
                    uploadFileView.setFileUploadingDetails(path: path, name: fileName, size: Int(fileSize))
                    self.presentAsSheet(uploadFileView)
                } catch {
                    return
                }
            }
                
        }
    }
    
    func hideAndClearSearchBar() {
        searchTableController = SearchResultTableController(parent: self, results: [])
        searchResultsTableView.delegate = searchTableController
        searchResultsTableView.dataSource = searchTableController
        searchResultsTableView.reloadData()
        
        NSAnimationContext.runAnimationGroup { context in
            context.timingFunction = CAMediaTimingFunction(name: .easeOut)
            searchResultsContainer.animator().isHidden = true
        }
    }
    
    var i = 0
    @IBAction func action(_ sender: NSButton) {
        i += 1
        cardCollectionsView.showCard(type: .allFilesFolders, data: nil)
    }
    
    @IBAction func showDownloadDialog(_ sender: NSButton) {
        self.showDownloadsDialog()
    }
    
    @IBAction func showUploadDialog(_ sender: NSButton) {
        self.showUploadsDialog()
    }
    
    override func viewDidLayout() {
        super.viewDidLayout()
    }
    
}

class OpaqueScroller: NSScroller {
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        NSColor.white.setFill()
        dirtyRect.fill()
        // whatever style you want here for knob if you want
        knobStyle = .light
        drawKnob()
    }
}

class RecentBlocksTableController: NSObject, NSTableViewDelegate, NSTableViewDataSource {
    var blocks: [String] = []
    
    var allBlocks: [Block]!
    var cardCollectionView: CardCollectionView!
    
    init(allBlocks: [Block], cardCollectionView: CardCollectionView) {
        self.allBlocks = allBlocks
        self.cardCollectionView = cardCollectionView
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        return false
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if blocks.count > 0 {
            
            var columnIndex = 0
            for blockName in blocks {
                columnIndex += 1
                
                if tableColumn?.identifier == NSUserInterfaceItemIdentifier(rawValue: columnIndex.description) {
                    guard let cellView = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier("recentBlockCell"), owner: self) as? RecentBlockTableCell else {
                        return nil
                    }
                    
                    cellView.button.imagePosition = .imageLeft
                    cellView.button.title = blockName
                    cellView.button.image = NSImage(systemSymbolName: "doc.fill", accessibilityDescription: nil)
                    
                    cellView.action = {
                        for block in self.allBlocks {
                            if block.FileName == blockName {
                                DispatchQueue.main.asyncAfter(deadline: .now()+0.125) {
                                    self.cardCollectionView.showCard(type: .file, data: block)
                                }
                                break
                                
                            }
                        }
                    }
                    
                    tableColumn?.width = Common.widthOfString(blockName, font: NSFont.systemFont(ofSize: 13))+40+20
                    return cellView
                }
            }
            
        }
        
        return nil
    }
}

extension HomePage: NSSearchFieldDelegate {
    func controlTextDidChange(_ obj: Notification) {
        let value = (obj.object as! NSSearchField).stringValue
        let results = searchHandler.search(phrase: value)
        
        var searchResults: [SearchResults] = []
        for i in results {
            let block = i as! Block
            searchResults.append(SearchResults(resultType: .block, data: block))
        }
        
        if searchResults.count > 0 {
            NSAnimationContext.runAnimationGroup { context in
                context.timingFunction = CAMediaTimingFunction(name: .easeOut)
                
                recentsSection.animator().isHidden = true
                searchResultsContainer.animator().isHidden = false
            }
            searchTableController = SearchResultTableController(parent: self, results: searchResults)
            searchResultsTableView.delegate = searchTableController
            searchResultsTableView.dataSource = searchTableController
            searchResultsTableView.reloadData()
        } else {
            NSAnimationContext.runAnimationGroup { context in
                context.timingFunction = CAMediaTimingFunction(name: .easeOut)
                searchResultsContainer.animator().isHidden = true
                recentsSection.animator().isHidden = false
            }
        }
    }
}

extension HomePage: CardCollectionViewDelegate {
    func cardRemoved(count: Int) {
        if count == 0 {
            NSAnimationContext.runAnimationGroup { context in
                context.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
                searchFieldCenterConstraint.animator().constant = 0
                cardCollectionsView.animator().alphaValue = 0
            }
        }
    }
    
    func cardAdded(count: Int) {
        if count == 1 {
            NSAnimationContext.runAnimationGroup { context in
                context.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
                searchFieldCenterConstraint.animator().constant = -120
                cardCollectionsView.animator().alphaValue = 1
            }
        }
    }
    
    
}
