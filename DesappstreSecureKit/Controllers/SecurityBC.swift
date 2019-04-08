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
    ///
    public let serviceName: String
    
    /**
 
    */
    public init()
    {
        self.serviceName = "The Shows"
    }
    
    public func fetchUser(_ user: User) -> Result<User, KeychainError>
    {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String : self.serviceName,
            kSecAttrAccount as String: user.name,
            kSecMatchLimit as String: kSecMatchLimitOne,
            kSecReturnAttributes as String: true,
            kSecReturnData as String: true
        ]
        
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        
        if status == errSecItemNotFound
        {
            return Result.failure(KeychainError.passwordNotFound)
            //throw KeychainError.passwordNotFound
        }
        
        if status == errSecSuccess
        {
            guard let existingItem = item as? [String : Any],
                  let passwordData = existingItem[kSecValueData as String] as? Data,
                  let password = String(data: passwordData, encoding: .utf8),
                  let account = existingItem[kSecAttrAccount as String] as? String
            else
            {
                return Result.failure(KeychainError.malformedData)
            }
            
            let user = User(named: account, withPassword: password)
            
            return Result.success(user)
            
        }
        else
        {
            return Result.failure(KeychainError.unknown(status: status))
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
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: self.serviceName,
            kSecAttrAccount as String: user.name,
            kSecValueData as String: passwordData
        ]
        
        let status = SecItemAdd(query as CFDictionary, nil)
        
        if status != errSecSuccess
        {
            throw KeychainError.unknown(status: status)
        }
    }
    
    public func updateSecureUser(_ user: User) throws -> Void
    {
        guard let passwordData = user.password.data(using: .utf8) else
        {
            return
        }
        
        // Filtro para encontrar el registro
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String : self.serviceName,
            kSecAttrAccount as String: user.name
        ]
        
        // La clave que queremos actualizar
        let fields: [String: Any] = [
            kSecAttrAccount as String: user.name,
            kSecValueData as String: passwordData
        ]
        
        let status = SecItemUpdate(query as CFDictionary, fields as CFDictionary)
        
        if status != errSecSuccess
        {
            throw KeychainError.unknown(status: status)
        }
    }
    
    /**
 
    */
    public func deleteUser(_ user: User) throws -> Void
    {
        // Filtro para encontrar el registro
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String : self.serviceName,
            kSecAttrAccount as String: user.name
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        
        if status != errSecSuccess
        {
            throw KeychainError.unknown(status: status)
        }
    }
    
    /**
 
    */
    public func existsUser(_ user: User) -> Bool
    {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String : self.serviceName,
            kSecAttrAccount as String: user.name,
            kSecMatchLimit as String: kSecMatchLimitOne,
            kSecReturnAttributes as String: false,
            kSecReturnData as String: false
        ]
        
        let status = SecItemCopyMatching(query as CFDictionary, nil)
        
        if status == errSecItemNotFound
        {
            return false
        }
        
        return true
    }
}
