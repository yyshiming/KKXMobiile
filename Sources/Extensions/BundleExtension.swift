//
//  BundleExtension.swift
//  KKXMobiile
//
//  Created by ming on 2021/5/11.
//

import UIKit

extension Bundle {
    
    public var bundleId: String {
        return Bundle.main.infoDictionary?["CFBundleIdentifier"] as? String ?? ""
    }
    
    public var name: String {
        return Bundle.main.infoDictionary?["CFBundleName"] as? String ?? ""
    }
    
    public var displayName: String {
        return Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String ?? ""
    }
    
    public var version: String {
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
    }
    
    public var build: String {
        return Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? ""
    }
}

extension Bundle {
    
    public static let kkxMobileBundle = Bundle(path: Bundle(for: _KKXMobile_.self).path(forResource: "KKXMobile", ofType: "bundle")!)!
    
    public class func kkx_localizedString(forKey key: String) -> String {
        self.kkx_localizedString(forKey: key, value: nil)
    }
    
    public class func kkx_localizedString(forKey key: String, value: String?) -> String {
        
        let bundle = _KKXMobile_.shared.languageBundle!
        return bundle.localizedString(forKey: key, value: value, table: nil)
    }
}
