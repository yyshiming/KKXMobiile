//
//  AppDelegate.swift
//  Demo
//
//  Created by ming on 2021/5/10.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        KKXExtension.swizzling()
        
        let config = defaultConfiguration
        config.themeColor = .orange
        config.customBackBarButtonItemImage = defaultConfiguration.defaultBackImage
        config.customBackImageInsets = UIEdgeInsets(left: -3)
        config.languageCode = "zh-Hans"
        config.isHideNavigationBarShadowImage = true
        config.navigationBarStyle = .theme
        
//        window = UIWindow(frame: UIScreen.main.bounds)
//
//        window!.makeKeyAndVisible()
        return true
    }
}

