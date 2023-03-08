//
//  DaemonResponse.swift
//  Shr
//
//  Created by Christopher Inegbedion on 23/02/2023.
//

import Foundation

// A model for the response returned by the Daemon
struct DaemonResponse: Codable {
    var HasError: Bool
    var Error: String
    var Message: String
    var Value: String?
    
}
