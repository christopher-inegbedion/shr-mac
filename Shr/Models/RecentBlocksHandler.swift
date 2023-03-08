//
//  RecentBlocks.swift
//  Shr
//
//  Created by Christopher Inegbedion on 08/03/2023.
//

import Foundation

/// Handles storing and retrieving the most recent blocks that have been interacted with
class RecentBlocksHandler {
    private let MAX_RECENT_BLOCKS = 5
    private let RECENT_BLOCK_USERDEFAULTS_KEY = "recent-blocks"
    
    static let shared = RecentBlocksHandler()
    
    private init() {}
    
    func getRecentBlocks() -> [String] {
        let blocks = UserDefaults.standard.array(forKey: RECENT_BLOCK_USERDEFAULTS_KEY) as? [String] ?? []
        
        return blocks
    }
    
    func addBlockToRecents(block: Block) {
        var allBlocks: [String] = self.getRecentBlocks()
        
        if allBlocks.count == 5 {
            allBlocks.remove(at: 0)
        }
        
        allBlocks.append(block.FileName)
        
        UserDefaults.standard.set(allBlocks, forKey: RECENT_BLOCK_USERDEFAULTS_KEY)
        
        NotificationCenter.default.post(name: NSNotification.Name("recent-block-added"), object: block)
    }
    
    func clearRecents() {
        UserDefaults.standard.set([], forKey: RECENT_BLOCK_USERDEFAULTS_KEY)
        NotificationCenter.default.post(name: NSNotification.Name("recent-block-cleared"), object: nil)
    }
}
