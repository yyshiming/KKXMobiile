//
//  UIViewExtension.swift
//  KKXMobile
//
//  Created by ming on 2021/5/10.
//

import UIKit

// MARK: - ======== 系统菊花动画 ========
extension UIView {
    
    /// 是否显示菊花动画
    public var kkxLoading: Bool {
        get {
            return (objc_getAssociatedObject(self, &kkxLoadingKey) as? Bool) ?? false
        }
        set {
            objc_setAssociatedObject(self, &kkxLoadingKey, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
            if newValue {
                bringSubviewToFront(kkxLoadingView)
                kkxLoadingView.startAnimating()
            } else {
                kkxLoadingView.stopAnimating()
            }
        }
    }
    
    public var kkxLoadingView: UIActivityIndicatorView {
        guard let loadingView = objc_getAssociatedObject(self, &kkxLoadingViewKey) as? UIActivityIndicatorView else {
            
            let indicatorView = UIActivityIndicatorView()
            indicatorView.backgroundColor = .clear
            if #available(iOS 13.0, *) {
                indicatorView.style = .medium
            } else {
                indicatorView.style = .gray
            }
            
            addSubview(indicatorView)
            indicatorView.stopAnimating()
            indicatorView.translatesAutoresizingMaskIntoConstraints = false
            let attributes: [NSLayoutConstraint.Attribute] = [.centerX, .centerY, .width, .height]
            for attribute in attributes {
                NSLayoutConstraint(item: indicatorView, attribute: attribute, relatedBy: .equal, toItem: self, attribute: attribute, multiplier: 1.0, constant: 0.0).isActive = true
            }
            objc_setAssociatedObject(self, &kkxLoadingViewKey, indicatorView, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return indicatorView
        }
        return loadingView
    }
}
private var kkxLoadingKey: Int8 = 0
private var kkxLoadingViewKey: Int8 = 0

extension UIView {
    
    public enum LinePosition {
        case top
        case bottom
    }
    
    /// line属性
    /// - Parameters:
    ///   - color: 颜色， 默认UIColor.kkxSeparator
    ///   - width: 宽度，默认 CGFloat.pixel
    ///   - position: 位置，top或者bottom，默认bottom
    ///   - insets: 左右边距，默认UIEdgeInsets.zero
    public func separatorLine(inset: UIEdgeInsets? = nil, color: UIColor? = nil, width: CGFloat? = nil, position: UIView.LinePosition? = nil) {
        if let newColor = color {
            kkxLineView.backgroundColor = newColor
        }
        if let newWidth = width {
            kkxLineWidth = newWidth
        }
        if let newPosition = position {
            kkxLinePosition = newPosition
        }
        if let newInset = inset {
            kkxLineInset = newInset
        }
        
        reloadSeparatorLine()
    }
    
    public var separatorLine: UIView {
        kkxLineView
    }
    
    private func reloadSeparatorLine() {
        let x = kkxLineInset.left
        var y: CGFloat
        switch kkxLinePosition {
        case .top:
            y = 0
        case .bottom:
            y = frame.height - kkxLineWidth
        }
        let width = frame.width - kkxLineInset.left - kkxLineInset.right
        kkxLineView.frame = CGRect(x: x, y: y, width: width, height: kkxLineWidth)
    }
    
