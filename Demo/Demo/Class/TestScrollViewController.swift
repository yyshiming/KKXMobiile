//
//  TestScrollViewController.swift
//  Demo
//
//  Created by ming on 2021/7/15.
//

import UIKit

class TestScrollViewController: KKXScrollViewController {
    
    override func loadView() {
        super.loadView()
    }
    
    override func viewDidLoad() {
        navigationBarConfiguration = .background()
        super.viewDidLoad()
        

        scrollView.contentInset = UIEdgeInsets(bottom: 15)
        scrollView.backgroundColor = .green
        
        /// 设置contentView固定高度
        contentView.heightAnchor.constraint(equalToConstant: 1000).isActive = true

        let textField = UITextField()
        textField.borderStyle = .roundedRect
        contentView.addSubview(textField)
        
        textField.frame = CGRect(x: 0, y: 1000 - 45, width: 300, height: 35)
        textField.center.x = view.frame.width / 2
        
        
        
//        if #available(iOS 13.0, *) {
//            let newAppearance = UINavigationBarAppearance()
//            newAppearance.backgroundColor = .red
//            newAppearance.shadowImage = UIImage()
//            newAppearance.shadowColor = nil
//            newAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
//            newAppearance.configureWithTransparentBackground()
//            navigationItem.standardAppearance = newAppearance
//            navigationItem.scrollEdgeAppearance = newAppearance
//        }
    }
}
