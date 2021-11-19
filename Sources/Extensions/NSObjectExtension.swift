//
//  NSObjectExtension.swift
//  KKXMobile
//
//  Created by ming on 2021/5/10.
//

import UIKit

// MARK: - ======== InputDelegate ========

public protocol InputDelegate: NSObjectProtocol {
    
    var inputResponders: [UIView?] { get }
    
    func inputCancelButtonAction()
    
    func inputWillFocusPreviousStep()
    func inputDidFocusPreviousStep()
    
    func inputWillFocusNextStep()
    func inputDidFocusNextStep()
    
    func inputDoneButtonAction()
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

// MARK: - ======== DatePickerDelegate ========

public protocol DatePickerDelegate: NSObjectProtocol {
    var kkxDatePicker: UIDatePicker { get }
    func kkxDatePickerValueChanged(_ datePicker: UIDatePicker)
}

extension DatePickerDelegate {
    /// UITextField().inputView = datePicker
    /// 年月 datePickerMode = UIDatePicker.Mode(rawValue: 4269)!
    public var kkxDatePicker: UIDatePicker {
        if let datePicker = objc_getAssociatedObject(self, &kkxDatePickerKey) as? UIDatePicker {
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
            datePicker.addTarget(kkxDatePickerHandler, action: #selector(kkxDatePickerHandler.kkxValueChanged(_:)), for: .valueChanged)
            if #available(iOS 13.4, *) {
                datePicker.preferredDatePickerStyle = .wheels
            }
            objc_setAssociatedObject(self, &kkxDatePickerKey, datePicker, .OBJC_ASSOCIATION_RETAIN)
            return datePicker
        }
    }
    
    private var kkxDatePickerHandler: DatePickerDelegateHander {
        guard let handler = objc_getAssociatedObject(self, &kkxDatePickerHandlerKey) as? DatePickerDelegateHander else {
            let newHandler = DatePickerDelegateHander(delegate: self)
            objc_setAssociatedObject(self, &kkxDatePickerHandlerKey, newHandler, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return newHandler
        }
        return handler
    }
    public func kkxDatePickerValueChanged(_ datePicker: UIDatePicker) { }
}
private var kkxDatePickerKey: UInt8 = 0
private var kkxDatePickerHandlerKey: UInt8 = 0

fileprivate class DatePickerDelegateHander: NSObject {
    
    init(delegate: DatePickerDelegate?) {
        self.delegate = delegate
    }
    weak var delegate: DatePickerDelegate?
    
    @objc func kkxValueChanged(_ datePicker: UIDatePicker) {
        delegate?.kkxDatePickerValueChanged(datePicker)
    }
}


// MARK: - ======== DatePickerDelegate ========

public enum InputAccessoryBarStyle {
    /// 取消  完成
    case `default`
    
    /// 完成
    case done
    
    /// 上一个 下一个  完成
    case stepArrow
    case stepText
}

public protocol AccessoryBarDelegate: InputDelegate {
    
    var inputAccessoryBar: UIToolbar { get }
    
    var accessoryBarStyle: InputAccessoryBarStyle { get set }
    
    var kkxFirstResponder: UIView? { get set }
    
    var inputCancelItem: UIBarButtonItem { get }
    
    var inputDoneItem: UIBarButtonItem { get }
    
    var previousStepItem: UIBarButtonItem { get }
    
    var nextStepItem: UIBarButtonItem { get }
    
    func kkxFocusPreviousResponder()
    
    func kkxFocusNextResponder()
}

extension AccessoryBarDelegate {
    
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
    
    public func kkxFocusPreviousResponder() {
        kkxAccessoryBarHandler.kkxFocusPreviousResponder()
    }
    
    public func kkxFocusNextResponder() {
        kkxAccessoryBarHandler.kkxFocusNextResponder()
    }
    