    /// 自定义line
    private var kkxLineView: UIView {
        guard let lineView = objc_getAssociatedObject(self, &kkxLineViewKey) as? UIView else {
            let view = UIView()
            view.backgroundColor = UIColor.kkxSeparator
            var theSuperview: UIView = self
            if let cell = self as? UICollectionViewCell {
                theSuperview = cell.contentView
            } else if let cell = self as? UITableViewCell {
                theSuperview = cell.contentView
            } else if let cell = self as? UITableViewHeaderFooterView {
                theSuperview = cell.contentView
            }
            theSuperview.addSubview(view)
            objc_setAssociatedObject(self, &kkxLineViewKey, view, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            
            observations["frame.lineView"] = observe(\.frame, options: [.new, .old]) { (object, change) in
                guard change.newValue?.size != change.oldValue?.size else { return }
                self.reloadSeparatorLine()
            }
            
            observations["bounds.lineView"] = observe(\.bounds) { (object, change) in
                self.reloadSeparatorLine()
            }
            return view
        }
        return lineView
    }
    
    /// line宽度
    private var kkxLineWidth: CGFloat {
        get {
            let width = objc_getAssociatedObject(self, &kkxLineWidthKey) as? CGFloat
            return width ?? .pixel
        }
        set {
            objc_setAssociatedObject(self, &kkxLineWidthKey, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }
    
    /// line位置
    private var kkxLinePosition: UIView.LinePosition {
        get {
            let position = objc_getAssociatedObject(self, &kkxLinePositionKey) as? UIView.LinePosition
            return position ?? .bottom
        }
        set {
            objc_setAssociatedObject(self, &kkxLinePositionKey, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }
    
    /// line左右边距
    private var kkxLineInset: UIEdgeInsets {
        get {
            let insets = objc_getAssociatedObject(self, &kkxLineInsetKey) as? UIEdgeInsets
            return insets ?? .zero
        }
        set {
            objc_setAssociatedObject(self, &kkxLineInsetKey, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }
}
private var kkxLineWidthKey: UInt8 = 0
private var kkxLinePositionKey: UInt8 = 0
private var kkxLineInsetKey: UInt8 = 0
private var kkxLineViewKey: UInt8 = 0

// MARK: - ========  模糊视觉效果 ========
public protocol BlurVisualEffect {
    
    var kkxEffectView: UIVisualEffectView { get }
    
    /// 添加blur效果
    func blur(_ style: UIBlurEffect.Style?) -> Self
    
    /// 刷新blur style
    func reloadEffectView(_ style: UIBlurEffect.Style?)
    
    /// 生成有blur效果的view
    func blurred(_ style: UIBlurEffect.Style?) -> UIView?
}
extension UIView: BlurVisualEffect {
    
    public var kkxEffectView: UIVisualEffectView {
        guard let effectView = objc_getAssociatedObject(self, &effectViewKey) as? UIVisualEffectView else {
            let blurEffect = UIBlurEffect(style: .extraLight)
            let blurEffectView = UIVisualEffectView(effect: blurEffect)
            if #available(iOS 11.0, *) { } else {
                blurEffectView.backgroundColor = UIColor.kkxCard
            }
            objc_setAssociatedObject(self, &effectViewKey, blurEffectView, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return blurEffectView
        }
        return effectView
    }
    
    @discardableResult
    public func blur(_ style: UIBlurEffect.Style? = nil) -> Self {
        reloadEffectView(style)
        kkxEffectView.frame = bounds
        kkxEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight] // for supporting device rotation
        insertSubview(kkxEffectView, at: 0)
        clipsToBounds = true
        return self
    }
    
    public func reloadEffectView(_ style: UIBlurEffect.Style? = nil) {
        if let style = style {
            kkxEffectView.effect = UIBlurEffect(style: style)
        } else {
            var style: UIBlurEffect.Style = .extraLight
            if #available(iOS 13.0, *) {
                style = .systemThickMaterial
            }
            kkxEffectView.effect = UIBlurEffect(style: style)
        }
    }
    
    public func blurred(_ style: UIBlurEffect.Style? = nil) -> UIView? {
        let imgView = self
        self.blur(style)
        return imgView
    }
}
private var effectViewKey: UInt8 = 0

// MARK: - ======== View安全区域 ========
extension UIView {
    
    /// View安全区域
    public var kkxSafeAreaInsets: UIEdgeInsets {
        var insets: UIEdgeInsets = .zero
        if #available(iOS 11.0, *) {
            insets = safeAreaInsets
        }
        return insets
    }
}

// MARK: - ======== Add GradientLayer ========
extension UIView {
    
    private var gradientLayer: CAGradientLayer {
        guard let gradientLayer = objc_getAssociatedObject(self, &gradientLayerKey) as? CAGradientLayer else {
            let gradientLayer = CAGradientLayer()
            layer.insertSublayer(gradientLayer, at: 0)
            objc_setAssociatedObject(self, &gradientLayerKey, gradientLayer, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            
            observations["frame.gradientLayer"] = observe(\.frame, options: [.new, .old]) { (object, change) in
                guard change.newValue?.size != change.oldValue?.size else { return }
                gradientLayer.frame = object.bounds
            }
            observations["bounds.gradientLayer"] = observe(\.bounds) { (object, change) in
                gradientLayer.frame = object.bounds
            }
            return gradientLayer
        }
        return gradientLayer
    }
    
    /// 渐变颜色
    /// - Parameters:
    ///   - colors: UIColor数组
    ///   - locations: NSNumber数组
    ///   - startPoint: 默认 (0.5, 0)
    ///   - endPoint: 默认 (0.5, 1.0)
    ///   - type: 默认 axial
    /// - Returns: Self
    @discardableResult
    public func gradient(colors: [UIColor]? = nil, locations: [NSNumber]? = nil, startPoint: CGPoint = CGPoint(x: 0.5, y: 0.0), endPoint: CGPoint = CGPoint(x: 0.5, y: 1.0), type: CAGradientLayerType = .axial) -> Self {
        gradientLayer.colors = colors?.map { $0.cgColor }
        gradientLayer.locations = locations
        gradientLayer.startPoint = startPoint
        gradientLayer.endPoint = endPoint
        gradientLayer.type = type
        return self
    }
}
private var gradientLayerKey: UInt8 = 0


// MARK: - ======== Add MaskedCorner ========

public struct CornerMask : OptionSet {
    public var rawValue: Int
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
    
    public static let none     = CornerMask([])
    public static let minXMinY = CornerMask(rawValue: 1 << 0)
    public static let maxXMinY = CornerMask(rawValue: 1 << 1)
    public static let minXMaxY = CornerMask(rawValue: 1 << 2)
    public static let maxXMaxY = CornerMask(rawValue: 1 << 3)
    public static let all: CornerMask = [.minXMinY, .maxXMinY, .minXMaxY, .maxXMaxY]
}

public struct MaskedCornerConfiguration {
    
    public init(maskedCorners: CornerMask = .none, cornerRadius: CGFloat = 0, strokeWidth: CGFloat = 0, strokeColor: UIColor = .white, fillColor: UIColor = .white) {
        self.maskedCorners = maskedCorners
        self.cornerRadius = cornerRadius
        self.strokeWidth = strokeWidth
        self.strokeColor = strokeColor
        self.fillColor = fillColor
    }
    
    public var maskedCorners: CornerMask = .none
    public var cornerRadius: CGFloat = 0
    public var strokeWidth: CGFloat = 0
    public var strokeColor: UIColor = .white
    public var fillColor: UIColor = .white
}

extension UIView {
    
    /// 添加圆角
    /// - Parameter maskedObject: masked属性
    /// - Returns: Self
    @discardableResult
    public func maskedCorners(_ maskedObject: MaskedCornerConfiguration) -> Self {
        self.maskedObject = maskedObject
        updateMaskedLayerPath()
        return self
    }
    
    private var maskedCornerLayer: CAShapeLayer {
        guard let shapeLayer = objc_getAssociatedObject(self, &maskedCornerLayerKey) as? CAShapeLayer else {
            let shapeLayer = CAShapeLayer()
            objc_setAssociatedObject(self, &maskedCornerLayerKey, shapeLayer, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            
            observations["frame.maskedCornerLayer"] = observe(\.frame, options: [.new, .old]) { (object, change) in
                guard change.newValue?.size != change.oldValue?.size else { return }
                object.updateMaskedLayerPath()
            }
            
            observations["bounds.maskedCornerLayer"] = observe(\.bounds) { (object, change) in
                object.updateMaskedLayerPath()
            }
            layer.insertSublayer(shapeLayer, at: 0)
            return shapeLayer
        }
        return shapeLayer
    }
    
    private var maskedObject: MaskedCornerConfiguration? {
        get {
            objc_getAssociatedObject(self, &maskedObjectKey) as? MaskedCornerConfiguration
        }
        set {
            objc_setAssociatedObject(self, &maskedObjectKey, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }
    
    private func updateMaskedLayerPath() {
        maskedCornerLayer.frame = bounds
        guard let object = maskedObject else {
            return
        }
        let maskedCorners = object.maskedCorners
        let strokeWidth = object.strokeWidth
        let cornerRadius = object.cornerRadius
        let strokeColor = object.strokeColor
        let fillColor = object.fillColor
        
        let path = UIBezierPath()
        path.lineWidth = strokeWidth
        
        let minXMinYCenter = CGPoint(x: cornerRadius, y: cornerRadius)
        let maxXMinYCenter = CGPoint(x: frame.width - cornerRadius, y: cornerRadius)
        let maxXMaxYCenter = CGPoint(x: frame.width - cornerRadius, y: frame.height - cornerRadius)
        let minXMaxYCenter = CGPoint(x: cornerRadius, y: frame.height - cornerRadius)
        
        let minXMinYPoint: CGPoint = .zero
        let maxXMinYPoint: CGPoint = CGPoint(x: frame.width, y: 0)
        let maxXMaxYPoint: CGPoint = CGPoint(x: frame.width, y: frame.height)
        let minXMaxYPoint: CGPoint = CGPoint(x: 0, y: frame.height)
        
        let topPoint1: CGPoint = CGPoint(x: cornerRadius, y: 0)
        let topPoint2: CGPoint = CGPoint(x: frame.width - cornerRadius, y: 0)
        
        let rightPoint1: CGPoint = CGPoint(x: frame.width, y: cornerRadius)
        let rightPoint2: CGPoint = CGPoint(x: frame.width, y: frame.height - cornerRadius)
        
        let bottomPoint1: CGPoint = CGPoint(x: frame.width - cornerRadius, y: frame.height)
        let bottomPoint2: CGPoint = CGPoint(x: cornerRadius, y: frame.height)
        
        let leftPoint1: CGPoint = CGPoint(x: 0, y: frame.height - cornerRadius)
        let leftPoint2: CGPoint = CGPoint(x: 0, y: cornerRadius)
        
        path.move(to: leftPoint2)
        if maskedCorners.contains(.minXMinY) {
            path.addArc(withCenter: minXMinYCenter, radius: cornerRadius, startAngle: .pi, endAngle: .pi*3/2, clockwise: true)
        } else {
            path.addLine(to: minXMinYPoint)
            path.addLine(to: topPoint1)
        }
        
        path.addLine(to: topPoint2)
        
        if maskedCorners.contains(.maxXMinY) {
            path.addArc(withCenter: maxXMinYCenter, radius: cornerRadius, startAngle: -.pi/2, endAngle: 0, clockwise: true)
        } else {
            path.addLine(to: maxXMinYPoint)
            path.addLine(to: rightPoint1)
        }
        
        path.addLine(to: rightPoint2)

        if maskedCorners.contains(.maxXMaxY) {
            path.addArc(withCenter: maxXMaxYCenter, radius: cornerRadius, startAngle: 0, endAngle: .pi/2, clockwise: true)
        } else {
            path.addLine(to: maxXMaxYPoint)
            path.addLine(to: bottomPoint1)
        }
        
        path.addLine(to: bottomPoint2)
        
        if maskedCorners.contains(.minXMaxY) {
            path.addArc(withCenter: minXMaxYCenter, radius: cornerRadius, startAngle: .pi/2, endAngle: .pi, clockwise: true)
        } else {
            path.addLine(to: minXMaxYPoint)
            path.addLine(to: leftPoint1)
        }
        
        path.addLine(to: leftPoint2)
        
        maskedCornerLayer.strokeColor = strokeColor.cgColor
        maskedCornerLayer.fillColor = fillColor.cgColor
        maskedCornerLayer.lineWidth = strokeWidth
        maskedCornerLayer.path = path.cgPath
    }
}
private var maskedCornerLayerKey: UInt8 = 0
private var maskedObjectKey: UInt8 = 0

extension UIView {
    
    /// 转换为PDF
    public func pdfPage() -> CGPDFPage? {
        var contentSize = frame.size
        if let scrollView = self as? UIScrollView {
            contentSize = scrollView.contentSize
        }
        let printPageRenderer = PrintPageRenderer(contentSize: contentSize)
        printPageRenderer.addPrintFormatter(viewPrintFormatter(), startingAtPageAt: 0)
        
        let pageCount = printPageRenderer.numberOfPages
        let data = NSMutableData()
        UIGraphicsBeginPDFContextToData(data, printPageRenderer.paperRect, nil)
        printPageRenderer.prepare(forDrawingPages: NSMakeRange(0, pageCount))
        UIGraphicsBeginPDFPage()
        
        printPageRenderer.drawPage(at: 0, in: UIGraphicsGetPDFContextBounds())
        UIGraphicsEndPDFContext()
        
        guard let provider = CGDataProvider(data: data as CFData),
              let pdfPage = CGPDFDocument(provider)?.page(at: 1) else {
            return nil
        }
        return pdfPage
    }
    
    /// view截图
    public func screenshot() -> UIImage? {
        guard let pdfPage = pdfPage() else {
            return nil
        }
        let pageRect = pdfPage.getBoxRect(.trimBox)
        let contentSize = CGSize(width: floor(pageRect.width), height: floor(pageRect.height))
        UIGraphicsBeginImageContextWithOptions(contentSize, false, 0)
        
        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }
        
        context.setFillColor(UIColor.white.cgColor)
        context.setStrokeColor(UIColor.white.cgColor)
        context.fill(pageRect)
         
        context.saveGState()
        context.translateBy(x: 0, y: contentSize.height)
        context.scaleBy(x: 1.0, y: -1.0)
        
        context.interpolationQuality = .low
        context.setRenderingIntent(.defaultIntent)
        context.drawPDFPage(pdfPage)
        context.restoreGState()
         
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}

// MARK: - ======== Frame ========
extension UIView {
    
    public func frame(x: CGFloat? = nil, y: CGFloat? = nil, width: CGFloat? = nil, height: CGFloat? = nil) -> Self {
        var newFrame = frame
        if let newX = x {
            newFrame.origin.x = newX
        }
        if let newY = y {
            newFrame.origin.y = newY
        }
        if let newWidth = width {
            newFrame.size.width = newWidth
        }
        if let newHeight = height {
            newFrame.size.height = newHeight
        }
        frame = newFrame
        return self
    }
}

public protocol LayoutConstraintItem {
    
    var kkxLayoutItem: Any { get }
}

extension UIView: LayoutConstraintItem {
    
    public var kkxLayoutItem: Any {
        if #available(iOS 11.0, *) {
            return safeAreaLayoutGuide
        } else {
            return self
        }
    }
}

// MARK: - ======== Cell计算高度 ========
extension UIView {
    
    /// 高度计算
    ///
    ///     view中重写 kkxTotalHeight，返回view的真实高度
    @objc
    open var kkxTotalHeight: CGFloat {
        0.0
    }
}

fileprivate class PrintPageRenderer: UIPrintPageRenderer {
    
    var contentSize: CGSize
    
    init(contentSize: CGSize) {
        self.contentSize = contentSize
    }
    
    override var paperRect: CGRect {
        CGRect(origin: .zero, size: contentSize)
    }
    
    override var printableRect: CGRect {
        CGRect(origin: .zero, size: contentSize)
    }
}