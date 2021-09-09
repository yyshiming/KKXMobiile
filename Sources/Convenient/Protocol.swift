//
//  Protocol.swift
//  Demo
//
//  Created by ming on 2021/5/10.
//

import UIKit

/// 在ipad上运行时，右上角添加取消item的viewController需要实现的协议
public protocol KKXCustomCancelItemOnIpad: NSObjectProtocol { }

/// 自定义导航栏
public protocol KKXCustomNavBar: NSObjectProtocol { }

/// 自定义返回按钮
public protocol KKXCustomBackItem: NSObjectProtocol { }

/// 刷新数据
public protocol KKXReloadDataProtocol: NSObjectProtocol {
    func kkxReloadData(_ isRefresh: Bool)
}


public protocol KKXAdjustmentBehavior {
    var kkxAdjustsScrollViewInsets: Bool { get set }
}


/// 数据对象转字典
public protocol KKXModelToDictionary {
    
    func dictValue() -> [String: Any]
}

extension KKXModelToDictionary where Self: Encodable {
    
    public func dictValue() -> [String: Any] {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        guard let data = try? encoder.encode(self) else {
            return [:]
        }
        
        let parameters = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any]
        guard let param = parameters, !param.isEmpty else {
            return [:]
        }
        return param
    }
}


// MARK: - ======== IndexPath传参用 ========
public protocol KKXIndexPath {
    
    /// 可用于UITableViewCell、UICollectionViewCell传参数
    var kkxIndexPath: IndexPath? { get set }
}

extension KKXIndexPath {
    
    public var kkxIndexPath: IndexPath? {
        get {
            let indexPath = objc_getAssociatedObject(self, &indexPathKey) as? IndexPath
            return indexPath
        }
        set {
            objc_setAssociatedObject(self, &indexPathKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}
private var indexPathKey: UInt8 = 0


// MARK: - ======== 键盘显示/隐藏时，修改scrollView的contentInset.bottom ========
/// 键盘显示/隐藏时，修改scrollView的contentInset.bottom，使得scrollView滚动时可以显示所有内容
public protocol KKXKeyboardShowHide: NSObjectProtocol {
    
    /// scrollView，必须实现的
    var aScrollView: UIScrollView { get }
    
    /// 键盘是否显示
    var isKeyboardShow: Bool { get }
    
    /// 添加键盘监听
    func addKeyboardObserver()
    
    /// 移除键盘监听
    func removeKeyboardObserver()
}

extension KKXKeyboardShowHide {
    
    public var isKeyboardShow: Bool {
        _isKeyboardShow
    }
    
    public func addKeyboardObserver() {
        
        NotificationCenter.default.addObserver(forName: UIView.keyboardWillShowNotification, object: nil, queue: OperationQueue.main) { [weak self] note in
            guard let self = self else { return }
            if isPad { return }
            
            /// 键盘开始显示时记录scrollView的contentInset，用于隐藏时重置contentInset
            if !self._isKeyboardShow {
                self._isKeyboardShow = true
                self.previousContentInset = self.aScrollView.contentInset
            }
            
            /// 转换scrollView.frame的坐标到window
            let scrollViewRect = self.aScrollView.superview?.convert(self.aScrollView.frame, to: nil) ?? .zero
            /// 获取键盘显示后的frame
            let frame = note.userInfo?[UIView.keyboardFrameEndUserInfoKey] as? CGRect ?? .zero
            
            /// scrollView的bottom距离keyboard的top的高度
            let defferHeight = scrollViewRect.maxY - frame.minY
            /// 高度大于零时，修改scrollView.contentInset.bottom
            if defferHeight > 0 {
                let bottom = defferHeight - self.aScrollView.safeAreaInsets.bottom
                var contentInset = self.aScrollView.contentInset
                contentInset.bottom = bottom
                self.aScrollView.contentInset = contentInset
            }
        }
        
        NotificationCenter.default.addObserver(forName: UIView.keyboardWillHideNotification, object: nil, queue: OperationQueue.main) { [weak self] note in
            guard let self = self else { return }
            if isPad { return }
            
            self._isKeyboardShow = false
            self.aScrollView.contentInset = self.previousContentInset
        }
    }
    
    public func removeKeyboardObserver() {
        NotificationCenter.default.removeObserver(self, name: UIView.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIView.keyboardWillHideNotification, object: nil)
    }
    
    private var previousContentInset: UIEdgeInsets {
        get {
            let inset = objc_getAssociatedObject(self, &previousContentInsetKey) as? UIEdgeInsets
            return inset ?? .zero
        }
        set {
            objc_setAssociatedObject(self, &previousContentInsetKey, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }
    
    private var _isKeyboardShow: Bool {
        get {
            let show = objc_getAssociatedObject(self, &isKeyboardShowKey) as? Bool
            return show ?? false
        }
        set {
            objc_setAssociatedObject(self, &isKeyboardShowKey, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }
}
private var previousContentInsetKey: UInt8 = 0
private var isKeyboardShowKey: UInt8 = 0


/// 视频时长转字符串
public protocol KKXVideoDuration {
    /// 视频时长（秒）转字符串（00:00:00）
    func videoDuration() -> String
}
extension Int: KKXVideoDuration {
    public func videoDuration() -> String {
        let formater = "%.2d"
        let duration = self
        
        var durationString: String
        if duration < Int.aHour {
            let minute = duration/Int.aMinute
            let second = duration%Int.aMinute
            durationString = String(format: "\(formater):\(formater)", minute, second)
        }
        else {
            let hour = duration/Int.aHour
            let minute = duration%Int.aHour/Int.aMinute
            let second = duration%Int.aMinute
            durationString = String(format: "\(formater):\(formater):\(formater)", hour, minute, second)
        }
        return durationString
    }
}
extension Double: KKXVideoDuration {
    public func videoDuration() -> String {
        Int(self).videoDuration()
    }
}
extension Float: KKXVideoDuration {
    public func videoDuration() -> String {
        Int(self).videoDuration()
    }
}

extension CGFloat: KKXVideoDuration {
    public func videoDuration() -> String {
        Int(self).videoDuration()
    }
}
