//
//  Common.swift
//  Shr
//
//  Created by Christopher Inegbedion on 23/02/2023.
//

import Foundation
import AppKit

class Common {
    private init() {}
    
    static let shared = Common()
    
    /// Convert a dictionary to an object
    static func convertDictionaryToObject<T>(from a: [String:Any], to object: T.Type) -> (T?, Error?) where T : Decodable {
        let decoder = JSONDecoder()
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: a, options: .prettyPrinted)
            
            do {
                let decoded = try decoder.decode(object, from: jsonData)
                
                return (decoded, nil)
            } catch {
                return (nil, error)
            }
        } catch {
            return (nil, error)
        }
    }
    
    /// Get the storage path of a daemon file
    static func getAppDataStoragePath(filename: String) -> String {
        let username = NSUserName()
        
        let filePath = "/Users/\(username)/Library/Application Support/shr/\(filename)"
        
        return filePath
    }
    
    static func decodeBase64ToObject<T>(from: String, to: T.Type) -> T? {
        guard let data = Data(base64Encoded: from) else { return nil }
        do {
            return try data.withUnsafeBytes { $0.load(as: T.self) }
        } catch {
            return nil
        }
    }
    
    /// Convert Base64 string to an object
    static func decodeBase64ToObject<T>(from base64EncodedString: String, to object: T.Type, isFromDaemon: Bool) -> T? where T : Decodable {
        let decoder = JSONDecoder()
        // Convert the B64 string to a Data object
        guard let decodedData = Data(base64Encoded: base64EncodedString) else {
            return nil
        }
        
        // Convert the Data object to a JSON string
        guard let jsonString = String(data: decodedData, encoding: .utf8) else {
            return nil
        }
        
        let cleanedJsonString = jsonString
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .trimmingCharacters(in: .newlines)
            .replacingOccurrences(of: "\\n", with: "")
            .replacingOccurrences(of: "\\", with: "")
            .replacingOccurrences(of: "\"{", with: "{")
            .replacingOccurrences(of: "}\"", with: "}")
            .replacingOccurrences(of: "\"[", with: "[")
            .replacingOccurrences(of: "]\"", with: "]")
        do {
            let a = try JSONSerialization.jsonObject(with: cleanedJsonString.data(using: .utf8)!, options: .fragmentsAllowed) as? [String: Any]
            // Convert the dictionary to a Data object
            do {
                var jsonObject: Data
                if isFromDaemon {
                    jsonObject = try JSONSerialization.data(withJSONObject: a!["data"]!, options: .prettyPrinted)
                } else {
                    jsonObject = try JSONSerialization.data(withJSONObject: a!, options: .prettyPrinted)
                }
                
                do {
                    // Convert the Data object to the required object type
                    let decoded = try decoder.decode(object, from: jsonObject)
                    
                    return decoded
                } catch {
                    print(error)
                    return nil
                }
            } catch {
                print(error)
                return nil
            }
        } catch {
            print(error)
            return nil
        }
    }
    
    static func widthOfString(_ string: String, font: NSFont) -> CGFloat {
        let attributes = [NSAttributedString.Key.font: font]
        let size = string.size(withAttributes: attributes)
        return size.width
    }
    
    static func convertUnixTimestampToStringDate(_ timestamp: Double, format: String = "yyyy-MM-dd HH:mm:ss") -> String {
        let date = Date(timeIntervalSince1970: timestamp)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: date)
    }
    
    static func convertBytesToString(_ bytes: Int) -> String {
        let byteCountFormatter = ByteCountFormatter()
        byteCountFormatter.allowedUnits = [.useKB, .useMB, .useGB, .useTB]
        byteCountFormatter.countStyle = .file
        return byteCountFormatter.string(fromByteCount: Int64(bytes))
    }
    
    static func convertObjectToDictionary(from object: Any) -> [String:Any] {
        let mirror = Mirror(reflecting: object)
        var dictionary = [String: Any]()
        
        for child in mirror.children {
            if let key = child.label {
                dictionary[key] = child.value
            }
        }
        
        return dictionary
    }
}
