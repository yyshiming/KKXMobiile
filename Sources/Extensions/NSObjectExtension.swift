//
//  NSObjectExtension.swift
//  KKXMobile
//
//  Created by ming on 2021/5/10.
//

import UIKit

// MARK: - ======== InputDelegate ========
public protocol InputDelegate: AnyObject {
    
    var inputResponders: [UIView?] { get }
    
    func inputCancelButtonAction()
    
    func inputWillFocusPreviousStep()
    func inputDidFocusPreviousStep()
    
    func inputWillFocusNextStep()
    func inputDidFocusNextStep()
    
    func inputDoneButtonAction()
    func inputDatePickerValueChanged(_ datePicker: UIDatePicker)
}

extension InputDelegate {
    public var inputResponders: [UIView?] { [] }
    
    public func inputCancelButtonAction() { }
    
    public func inputWillFocusPreviousStep() { }
    public func inputDidFocusPreviousStep() { }
    
    public func inputWillFocusNextStep() { }
    public func inputDidFocusNextStep() { }
    
    public func inputDoneButtonAction() { }
    public func inputDatePickerValueChanged(_ datePicker: UIDatePicker) { }
}

public enum InputAccessoryBarStyle {
    /// 取消  完成
    case `default`
    
    /// 完成
    case done
    
    /// 上一个 下一个  完成
    case stepArrow
    case stepText
}

extension NSObject {
    
    private weak var kkxInputDelegate: InputDelegate? {
        return self as? InputDelegate
    }
    
    /// UITextField().inputView = datePicker
    public var datePicker: UIDatePicker {
        if let datePicker = objc_getAssociatedObject(self, &datePickerKey) as? UIDatePicker {
            return datePicker
        }
        else {
            // 设置最小、最大时间
            /*
             let maximumDate = Date()
             let calendar = Calendar.current
             let dateComponents = DateComponents(year: -100, month: 1 - calendar.component(.month, from: maximumDate), day: 1 - calendar.component(.day, from: maximumDate))
             let minimumDate = calendar.date(byAdding: dateComponents, to: maximumDate)
             picker.maximumDate = maximumDate
             picker.minimumDate = minimumDate
             
             /// 年月
             datePicker.datePickerMode = UIDatePicker.Mode(rawValue: 4269)!
             */
            
            let datePicker = UIDatePicker()
            datePicker.datePickerMode = .date
            datePicker.addTarget(self, action: #selector(kkxValueChanged(_:)), for: .valueChanged)
            if #available(iOS 13.4, *) {
                datePicker.preferredDatePickerStyle = .wheels
//                datePicker.frame.size.height = 410
            }
            objc_setAssociatedObject(self, &datePickerKey, datePicker, .OBJC_ASSOCIATION_RETAIN)
            return datePicker
        }
    }
    
