//
//  Block.swift
//  Shr
//
//  Created by Christopher Inegbedion on 24/02/2023.
//

import Foundation

struct Block: Codable {
    var FileName: String
    var Hash: String
    var PrevHash: String
    var Salt: String
    var Cost: CGFloat
    var CreationTime: Int
    var UBlock: UploadBlock
    var DBlock: DeleteBlock?
}

struct UploadBlock: Codable {
    var FileSizeBytes: Int
    var FileSizeb64Bytes: Int
    var Hosts: [[String]]
    var Visible: Bool
    var ShardsCreated: Int
    var Key: String
}

struct DeleteBlock: Codable {
    var blockReferencingHash: String
}
