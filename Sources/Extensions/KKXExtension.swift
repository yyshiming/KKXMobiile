//
//  KKXExtension.swift
//  KKXMobile
//
//  Created by ming on 2021/5/10.
//

import UIKit

public final class KKXExtension {
    static let shared = KKXExtension()
    public class func swizzling() {
        _ = KKXExtension.shared.swizzling
    }
    
    private lazy var swizzling: Void = {
        UIViewController.initializeController()
        UINavigationController.initializeNavController()
        UICollectionView.initializeCollectionView()
    }()
}

/// 获取目前屏幕中显示的viewController
public var kkxTopViewController: UIViewController? {
    var controller = UIApplication.shared.windows.first?.rootViewController
    while true {
        if let presentedControler = controller?.presentedViewController {
            controller = presentedControler
        }
        else if let topViewController = (controller as? UINavigationController)?.topViewController {
            controller = topViewController
        }
        else if let selectedController = (controller as? UITabBarController)?.selectedViewController {
            controller = selectedController
        }
        else {
            break
        }
    }
    return controller
}

/// 交换Class中的方法和自定义方法
/// - Parameter theClass: 要交换的Class
/// - Parameter originalSelector: Class方法
/// - Parameter swizzledSelector: 自定义方法
public func kkxSwizzleSelector(_ theClass: AnyClass, originalSelector: Selector, swizzledSelector: Selector) {
    
    let originalMethod = class_getInstanceMethod(theClass, originalSelector)
    let swizzledMethod = class_getInstanceMethod(theClass, swizzledSelector)
    
    let didAddMethod: Bool = class_addMethod(theClass, originalSelector, method_getImplementation(swizzledMethod!), method_getTypeEncoding(swizzledMethod!))
    
    if didAddMethod {
        class_replaceMethod(theClass, swizzledSelector, method_getImplementation(originalMethod!), method_getTypeEncoding(originalMethod!))
    } else {
        method_exchangeImplementations(originalMethod!, swizzledMethod!)
    }
}

/// DEBUG环境打印
public func kkxPrint(_ items: Any..., separator: String = " ", terminator: String = "\n") {
    #if DEBUG
    print(items, separator, terminator)
    #endif
}

/// DEBUG环境打印
public func kkxDebugPrint(_ items: Any..., separator: String = " ", terminator: String = "\n") {
    #if DEBUG
    debugPrint(items, separator, terminator)
    #endif
}

// MARK: - ======== LocalizedString ========
internal func KKXExtensionString(_ key: String) -> String {
    let bundle = _KKXMobile_.shared.languageBundle!
    return NSLocalizedString(key, tableName: "Localizable", bundle: bundle, value: "", comment: "")
}
