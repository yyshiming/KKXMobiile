//
//  KKXTextView.swift
//  KKXMobile
//
//  Created by ming on 2021/5/28.
//

import UIKit

open class KKXTextView: UITextView {
    
    // MARK: -------- Properties --------
        
    public var placeholder: String? {
        didSet {
            placeholderLabel.text = placeholder
            setNeedsLayout()
        }
    }
    
    public var placeholderLabel: UILabel = UILabel()
    
    open override var font: UIFont? {
        get {
            return super.font
        }
        set {
            super.font = newValue
            placeholderLabel.font = newValue
            
        }
    }
    
    open override var textAlignment: NSTextAlignment {
        get {
            return super.textAlignment
        }
        set {
            super.textAlignment = newValue
            placeholderLabel.textAlignment = newValue
            setNeedsLayout()
        }
    }
    
    private var kkxPlaceholderText: UIColor {
        if #available(iOS 13.0, *) {
            return .placeholderText
        } else {
            return UIColor(red: 60.0/255.0, green: 60.0/255.0, blue: 67.0/255.0, alpha: 0.3)
        }
    }
    
    // MARK: -------- Init --------
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UITextView.textDidChangeNotification, object: nil)
        removeObserver(self, forKeyPath: #keyPath(text), context: nil)
    }
    
    public override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        configurations()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configurations()
    }
    
    // MARK: -------- Helper --------
    
    private func configurations() {
        
        placeholderLabel.numberOfLines = 0
        placeholderLabel.textColor = kkxPlaceholderText
        placeholderLabel.font = font
        addSubview(placeholderLabel)
        
        textContainerInset = UIEdgeInsets(top: 5.0, left: 5.0, bottom: 5.0, right: 5.0)
        textContainer.lineFragmentPadding = 0
        
        NotificationCenter.default.addObserver(self, selector: #selector(textDidChanged(_:)), name: UITextView.textDidChangeNotification, object: self)
        addObserver(self, forKeyPath: #keyPath(text), options: .new, context: nil)
    }
    
    // MARK: -------- Actions --------
    
    @objc private func textDidChanged(_ sender: Notification) {
        placeholderLabel.isHidden = !text.isEmpty
    }
    
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        switch keyPath {
        case #keyPath(text):
            placeholderLabel.isHidden = !text.isEmpty
        default:
            break
        }
    }
    
    // MARK: -------- Layout --------
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        var left: CGFloat = textContainerInset.left
        let right: CGFloat = textContainerInset.right
        placeholderLabel.frame.size.width = frame.width - left - right
        placeholderLabel.sizeToFit()
        
        if textAlignment == .right {
            left = frame.width - right - placeholderLabel.frame.width
        } else if textAlignment == .center {
            left = (frame.width - placeholderLabel.frame.width)/2
        }
        let maxHeight = frame.height - textContainerInset.top - textContainerInset.bottom
        placeholderLabel.frame.size.height = min(maxHeight, placeholderLabel.frame.height)
        placeholderLabel.frame.origin = CGPoint(x: left, y: textContainerInset.top)
    }
    
}
