//
//  SearchResults.swift
//  Shr
//
//  Created by Christopher Inegbedion on 04/03/2023.
//

import Foundation

struct SearchResults {
    var resultType: SearchResultType
    var data: Any
}

enum SearchResultType {
    case block
    case user
}
