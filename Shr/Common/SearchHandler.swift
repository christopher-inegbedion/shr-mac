//
//  SearchHandler.swift
//  Shr
//
//  Created by Christopher Inegbedion on 04/03/2023.
//

import Foundation

class SearchHandler {
    var possibleSearchSpaceObjects: [Any] = []
    var searchSpaceObjectsStringed: [String:Any] {
        self.convertSearchSpaceObjectsToTokens()
    }
    
    init(possibleResultObjects: [Any]) {
        self.possibleSearchSpaceObjects = possibleResultObjects
    }
    
    private func convertSearchSpaceObjectsToTokens() -> [String:Any] {
        var result: [String:Any] = [:]
        for object in possibleSearchSpaceObjects {
            var properties: [String] = []
            let mirror = Mirror(reflecting: object)
            
            for i in mirror.children {
                let propertyValue = String(describing: i.value)
                properties.append(propertyValue)
            }
            
            result[properties.joined(separator: " ")] = object
        }
        
        return result
    }
    
    func containsAny(words: [String], in phrase: String) -> Bool {
        for word in words {
            if word.capitalized.contains(phrase.capitalized) {
                return true
            }
        }
        return false
    }
    
    func search(phrase: String) -> [Any] {
        var results: [Any] = []
        for (k, v) in self.searchSpaceObjectsStringed {
            if containsAny(words: k.components(separatedBy: " "), in: phrase) {
                results.append(v)
            }
        }
        
        return results
    }
    
    
}
