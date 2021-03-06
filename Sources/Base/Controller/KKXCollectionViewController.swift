//
//  KKXCollectionViewController.swift
//  KKXMobile
//
//  Created by ming on 2021/5/10.
//

import UIKit

private let cellIdentifier = "UICollectionViewCell"
private let reusableIdentifier = "UICollectionReusableView"

open class KKXCollectionViewController: KKXViewController, UICollectionViewDelegateFlowLayout {

    public var collectionViewLayout: UICollectionViewLayout {
        _collectionViewLayout
    }
    
    open var collectionView: UICollectionView! {
        get { _collectionView }
        set {
            _collectionView.removeFromSuperview()
            _collectionView = newValue
            view.addSubview(newValue)
            reloadViewConstraints()
        }
    }
    
    private var _collectionViewLayout = UICollectionViewLayout()
    
    private var _collectionView: UICollectionView!
    
    convenience init() {
        let layout = UICollectionViewFlowLayout()
        self.init(collectionViewLayout: layout)
    }
    
    public init(collectionViewLayout layout: UICollectionViewLayout) {
        super.init(nibName: nil, bundle: nil)
        _collectionViewLayout = layout
        _collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = defaultConfiguration.mainBackground

        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: cellIdentifier)
        collectionView.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: reusableIdentifier)
        collectionView.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: reusableIdentifier)
        
        if collectionView.superview == nil {
            view.addSubview(collectionView)
        }
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.alwaysBounceVertical = true
        
        reloadViewConstraints()
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addKeyboardObserver()
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeKeyboardObserver()
    }
    
    private func reloadViewConstraints() {
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        let attributes: [NSLayoutConstraint.Attribute] = [
            .top, .left, .bottom, .right
        ]
        for attribute in attributes {
            NSLayoutConstraint(item: collectionView!, attribute: attribute, relatedBy: .equal, toItem: view, attribute: attribute, multiplier: 1.0, constant: 0).isActive = true
        }
    }
}

// MARK: - ======== UICollectionViewDataSource ========
extension KKXCollectionViewController: UICollectionViewDataSource {
    
    open func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    
    open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 0
    }

    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath)
    
        // Configure the cell
        if traitCollection.forceTouchCapability == .available {
            registerForPreviewing(with: self, sourceView: cell)
        }
        
        return cell
    }
    
    open func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        return collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: reusableIdentifier, for: indexPath)
    }
}

// MARK: - ======== UIViewControllerPreviewingDelegate ========
extension KKXCollectionViewController: UIViewControllerPreviewingDelegate {
    
    public func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        return previewingController(previewingContext)
    }
    
    public func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        if let cell = previewingContext.sourceView as? UICollectionViewCell,
            let indexPath = collectionView.indexPath(for: cell) {
            collectionView.delegate?.collectionView?(collectionView, didSelectItemAt: indexPath)
        }
    }
}

extension KKXCollectionViewController: KKXKeyboardShowHide {
    
    public var aScrollView: UIScrollView {
        _collectionView
    }
}

extension KKXCollectionViewController: KKXAdjustmentBehavior {
    
    public var kkxAdjustsScrollViewInsets: Bool {
        get {
            if #available(iOS 11.0, *) {
                return collectionView.contentInsetAdjustmentBehavior != .never
            }
            else {
                return automaticallyAdjustsScrollViewInsets
            }
        }
        set {
            if #available(iOS 11.0, *) {
                collectionView.contentInsetAdjustmentBehavior = newValue ? .automatic:.never
            }
            else {
                automaticallyAdjustsScrollViewInsets = newValue
            }
        }
    }
}
