//
//  KeychainError.swift
//  DesappstreSecureKit
//
//  Created by Adolfo Vera Blasco on 03/04/2019.
//  Copyright © 2019 desappstre {estudio}. All rights reserved.
//

import Security
import Foundation

public enum KeychainError: Error
{
    case passwordNotFound
    case malformedData
    case unknown(status: OSStatus)
}
