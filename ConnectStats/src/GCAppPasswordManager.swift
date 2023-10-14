//
//  GCAppPasswordManager.swift
//  GarminConnect
//
//  Created by Brice Rosenzweig on 30/10/2016.
//  Copyright © 2016 Brice Rosenzweig. All rights reserved.
//

import UIKit
import KeychainAccess
import RZUtils
import RZUtilsSwift

class GCAppPasswordManager : NSObject {

    let keychain : Keychain
    let key :String
    
    @objc public init(forService service : String, andUsername username : String) {
        keychain = Keychain(service: "net.ro-z.connectstats")
            .accessibility(.afterFirstUnlock)
        key = NSString(format: "%@.%@", service,username) as String
        super.init()
    }
    
    @objc public func retrievePassword() -> String? {
        do {
            return try keychain.get(key)
        }catch{
            RZSLog.error("Failed to retrieve \(key) from keychain \(error)")
            return nil
        }
    }
    
    @objc @discardableResult public func savePassword(_ password : String ) -> Bool {
        do {
            try keychain.set(password, key: key)
            return true
        }catch{
            RZSLog.error("Failed to set \(key) to keychain \(error)")
            return false
        }
    }
    
    @objc @discardableResult public func clearPassword() -> Bool {
        do {
            try keychain.remove(key)
            return true
        }catch{
            RZSLog.error("Failed to remove \(key) from keychain \(error)")
            return false
        }
    }
}
