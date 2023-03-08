//
//  Constants.swift
//  Shr
//
//  Created by Christopher Inegbedion on 23/02/2023.
//

import Foundation

class Constants {
    private init() {}
    
    static let RSA_KEY_LENGTH = 2048
    static let WS_PORT: Int = 54325
    static let CONFIG_FILE_PATH = Common.getAppDataStoragePath(filename: "config.toml")
    
    static let FREE_MAX_STORAGE = 10 // GB
    static let TIER_1_MAX_STORAGE = 300 // Gigabytes
    
    static let NEW_DOWNLOAD_USERDEFAULTS = "file-downloads"
    static let NEW_UPLOAD_USERDEFAULTS = "file-uploads"
}
