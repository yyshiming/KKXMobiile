//
//  MainViewController.swift
//  Demo
//
//  Created by ming on 2021/5/12.
//

import UIKit

class MainViewController: KKXTableViewController {

    private enum CellType: String, CaseIterable {
        case textField
        case webView
        case choosePhoto
        case scrollView
        case stackView
    }
    
    private var dataArray: [CellType] = []
    
    override func viewDidLoad() {

        super.viewDidLoad()
        
        navigationItem.title = "KKXMobile"
        
        tableView.kkx_register(UITableViewCell.self)
        tableView.rowHeight = 44
        
        dataArray = CellType.allCases
    }
}

// MARK: - ======== UITableViewDataSource ========
extension MainViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.kkx_dequeueReusableCell(UITableViewCell.self)
        let t = dataArray[indexPath.row]
        cell.textLabel?.text = t.rawValue
        return cell
    }
}

// MARK: - ======== UITableViewDelegate ========
extension MainViewController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var controller: UIViewController?
        let t = dataArray[indexPath.row]
        switch t {
        case .textField:
            controller = TextFieldController()
        case .webView:
            let string = "https://www.baidu.com"
            if let url = URL(string: string) {
                let req = URLRequest(url: url)
                controller = KKXWebViewController(request: req)
            }
        case .choosePhoto:
            controller = PhotoViewController()
        case .scrollView:
            controller = TestScrollViewController()
        case .stackView:
            controller = StackViewController()
        }
        if let vc = controller {
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}
