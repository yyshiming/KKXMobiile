//
//  KKXMobile.swift
//  Demo
//
//  Created by ming on 2021/9/8.
//

import UIKit

public struct KKX {

}

internal class _KKXMobile_ {
        
    static let shared = _KKXMobile_()
    
    internal var languageBundle: Bundle? {
        if _languageBundle == nil {
            var language = defaultConfiguration.languageCode
            if language == nil {
                language = Locale.preferredLanguages.first
            }
            if language?.contains("zh-Hans") == true {
                language = "zh-Hans"
            } else {
                language = "en"
            }
            
            _languageBundle = Bundle(path: Bundle.kkxMobileBundle.path(forResource: language, ofType: "lproj")!)
        }
        return _languageBundle
    }
    internal var _languageBundle: Bundle?
}
