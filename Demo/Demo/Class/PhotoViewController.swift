//
//  PhotoViewController.swift
//  Demo
//
//  Created by ming on 2021/5/28.
//

import UIKit

class PhotoViewController: KKXViewController {

    private let imageView = UIImageView()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        navigationItem.title = "选择照片"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "选择", style: .done, target: self, action: #selector(chooseAction))
        
        imageView.backgroundColor = .kkxPlaceholder
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.frame = CGRect(x: 0, y: 0, width: 200, height: 200)
        imageView.center = CGPoint(x: view.bounds.midX, y: view.bounds.midY)
        view.addSubview(imageView)
        
    }
    
    @objc
    private func chooseAction() {
        
        selectPhoto { [weak self] info in
            self?.imageView.image = info[.originalImage] as? UIImage
        }
    }
}
