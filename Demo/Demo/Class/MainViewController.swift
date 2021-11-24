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
            let token = "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJhdWQiOlsiZGVtby1vYXV0aDIiLCJvYXV0aDItcmVzb3VyY2UiLCJyZXNvdXJjZS0xIiwibXktb2F1dGgyIl0sInVzZXJfbmFtZSI6IjE4NTExOTk1NjEyIiwic2NvcGUiOlsicmVhZCJdLCJleHAiOjE2MTk4NTc0MzYsImF1dGhvcml0aWVzIjpbIlJPTEVfVVNFUiJdLCJqdGkiOiI4OWNiMTExMS1lZWQxLTRlMGUtYTU4My01OWM1MWYxMjllODAiLCJjbGllbnRfaWQiOiJmcm9udGVuZC1jbGllbnQyIiwidXNlcm5hbWUiOiIxODUxMTk5NTYxMiJ9.JWa88AkG5zQapjJc5dp4Oo7jfZMCJrzAD2bAZ3Rvuij4Zqda9ZxY0u9pCMdPnm3tyWg-Lt_Q96EKFfZZnY3G6nKEv9d-MwDY2rCh7XbQ9AG4m2UCbUtBLdj292cvpA6ba2bC7N6a_0VUNz-YnYK0P0dyWmarIVC6XWs0w-tcdq8Y2kRq_f8__n3U1XWWRErI3A9anfug7jvMfCNyKdfNA0E9fNrGiEFswJLLrNYbsc9uB0EJ6xvy5FZPN_dRWy7E3tGD1pXoiqYdRNdldRfjHPWtD6FGfLEfWbpgN3V2G5o1i6eB6cliKMPMBxrtnqtMHph_wvXiJlIvAjy4Z9KoRQ"
            let jsString = "window.localStorage.setItem('userAgent', '\(token)');"
            
            let controller = KKXWebViewController(url: URL(string: "https://h5.shop.yzvet.com/static/html/pc.html"))
            controller.showRefreshItem = true
            controller.isShowToolBar = false
            controller.onFinished { webView in
                webView.evaluateJavaScript(jsString) { obj, error in
                    print(error)
                }
            }
            navigationController?.pushViewController(controller, animated: true)
        case .choosePhoto:
            navigationController?.pushViewController(PhotoViewController(), animated: true)
        case .scrollView:
            let controller = TestScrollViewController()
            navigationController?.pushViewController(controller, animated: true)
        }
    }
}

