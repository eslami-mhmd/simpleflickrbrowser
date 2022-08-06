//
//  KeyChain.swift
//  SimpleFlickrBrowser
//
//  Created by Mohammad Eslami on 8/6/22.
//

import Foundation

class KeyChain {
    class func save(key: String, data: Data) -> OSStatus {
        let query = [
            kSecClass as String       : kSecClassGenericPassword as String,
            kSecAttrAccount as String : key,
            kSecValueData as String   : data ] as [String : Any]

        SecItemDelete(query as CFDictionary)

        return SecItemAdd(query as CFDictionary, nil)
    }

    class func load(key: String) -> Data? {
        let query = [
            kSecClass as String       : kSecClassGenericPassword,
            kSecAttrAccount as String : key,
            kSecReturnData as String  : kCFBooleanTrue!,
            kSecMatchLimit as String  : kSecMatchLimitOne ] as [String : Any]

        var dataTypeRef: AnyObject? = nil

        let status: OSStatus = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)

        if status == noErr {
            return dataTypeRef as! Data?
        } else {
            return nil
        }
    }

    class func loadAsString(key: String) -> String? {
            guard let data = load(key: key) else {
                return nil
            }
            return String(data: data, encoding: .utf8)
    }

    class func save(key: String, value: String) -> OSStatus {
        guard let data = value.data(using: .utf8) else {
            return .zero
        }
        return save(key: key, data: data)
    }
    
    class func delete(key: String) {
        let query = [
            kSecClass as String: kSecClassGenericPassword as String, kSecAttrAccount as String: key
        ] as [String: Any]
        SecItemDelete(query as CFDictionary)
    }

    class func createUniqueID() -> String {
        let uuid: CFUUID = CFUUIDCreate(nil)
        let cfStr: CFString = CFUUIDCreateString(nil, uuid)

        let swiftString: String = cfStr as String
        return swiftString
    }
}
