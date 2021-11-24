//
//  MainViewController.swift
//  Demo
//
//  Created by ming on 2021/5/10.
//

import UIKit

private enum CellType: String, CaseIterable {
    case textField
    case webView
    case choosePhoto
    case scrollView
}
class MainViewController: KKXTableViewController {

    private var dataArray: [CellType] = []
    
    override func viewDidLoad() {

        super.viewDidLoad()
        // Do any additional setup after loading the view.

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
        let t = dataArray[indexPath.row]
        switch t {
        case .textField:
            navigationController?.pushViewController(FirstViewController(), animated: true)
        case .webView:
            
            let controller = KKXWebViewController(url: URL(string: "https://h5.shop.yzvet.com/static/html/pc.html"))
            navigationController?.pushViewController(controller, animated: true)
        case .choosePhoto:
            navigationController?.pushViewController(PhotoViewController(), animated: true)
        case .scrollView:
            let controller = TestScrollViewController()
            navigationController?.pushViewController(controller, animated: true)
        }
    }
}

