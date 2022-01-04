//
//  KeychainWrapper.swift
//  Demo app
//
//  Created by tft on 22/01/20.
//  Copyright © 2020 tft. All rights reserved.
//

import Foundation
//import KeychainAccess

public struct KeychainWrapper {
    
    private static var k: Keychain {
        return Keychain(service: "Demo")
    }
    
    public static func setPassword(_ password: String, forVPNID VPNID: String) {
        let key = NSURL(string: VPNID)!.lastPathComponent!
        _ = try? k.remove(key)
        k[key] = password
    }
    
    public static func setSecret(_ secret: String, forVPNID VPNID: String) {
        let key = NSURL(string: VPNID)!.lastPathComponent!
        _ = try? k.remove("\(key)psk")
        k["\(key)psk"] = secret
    }
    
    public static func passwordRefForVPNID(_ VPNID: String) -> Data? {
        let key = NSURL(string: VPNID)!.lastPathComponent!
        return k[attributes: key]?.persistentRef
    }
    
    public static func secretRefForVPNID(_ VPNID: String) -> Data? {
        let key = NSURL(string: VPNID)!.lastPathComponent!
        if let data = k[attributes: "\(key)psk"]?.data, let value = String(data: data, encoding: .utf8) {
            if !value.isEmpty {
                return k[attributes: "\(key)psk"]?.persistentRef
            }
        }
        return nil
    }
    
    public static func destoryKeyForVPNID(_ VPNID: String) {
        let key = NSURL(string: VPNID)!.lastPathComponent!
        _ = try? k.remove(key)
        _ = try? k.remove("\(key)psk")
        _ = try? k.remove("\(key)cert")
    }
    
    public static func passwordStringForVPNID(_ VPNID: String) -> String? {
        let key = NSURL(string: VPNID)!.lastPathComponent!
        return k[key]
    }
    
    public static func secretStringForVPNID(_ VPNID: String) -> String? {
        let key = NSURL(string: VPNID)!.lastPathComponent!
        return k["\(key)psk"]
    }
    
}