    public var inputCancelItem: UIBarButtonItem {
        guard let item = objc_getAssociatedObject(self, &inputCancelItemKey) as? UIBarButtonItem else {
            let item = UIBarButtonItem(barButtonSystemItem: .cancel, target: kkxAccessoryBarHandler, action: #selector(kkxAccessoryBarHandler.kkxInputCancelAction))
            objc_setAssociatedObject(self, &inputCancelItemKey, item, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return item
        }
        return item
    }
    
    public var inputDoneItem: UIBarButtonItem {
        guard let item = objc_getAssociatedObject(self, &inputDoneItemKey) as? UIBarButtonItem else {
            let item = UIBarButtonItem(barButtonSystemItem: .done, target: kkxAccessoryBarHandler, action: #selector(kkxAccessoryBarHandler.kkxDoneAction))
            objc_setAssociatedObject(self, &inputDoneItemKey, item, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return item
        }
        return item
    }
    
    public var previousStepItem: UIBarButtonItem {
        guard let item = objc_getAssociatedObject(self, &previousStepItemKey) as? UIBarButtonItem else {
            let item = UIBarButtonItem(title: KKXExtensionString("previous.step"), style: .plain, target: kkxAccessoryBarHandler, action: #selector(kkxAccessoryBarHandler.kkxPreviousStepAction))
            item.tintColor = .kkxAccessoryBar
            objc_setAssociatedObject(self, &previousStepItemKey, item, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return item
        }
        return item
    }
    
    public var nextStepItem: UIBarButtonItem {
        guard let item = objc_getAssociatedObject(self, &nextStepItemKey) as? UIBarButtonItem else {
            let item = UIBarButtonItem(title: KKXExtensionString("next.step"), style: .plain, target: kkxAccessoryBarHandler, action: #selector(kkxAccessoryBarHandler.kkxNextStepAction))
            item.tintColor = .kkxAccessoryBar
            objc_setAssociatedObject(self, &nextStepItemKey, item, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return item
        }
        return item
    }
    
    private var kkxAccessoryBarHandler: AccessoryBarDelegateHander {
        guard let handler = objc_getAssociatedObject(self, &kkxAccessoryBarHanderKey) as? AccessoryBarDelegateHander else {
            let newHandler = AccessoryBarDelegateHander(delegate: self)
            objc_setAssociatedObject(self, &kkxAccessoryBarHanderKey, newHandler, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return newHandler
        }
        return handler
    }
}
private var inputAccessoryBarKey: UInt8 = 0
private var inputAccessoryBarStyleKey: UInt8 = 0
private var theFirstResponderKey: UInt8 = 0
private var inputCancelItemKey: UInt8 = 0
private var inputDoneItemKey: UInt8 = 0
private var previousStepItemKey: UInt8 = 0
private var nextStepItemKey: UInt8 = 0
private var kkxAccessoryBarHanderKey: UInt8 = 0

fileprivate class AccessoryBarDelegateHander: NSObject {
    
    init(delegate: AccessoryBarDelegate?) {
        self.delegate = delegate
    }
    weak var delegate: AccessoryBarDelegate?
    
    @objc func kkxInputCancelAction() {
        if let view = delegate as? UIView {
            view.endEditing(true)
        } else if let viewController = delegate as? UIViewController {
            viewController.view.endEditing(true)
        }
        delegate?.inputCancelButtonAction()
    }
    
    @objc func kkxPreviousStepAction() {
        delegate?.inputWillFocusPreviousStep()
        kkxFocusPreviousResponder()
        delegate?.inputDidFocusPreviousStep()
    }
    
    @objc func kkxNextStepAction() {
        delegate?.inputWillFocusNextStep()
        kkxFocusNextResponder()
        delegate?.inputDidFocusNextStep()
    }
    
    @objc func kkxDoneAction() {
        if let view = delegate as? UIView {
            view.endEditing(true)
        } else if let viewController = delegate as? UIViewController {
            viewController.view.endEditing(true)
        }
        delegate?.kkxFirstResponder = nil
        delegate?.inputDoneButtonAction()
    }
    
    func kkxFocusPreviousResponder() {
        if let responder = delegate?.kkxFirstResponder,
            responder.isFirstResponder,
            let inputResponders = delegate?.inputResponders,
            let index = inputResponders.firstIndex(of: responder),
            index > 0 {
            
            inputResponders[index - 1]?.becomeFirstResponder()
        }
    }
    
    func kkxFocusNextResponder() {
        if let responder = delegate?.kkxFirstResponder,
            responder.isFirstResponder,
            let inputResponders = delegate?.inputResponders,
            let index = inputResponders.firstIndex(of: responder) {
            
            if index < inputResponders.count - 1 {
                inputResponders[index + 1]?.becomeFirstResponder()
            } else if index == inputResponders.count - 1 {
                inputResponders[index]?.resignFirstResponder()
            }
        }
    }
}

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

/// 存储计时信息的对象
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

/// 计时器代理
///
///     Class Object: NSObject, TimerDelegate { }
///     let obj = Object()
///     obj.timerObject.timerCount = 60
///     obj.startTimer()
public protocol TimerDelegate: AnyObject {
        
    /// 存储计时信息的对象
    var timerObject: TimerObject { get }
    
    /// 将要开始计时回调
    func onWillRunning(handler: @escaping (TimerDelegate) -> Void) -> Self
    /// 计时中回调
    func onRunning(handler: @escaping (TimerDelegate, Int) -> Void) -> Self
    /// 计时结束回调
    func onStoped(handler: @escaping (TimerDelegate) -> Void) -> Self
    
    /// 开始计时
    func kkxStartTimer()
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
    
    @discardableResult
    public func onWillRunning(handler: @escaping (TimerDelegate) -> Void) -> Self {
        willRunningHandler = handler
        return self
    }
    
    @discardableResult
    public func onRunning(handler: @escaping (TimerDelegate, Int) -> Void) -> Self {
        runningHandler = handler
        return self
    }
    
    @discardableResult
    public func onStoped(handler: @escaping (TimerDelegate) -> Void) -> Self {
        stopHandler = handler
        return self
    }
    
    public func kkxStartTimer() {
        if timerObject.isCountDown {
            return
        }

        timerObject.invalidateTimer()
        timerObject.isCountDown = true
        timerObject.isTiming = true
        willRunningHandler?(self)

        let timer = Timer.kkxTimer(timeInterval: 1.0, repeats: true, block: { [weak self](timer) in
            self?.timerFired(timer)
        })
        RunLoop.current.add(timer, forMode: .common)
        timerObject.timer = timer

        runningHandler?(self, timerObject.currentCount)
    }
    
    private func timerFired(_ timer: Timer) {
        
        timerObject.currentCount -= 1
        guard timerObject.currentCount > 0 else {
            timerObject.invalidateTimer()
            stopHandler?(self)
            return
        }
        runningHandler?(self, timerObject.currentCount)
    }
    
    private var willRunningHandler: ((Self) -> Void)? {
        get {
            objc_getAssociatedObject(self, &willRunningHandlerKey) as? (Self) -> Void
        }
        set {
            objc_setAssociatedObject(self, &willRunningHandlerKey, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }
    
    private var runningHandler: ((Self, Int) -> Void)? {
        get {
            objc_getAssociatedObject(self, &runningHandlerKey) as? (Self, Int) -> Void
        }
        set {
            objc_setAssociatedObject(self, &runningHandlerKey, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }
    
    private var stopHandler: ((Self) -> Void)? {
        get {
            objc_getAssociatedObject(self, &stopHandlerKey) as? (Self) -> Void
        }
        set {
            objc_setAssociatedObject(self, &stopHandlerKey, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }
}
private var timerObjectKey: UInt8 = 0
private var willRunningHandlerKey: UInt8 = 0
private var runningHandlerKey: UInt8 = 0
private var stopHandlerKey: UInt8 = 0
