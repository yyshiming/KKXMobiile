//
//  FirstViewController.swift
//  Demo
//
//  Created by ming on 2021/5/12.
//

import UIKit

class FirstViewController: KKXViewController, KKXCustomSearchView {

    private let moveView = UIView()
    
    private let textField = UITextField()
    
    private var viewHidden = false

    override func viewDidLoad() {
        super.viewDidLoad()
            
        navigationItem.title = "TextField"
                
        moveView
            .maskedCorners(MaskedCornerConfiguration(maskedCorners: [.minXMinY, .maxXMinY], cornerRadius: 20.0, fillColor: UIColor.lightGray))
            .separatorLine(inset: UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10), color: UIColor.red, width: 2, position: .bottom)

        view.addSubview(moveView)
        moveView.frame = CGRect(x: 20, y: 100, width: 100, height: 100)
        
        
        let gradientView = UIView()
        gradientView.gradient(colors: [UIColor.red, UIColor.green, UIColor.blue])
        view.addSubview(gradientView)
        gradientView.frame = CGRect(x: moveView.frame.maxX + 10, y: moveView.frame.minY, width: 100, height: 100)
        
        let rightView = UIImageView()
        rightView.image = UIImage.itemImage()
        
        view.addSubview(textField)
        textField.frame = CGRect(x: 40, y: moveView.frame.maxY + 30, width: 200, height: 35)
        textField.borderStyle = .roundedRect
        textField.onTextChanged { newText in
            print("textField text did changed: ", newText)
        }
        textField.inputAccessoryView = inputAccessoryBar
        textField.rightView = rightView
        textField.rightViewMode = .always
        
        let textView = UITextView()
        textView.layer.borderWidth = 1.0
        textView.layer.borderColor = UIColor.kkxPlaceholder.cgColor
        view.addSubview(textView)
        
        textView.onTextChanged { newText in
            print("textView text did changed: ", newText)
        }
        .placeholder(text: "写点什么吧写点什么吧写点什么吧写点什么吧写点什么吧", textColor: .kkxPlaceholder, alignment: .left)
        textView.font = .systemFont(ofSize: 15)
        textView.frame = CGRect(x: 40, y: textField.frame.maxY + 30, width: 200, height: 80)
    }
}
