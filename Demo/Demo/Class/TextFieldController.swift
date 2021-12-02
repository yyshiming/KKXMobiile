//
//  TextFieldController.swift
//  Demo
//
//  Created by ming on 2021/12/2.
//

import UIKit

class TextFieldController: KKXViewController, KKXCustomSearchView, AccessoryBarDelegate, DatePickerDelegate {

    private let moveView = UIView()
    
    private let textField = UITextField()
    
    private var viewHidden = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(Bundle.main.bundleIdentifier ?? "")
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
        textField.inputView = kkxDatePicker
        textField.inputAccessoryView = inputAccessoryBar
        textField.rightView = rightView
        textField.rightViewMode = .always
        
        let textView = KKXTextView()
        textView.layer.borderWidth = 1.0
        textView.layer.borderColor = UIColor.kkxPlaceholder.cgColor
        view.addSubview(textView)
        textView.maxVisibleLine = 4

        textView
            .onIntrinsicSizeChanged { _ in
                UIView.animate(withDuration: 0.25) {
                    self.view.layoutIfNeeded()
                }
            }
            .placeholder(text: "写点什么吧写点什么吧写点什么吧写点什么吧写点什么吧")
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -300.0).isActive = true
        textView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        textView.widthAnchor.constraint(equalToConstant: 200.0).isActive = true
    }

}