    /// UITextField().inputAccessoryView = inputAccessoryBar
    public var inputAccessoryBar: UIToolbar {
        if let bar = objc_getAssociatedObject(self, &inputAccessoryBarKey) as? UIToolbar {
            return bar
        }
        else {
            let bar = UIToolbar(frame: CGRect(x: 0.0, y: 0.0, width: UIScreen.main.bounds.size.width, height: 44.0))
            bar.tintColor = .kkxAccessoryBar
            objc_setAssociatedObject(self, &inputAccessoryBarKey, bar, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            accessoryBarStyle = .stepArrow
            return bar
        }
    }
    
    public var accessoryBarStyle: InputAccessoryBarStyle {
        get {
            let style = objc_getAssociatedObject(self, &inputAccessoryBarStyleKey) as? InputAccessoryBarStyle
            return style ?? .default
        }
        set {
            switch newValue {
            case .default:
                let flexibleSpaceItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
                inputAccessoryBar.items = [inputCancelItem, flexibleSpaceItem, inputDoneItem]
            case .done:
                let flexibleSpaceItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
                inputAccessoryBar.items = [flexibleSpaceItem, inputDoneItem]
            case .stepArrow:
                let flexibleSpaceItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
                let fixedSpaceItem = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
                fixedSpaceItem.width = 10
                
                let upConfiguration = UIImage.ItemConfiguration(direction: .up, lineWidth: 2.0, tintColor: .kkxAccessoryBar, width: 10)
                let downConfiguration = UIImage.ItemConfiguration(direction: .down, lineWidth: 2.0, tintColor: .kkxAccessoryBar, width: 10)
                let upImage = UIImage.itemImage(with: upConfiguration)
                let downImage = UIImage.itemImage(with: downConfiguration)
                
                previousStepItem.image = upImage
                previousStepItem.title = nil
                nextStepItem.image = downImage
                nextStepItem.title = nil
                inputAccessoryBar.items = [previousStepItem, fixedSpaceItem, nextStepItem, flexibleSpaceItem, inputDoneItem]
            case .stepText:
                let flexibleSpaceItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
                previousStepItem.image = nil
                previousStepItem.title = KKXExtensionString("previous.step")
                nextStepItem.image = nil
                nextStepItem.title = KKXExtensionString("next.step")
                inputAccessoryBar.items = [previousStepItem, nextStepItem, flexibleSpaceItem, inputDoneItem]
            }
            objc_setAssociatedObject(self, &inputAccessoryBarStyleKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    public var kkxFirstResponder: UIView? {
        get {
            let responder = objc_getAssociatedObject(self, &theFirstResponderKey) as? UIView
            return responder
        }
        set {
            objc_setAssociatedObject(self, &theFirstResponderKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    public var inputCancelItem: UIBarButtonItem {
        guard let item = objc_getAssociatedObject(self, &inputCancelItemKey) as? UIBarButtonItem else {
            let item = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(kkxInputCancelAction))
            objc_setAssociatedObject(self, &inputCancelItemKey, item, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return item
        }
        return item
    }
    
    public var previousStepItem: UIBarButtonItem {
        guard let item = objc_getAssociatedObject(self, &previousStepItemKey) as? UIBarButtonItem else {
            let item = UIBarButtonItem(title: KKXExtensionString("previous.step"), style: .plain, target: self, action: #selector(kkxPreviousStepAction))
            item.tintColor = .kkxAccessoryBar
            objc_setAssociatedObject(self, &previousStepItemKey, item, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return item
        }
        return item
    }
    
    public var nextStepItem: UIBarButtonItem {
        guard let item = objc_getAssociatedObject(self, &nextStepItemKey) as? UIBarButtonItem else {
            let item = UIBarButtonItem(title: KKXExtensionString("next.step"), style: .plain, target: self, action: #selector(kkxNextStepAction))
            item.tintColor = .kkxAccessoryBar
            objc_setAssociatedObject(self, &nextStepItemKey, item, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return item
        }
        return item
    }
    
    public var inputDoneItem: UIBarButtonItem {
        guard let item = objc_getAssociatedObject(self, &rinputDoneItemKey) as? UIBarButtonItem else {
            let item = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(kkxDoneAction))
            objc_setAssociatedObject(self, &rinputDoneItemKey, item, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return item
        }
        return item
    }
    
    // MARK: -------- Actions --------
    
    public func kkxFocusPreviousResponder() {
        if let responder = kkxFirstResponder,
            responder.isFirstResponder,
            let inputResponders = kkxInputDelegate?.inputResponders,
            let index = inputResponders.firstIndex(of: responder),
            index > 0 {
            
            inputResponders[index - 1]?.becomeFirstResponder()
        }
    }
    
    public func kkxFocusNextResponder() {
        if let responder = kkxFirstResponder,
            responder.isFirstResponder,
            let inputResponders = kkxInputDelegate?.inputResponders,
            let index = inputResponders.firstIndex(of: responder) {
            
            if index < inputResponders.count - 1 {
                inputResponders[index + 1]?.becomeFirstResponder()
            } else if index == inputResponders.count - 1 {
                inputResponders[index]?.resignFirstResponder()
            }
        }
    }
    
    @objc private func kkxInputCancelAction() {
        if let view = self as? UIView {
            view.endEditing(true)
        } else if let viewController = self as? UIViewController {
            viewController.view.endEditing(true)
        }
        kkxInputDelegate?.inputCancelButtonAction()
    }
    
    @objc private func kkxPreviousStepAction() {
        kkxInputDelegate?.inputWillFocusPreviousStep()
        kkxFocusPreviousResponder()
        kkxInputDelegate?.inputDidFocusPreviousStep()
    }
    
    @objc private func kkxNextStepAction() {
        kkxInputDelegate?.inputWillFocusNextStep()
        kkxFocusNextResponder()
        kkxInputDelegate?.inputDidFocusNextStep()
    }
    
    @objc private func kkxDoneAction() {
        if let view = self as? UIView {
            view.endEditing(true)
        } else if let viewController = self as? UIViewController {
            viewController.view.endEditing(true)
        }
        kkxFirstResponder = nil
        kkxInputDelegate?.inputDoneButtonAction()
    }
    
    @objc private func kkxValueChanged(_ datePicker: UIDatePicker) {
        kkxInputDelegate?.inputDatePickerValueChanged(datePicker)
    }
    
}
private var datePickerKey: UInt8 = 0
private var inputAccessoryBarKey: UInt8 = 0
private var inputAccessoryBarStyleKey: UInt8 = 0
private var theFirstResponderKey: UInt8 = 0
private var inputCancelItemKey: UInt8 = 0
private var previousStepItemKey: UInt8 = 0
private var nextStepItemKey: UInt8 = 0
private var rinputDoneItemKey: UInt8 = 0


// MARK: - ======== Observations ========

extension NSObject {
    
    public var observations: [String: NSKeyValueObservation] {
        get {
            guard let observations = objc_getAssociatedObject(self, &observationsKey) as? [String: NSKeyValueObservation] else {
                let value: [String: NSKeyValueObservation] = [:]
                objc_setAssociatedObject(self, &observationsKey, value, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                return value
            }
            return observations
        }
        set {
            objc_setAssociatedObject(self, &observationsKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}
private var observationsKey: UInt8 = 0


// MARK: - ======== deinitLog ========

extension NSObject {

    public func kkxDeinitLog() {
        kkxPrint(NSStringFromClass(self.classForCoder) + " deinit")
    }
}


// MARK: - ======== KeyboardShow\Hide ========

public struct KeybordObserverType: OptionSet {
    
    public let rawValue: Int
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
    
    public static var none     = KeybordObserverType(rawValue: 0)
    public static var willShow = KeybordObserverType(rawValue: 1 << 0)
    public static var didShow  = KeybordObserverType(rawValue: 1 << 1)
    public static var willHide = KeybordObserverType(rawValue: 1 << 2)
    public static var didHide  = KeybordObserverType(rawValue: 1 << 3)
    
    public static let all: KeybordObserverType = [.willShow, .didShow, .willHide, .didHide]
}

extension NSObject {
    
    public func kkx_addKeyboardObserver(_ observerType: KeybordObserverType = [.willShow, .willHide]) {
        if observerType.contains(.willShow) {
            NotificationCenter.default.addObserver(self, selector: #selector(kkx_keyboardWillShow(_:)), name: UIView.keyboardWillShowNotification, object: nil)
        }
        if observerType.contains(.didShow) {
            NotificationCenter.default.addObserver(self, selector: #selector(kkx_keyboardDidShow(_:)), name: UIView.keyboardDidShowNotification, object: nil)
        }
        if observerType.contains(.willHide) {
            NotificationCenter.default.addObserver(self, selector: #selector(kkx_keyboardWillHide(_:)), name: UIView.keyboardWillHideNotification, object: nil)
        }
        if observerType.contains(.didHide) {
            NotificationCenter.default.addObserver(self, selector: #selector(kkx_keyboardDidHide(_:)), name: UIView.keyboardDidHideNotification, object: nil)
        }
    }
    
    public func kkx_removeKeyboardObserver(_ observerType: KeybordObserverType = [.willShow, .willHide]) {
        if observerType.contains(.willShow) {
            NotificationCenter.default.removeObserver(self, name: UIView.keyboardWillShowNotification, object: nil)
        }
        if observerType.contains(.didShow) {
            NotificationCenter.default.removeObserver(self, name: UIView.keyboardDidShowNotification, object: nil)
        }
        if observerType.contains(.willHide) {
            NotificationCenter.default.removeObserver(self, name: UIView.keyboardWillHideNotification, object: nil)
        }
        if observerType.contains(.didHide) {
            NotificationCenter.default.removeObserver(self, name: UIView.keyboardDidHideNotification, object: nil)
        }
    }
    
    @objc open func kkx_keyboardWillShow(_ sender: Notification) {
        
    }
    
    @objc open func kkx_keyboardDidShow(_ sender: Notification) {
        
    }
    
    @objc open func kkx_keyboardWillHide(_ sender: Notification) {
        
    }
    
    @objc open func kkx_keyboardDidHide(_ sender: Notification) {
        
    }
}

/// 存储计时信息的对象，可以在代理方法里面设置button标题
///
///     let button = UIButton(type: .custom)
///     button.timerObject.timerCount = 60
///     button.timerDelegate = self
///     button.startTimer()
public class TimerObject {
    
    /// 计时秒数，默认 60
    public var timerCount: Int = 60 {
        didSet {
            currentCount = timerCount
        }
    }
    
    /// 定时器当前数值
    public fileprivate(set) var currentCount: Int = 60
    /// 定时器是否倒计时中
    public fileprivate(set) var isCountDown: Bool = false
    
    public fileprivate(set) var isTiming: Bool = false
    
    fileprivate var timer: Timer?
    
    /// 继续
    public func resume() {
        if timer?.isValid == true, !isTiming {
            isTiming = true
            timer?.fireDate = Date()
        }
    }
    
    /// 暂停
    public func pause() {
        if timer?.isValid == true {
            isTiming = false
            timer?.fireDate = Date.distantFuture
        }
    }
    
    /// 销毁定时器
    fileprivate func invalidateTimer() {
        isCountDown = false
        isTiming = false
        timer?.invalidate()
        timer = nil
        currentCount = timerCount
    }
    
    deinit {
        invalidateTimer()
    }
}

public protocol TimerDelegate: AnyObject {
        
    /// 存储计时信息的对象
    var timerObject: TimerObject { get }
    
    /// 开始计时
    func startTimer(willRunning: ((TimerDelegate) -> Void)?, onRunning: ((TimerDelegate, Int) -> Void)?, onStop: ((TimerDelegate) -> Void)?)
}

extension TimerDelegate {
        
    public var timerObject: TimerObject {
        guard let obj = objc_getAssociatedObject(self, &timerObjectKey) as? TimerObject else {
            let obj = TimerObject()
            objc_setAssociatedObject(self, &timerObjectKey, obj, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return obj
        }
        return obj
    }
    
    public func startTimer(willRunning: ((TimerDelegate) -> Void)? = nil, onRunning: ((TimerDelegate, Int) -> Void)? = nil, onStop: ((TimerDelegate) -> Void)? = nil) {

        if timerObject.isCountDown {
            return
        }

        onRunningHandler = onRunning
        onStopHandler = onStop

        timerObject.invalidateTimer()
        timerObject.isCountDown = true
        timerObject.isTiming = true
        willRunning?(self)

        let timer = Timer.kkxTimer(timeInterval: 1.0, repeats: true, block: { [weak self](timer) in
            self?.timerFired(timer)
        })
        RunLoop.current.add(timer, forMode: .common)
        timerObject.timer = timer

        onRunningHandler?(self, timerObject.currentCount)
    }
    
    private func timerFired(_ timer: Timer) {
        
        timerObject.currentCount -= 1
        guard timerObject.currentCount > 0 else {
            timerObject.invalidateTimer()
            onStopHandler?(self)
            return
        }
        onRunningHandler?(self, timerObject.currentCount)
    }
    
    private var onRunningHandler: ((Self, Int) -> Void)? {
        get {
            objc_getAssociatedObject(self, &onRunningHandlerKey) as? (Self, Int) -> Void
        }
        set {
            objc_setAssociatedObject(self, &onRunningHandlerKey, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }
    
    private var onStopHandler: ((Self) -> Void)? {
        get {
            objc_getAssociatedObject(self, &onStopHandlerKey) as? (Self) -> Void
        }
        set {
            objc_setAssociatedObject(self, &onStopHandlerKey, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }
}
private var timerObjectKey: UInt8 = 0
private var onRunningHandlerKey: UInt8 = 0
private var onStopHandlerKey: UInt8 = 0
