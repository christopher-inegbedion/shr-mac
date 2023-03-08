//
//  Keys.swift
//  Shr
//
//  Created by Christopher Inegbedion on 24/02/2023.
//

import Foundation

func generateKeyPair(bits: Int) throws -> (SecKey, SecKey) {
    let tag = "com.shr.key".data(using: .utf8)!
    let attributes: [String: Any] = [
        kSecAttrKeyType as String:            kSecAttrKeyTypeRSA,
        kSecAttrKeySizeInBits as String:      Constants.RSA_KEY_LENGTH,
        kSecPrivateKeyAttrs as String: [
            kSecAttrIsPermanent as String:   true,
            kSecAttrApplicationTag as String: tag]
    ]
    
    var error: Unmanaged<CFError>?
    guard let privateKey = SecKeyCreateRandomKey(attributes as CFDictionary, &error) else {
        throw error!.takeRetainedValue() as Error
    }
    let publicKey = SecKeyCopyPublicKey(privateKey)
    
    return (privateKey, publicKey!)
}

func convertPrivateKeyAsPEMString(privKey: SecKey) -> String? {
    var error: Unmanaged<CFError>?
    guard let keyData = SecKeyCopyExternalRepresentation(privKey, &error) as Data? else {
        print("Error getting key data: \(error?.takeRetainedValue() ?? "" as! CFError)")
        return nil
    }
    
    let base64EncodedKey = keyData.base64EncodedString()
    let pemString = """
    -----BEGIN PRIVATE KEY-----
    \(base64EncodedKey)
    -----END PRIVATE KEY-----
    """
    return pemString
}

func convertPublicKeyAsPEMString(pubKey: SecKey) -> String? {
    var error: Unmanaged<CFError>?
    guard let keyData = SecKeyCopyExternalRepresentation(pubKey, &error) as Data? else {
        print("Error getting key data: \(error?.takeRetainedValue() ?? "" as! CFError)")
        return nil
    }
    
    let base64EncodedKey = keyData.base64EncodedString()
    let pemString = """
    -----BEGIN PUBLIC KEY-----
    \(base64EncodedKey)
    -----END PUBLIC KEY-----
    """
    return pemString
    
}
