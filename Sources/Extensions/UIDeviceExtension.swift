//
//  UIDeviceExtension.swift
//  KKXMobile
//
//  Created by ming on 2021/5/10.
//

import UIKit
import CoreTelephony

extension UIDevice {
    
    public static var carriers: [CTCarrier]? {
        let networkInfo = CTTelephonyNetworkInfo()
        if #available(iOS 12.0, *) {
            return networkInfo.serviceSubscriberCellularProviders?.map { $0.value }
        } else if let provider = networkInfo.subscriberCellularProvider {
            return [provider]
        }
        return nil
    }
    
    public static var currentCarrier: CTCarrier? {
        let networkInfo = CTTelephonyNetworkInfo()
        if #available(iOS 13.0, *),
           let identifier = networkInfo.dataServiceIdentifier {
            return networkInfo.serviceSubscriberCellularProviders?[identifier]
        } else if #available(iOS 12.0, *) {
            return networkInfo.serviceSubscriberCellularProviders?.map { $0.value }.first
        } else {
            return networkInfo.subscriberCellularProvider
        }
    }
    
    public static var radioAccessTechnologys: [String]? {
        let networkInfo = CTTelephonyNetworkInfo()
        if #available(iOS 12.0, *) {
            return networkInfo.serviceCurrentRadioAccessTechnology?.map { $0.value }
        } else if let technology = networkInfo.currentRadioAccessTechnology {
            return [technology]
        }
        return nil
    }
    
    public static var currentRadioAccessTechnology: String? {
        let networkInfo = CTTelephonyNetworkInfo()
        if #available(iOS 13.0, *),
           let identifier = networkInfo.dataServiceIdentifier {
            return networkInfo.serviceCurrentRadioAccessTechnology?[identifier]
        } else if #available(iOS 12.0, *) {
            return networkInfo.serviceCurrentRadioAccessTechnology?.map { $0.value }.first
        } else {
            return networkInfo.currentRadioAccessTechnology
        }
    }

}

extension UIDevice {
    
    public static var machine: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let machine = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
        return machine
    }
    
    public var machineType: String {
        let identifier = UIDevice.machine
        switch identifier {
        case "i386", "x86_64": return "Simulator"
        
        case "iPhone1,1": return "iPhone"
        case "iPhone1,2": return "iPhone 3G"
        case "iPhone2,1": return "iPhone 3GS"
        case "iPhone3,1", "iPhone3,2", "iPhone3,3":  return "iPhone 4"
        case "iPhone4,1":  return "iPhone 4s"
        case "iPhone5,1":  return "iPhone 5"
        case "iPhone5,2":  return "iPhone 5c (GSM+CDMA)"
        case "iPhone5,3":  return "iPhone 5c (GSM)"
        case "iPhone5,4":  return "iPhone 5c (GSM+CDMA)"
        case "iPhone6,1":  return "iPhone 5s (GSM)"
        case "iPhone6,2":  return "iPhone 5s (GSM+CDMA)"
        case "iPhone7,1":  return "iPhone 6 Plus"
        case "iPhone7,2":  return "iPhone 6"
        case "iPhone8,1":  return "iPhone 6s"
        case "iPhone8,2":  return "iPhone 6s Plus"
        case "iPhone8,4":  return "iPhone SE"
        case "iPhone9,1", "iPhone9,3":  return "iPhone 7"
        case "iPhone9,2", "iPhone9,4":  return "iPhone 7 Plus"
        case "iPhone10,1", "iPhone10,4": return "iPhone 8"
        case "iPhone10,2", "iPhone10,5": return "iPhone 8 Plus"
        case "iPhone10,3", "iPhone10,6": return "iPhone X"
        case "iPhone11,2": return "iPhone XS"
        case "iPhone11,4",  "iPhone11,6": return "iPhone XS Max"
        case "iPhone11,8": return "iPhone XR"
        case "iPhone12,1": return "iPhone 11"
        case "iPhone12,3": return "iPhone 11 Pro"
        case "iPhone12,5": return "iPhone 11 Pro Max"
        case "iPhone12,8": return "iPhone SE (2nd generation)"
        case "iPhone13,1": return "iPhone 12 mini"
        case "iPhone13,2": return "iPhone 12"
        case "iPhone13,3": return "iPhone 12 Pro"
        case "iPhone13,4": return "iPhone 12 Pro Max"
            
        case "iPad1,1":  return "iPad"
        case "iPad1,2":  return "iPad 3G"
        case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":   return "iPad 2"
        case "iPad2,5", "iPad2,6", "iPad2,7":  return "iPad Mini"
        case "iPad3,1", "iPad3,2", "iPad3,3":  return "iPad 3"
        case "iPad3,4", "iPad3,5", "iPad3,6":  return "iPad 4"
        case "iPad4,1", "iPad4,2", "iPad4,3":  return "iPad Air"
        case "iPad4,4", "iPad4,5", "iPad4,6":  return "iPad Mini 2"
        case "iPad4,7", "iPad4,8", "iPad4,9":  return "iPad Mini 3"
        case "iPad5,1", "iPad5,2":  return "iPad Mini 4"
        case "iPad5,3", "iPad5,4":  return "iPad Air 2"
        case "iPad6,3", "iPad6,4":  return "iPad Pro 9.7"
        case "iPad6,7", "iPad6,8":  return "iPad Pro 12.9"
            
        case "iPod1,1":  return "iPod Touch 1"
        case "iPod2,1":  return "iPod Touch 2"
        case "iPod3,1":  return "iPod Touch 3"
        case "iPod4,1":  return "iPod Touch 4"
        case "iPod5,1":  return "iPod Touch (5 Gen)"
        case "iPod7,1":   return "iPod Touch 6"
            
        case "AppleTV2,1":  return "Apple TV 2"
        case "AppleTV3,1","AppleTV3,2":  return "Apple TV 3"
        case "AppleTV5,3":  return "Apple TV 4"
            
        default:  return identifier
        }
    }
}
