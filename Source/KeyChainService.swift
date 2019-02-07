//
//  KeyChainService.swift
//  PR2StudioSwift
//
//  Created by Pablo Roca on 07/02/2019.
//  Copyright © 2019 PR2Studio. All rights reserved.
//

import Foundation
import Security

public final class KeyChainService: NSObject {

    private class func keychainQuery(withKey key: String) -> NSMutableDictionary {
        let result = NSMutableDictionary()
        result.setValue(kSecClassGenericPassword, forKey: kSecClass as String)
        result.setValue(key, forKey: kSecAttrService as String)
        //        result.setValue(kSecAttrAccessibleAlwaysThisDeviceOnly, forKey: kSecAttrAccessible as String)
        return result
    }

    public class func save(_ value: String?, forKey key: String) -> Bool {
        let query = keychainQuery(withKey: key)
        let objectData: Data? = value?.data(using: .utf8, allowLossyConversion: false)

        if SecItemCopyMatching(query, nil) == noErr {
            if let dictData = objectData {
                let status = SecItemUpdate(query, NSDictionary(dictionary: [kSecValueData: dictData]))
                return status == errSecSuccess ? true: false
            } else {
                let status = SecItemDelete(query)
                return status == errSecSuccess ? true: false
            }
        } else {
            if let dictData = objectData {
                query.setValue(dictData, forKey: kSecValueData as String)
                let status = SecItemAdd(query, nil)
                return status == errSecSuccess ? true: false
            }
        }
        return true
    }

    public class func load(withKey key: String) -> String? {
        let query = keychainQuery(withKey: key)
        query.setValue(kCFBooleanTrue, forKey: kSecReturnData as String)
        query.setValue(kCFBooleanTrue, forKey: kSecReturnAttributes as String)

        var result: CFTypeRef?
        let status = SecItemCopyMatching(query, &result)

        guard
            let resultsDict = result as? NSDictionary,
            let resultsData = resultsDict.value(forKey: kSecValueData as String) as? Data,
            status == noErr
            else {
                return nil
        }
        return String(data: resultsData, encoding: .utf8)
    }

}
