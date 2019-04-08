//
//  User.swift
//  DesappstreSecureKit
//
//  Created by Adolfo Vera Blasco on 03/04/2019.
//  Copyright © 2019 desappstre {estudio}. All rights reserved.
//

import Foundation

public struct User
{
    ///
    public var name: String
    ///
    public var password: String
    
    /**
 
    */
    public init(named name: String, withPassword password: String)
    {
        self.name = name
        self.password = password
    }
}

//
// MARK: - CustomStringConvertible Protocol
//

extension User: CustomStringConvertible
{
    ///
    public var description: String
    {
        return "El usuario \(self.name) tiene la clave \(self.password)"
    }
}
