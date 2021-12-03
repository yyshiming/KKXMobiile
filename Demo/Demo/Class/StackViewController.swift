//
//  StackViewController.swift
//  Demo
//
//  Created by ming on 2021/12/3.
//

import UIKit

class StackViewController: KKXViewController {

    private let firstView = UIView()
    
    private var firstHeightConstraint: NSLayoutConstraint?
    
    private var didChanged = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "StackView"
        navigationBarConfiguration = .background()
        
        let rightItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(rightItemAction))
        navigationItem.rightBarButtonItem = rightItem
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.distribution = .fill
        view.addSubview(stackView)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20.0).isActive = true
        
        firstView.translatesAutoresizingMaskIntoConstraints = false
        firstView.backgroundColor = .red
        stackView.addArrangedSubview(firstView)
        firstView.widthAnchor.constraint(equalToConstant: 200.0).isActive = true
        firstHeightConstraint = firstView.heightAnchor.constraint(equalToConstant: 44.0)
        firstHeightConstraint?.isActive = true
        
        let secondView = UIView()
        secondView.translatesAutoresizingMaskIntoConstraints = false
        secondView.backgroundColor = .green
        stackView.addArrangedSubview(secondView)
        secondView.widthAnchor.constraint(equalToConstant: 200.0).isActive = true
        secondView.heightAnchor.constraint(equalToConstant: 80.0).isActive = true
    }
    
    @objc private func rightItemAction() {
        if didChanged {
            firstHeightConstraint?.constant = 44.0
        } else {
            firstHeightConstraint?.constant = 80.0
        }
        didChanged.toggle()
    }
}
