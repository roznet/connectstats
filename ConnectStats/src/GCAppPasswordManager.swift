//
//  GCAppPasswordManager.swift
//  GarminConnect
//
//  Created by Brice Rosenzweig on 30/10/2016.
//  Copyright © 2016 Brice Rosenzweig. All rights reserved.
//

import UIKit
import RZExternalUniversal
import SwiftKeychainWrapper

class GCAppPasswordManager : NSObject {

    let keychain : KeychainWrapper
    let key :String
    
    @objc public init(forService service : String, andUsername username : String) {
        keychain = KeychainWrapper(serviceName: "net.ro-z.connectstats")
        key = NSString(format: "%@.%@", service,username) as String
        super.init()
    }
    
    @objc public func retrievePassword() -> String? {
        return keychain.string(forKey: key)
    }
    
    @objc @discardableResult public func savePassword(_ password : String ) -> Bool {
        return keychain.set(password, forKey: key)
    }
    
    @objc @discardableResult public func clearPassword() -> Bool {
        return keychain.removeObject(forKey: key)
    }
}
