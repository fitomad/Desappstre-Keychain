//
//  SecurityBC.swift
//  DesappstreSecureKit
//
//  Created by Adolfo Vera Blasco on 03/04/2019.
//  Copyright © 2019 desappstre {estudio}. All rights reserved.
//

import Foundation
import Security

public class SecurityBC
{
    public func fetchUser(_ user: User) throws -> User
    {
        let query: [String: Any] = [
            kSecClass as String: kSecClassInternetPassword,
            kSecMatchLimit as String: kSecMatchLimitOne,
            kSecReturnAttributes as String: true,
            kSecReturnData as String: true
        ]
        
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        
        if status == errSecItemNotFound
        {
            throw KeychainError.passwordNotFound
        }
        
        if status == errSecSuccess
        {
            guard let existingItem = item as? [String : Any],
                  let passwordData = existingItem[kSecValueData as String] as? Data,
                  let password = String(data: passwordData, encoding: .utf8),
                  let account = existingItem[kSecAttrAccount as String] as? String
            else
            {
                    throw KeychainError.malformedData
            }
            
            let user = User(named: account, withPassword: password)
            
            return user
            
        }
        else
        {
            throw KeychainError.unknown(status: status)
        }
    }
    /**
 
    */
    public func saveSecureUser(_ user: User) throws -> Void
    {
        guard let passwordData = user.password.data(using: .utf8) else
        {
            return
        }
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassInternetPassword,
            kSecAttrAccount as String: user.name,
            kSecValueData as String: passwordData
        ]
        
        let status = SecItemAdd(query as CFDictionary, nil)
        
        if status != errSecSuccess
        {
            throw KeychainError.unknown(status: status)
        }
    }
}
