//
//  User.swift
//  Shr
//
//  Created by Christopher Inegbedion on 25/02/2023.
//

import Foundation

struct User: Codable {
    var Address: String
    var RelayAddress: String
    var UserName: String
    var Timezone: String
    var AccountType: String
    var SpoolCapacityUsed: Float64
    var AwsCapacityUsed: Float64
    var NumFilesUploaded: Int
}
