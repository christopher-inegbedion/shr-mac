//
//  Account.swift
//  Shr
//
//  Created by Christopher Inegbedion on 24/02/2023.
//

import Foundation
import Toml
import TOMLKit

struct Account: Codable {
    var UserName: String = ""
    var Registered: Bool = false
    var KnownNodes: [String:[String:String]]? = [:]
    var PrivateKey: String = ""
    var PubKey: String = ""
    var Port: Int = 0
    var ConnectedToRelay: Bool = false
    
    /// Create a new Account instance
    static func createAccount() -> Account {
        var account = Account()
        account.Port = Int(arc4random_uniform(9999)+1000)
        
        do {
            let keys = try generateKeyPair(bits: Constants.RSA_KEY_LENGTH)
            let privKey = keys.0
            let pubKey = keys.1
            
            account.PrivateKey = convertPrivateKeyAsPEMString(privKey: privKey)!
            account.PubKey = convertPublicKeyAsPEMString(pubKey: pubKey)!
        } catch {
            print(error)
        }
        
        return account
    }
    
    /// Load the account data from the 'config.toml' file
    mutating func Load() -> Error? {
        do {
            let toml = try Toml(contentsOfFile: Constants.CONFIG_FILE_PATH)
            
            do {
                let decodedAccount = try TOMLDecoder().decode(Account.self, from: toml.description)
                self = decodedAccount
            } catch {
                print("Error happened decoding Account")
                return error
            }
            
        } catch {
            return error
        }
        
        return nil
    }
    
    /// Call to check if the user is registered
    static func isUserRegistered() -> Bool {
        var account = Account.createAccount()
        let err = account.Load()
//        print(account)
        guard err == nil else { return false }
        return account.Registered
    }
}
