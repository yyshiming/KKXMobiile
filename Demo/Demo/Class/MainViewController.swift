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
        let t = dataArray[indexPath.row]
        switch t {
        case .textField:
            navigationController?.pushViewController(TextFieldViewController(), animated: true)
        case .webView:
            
            let string = "https://h5.shop.yzvet.com"
//            let string = "http://192.168.0.112:8080/"
            let controller = KKXWebViewController(url: URL(string: string))
            controller.showRefreshItem = true
            controller.isShowToolBar = false
            
            let token = "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJhdWQiOlsiZGVtby1vYXV0aDIiLCJvYXV0aDItcmVzb3VyY2UiLCJyZXNvdXJjZS0xIiwibXktb2F1dGgyIl0sInVzZXJfbmFtZSI6IjEzODMzMDMxNTg0Iiwic2NvcGUiOlsicmVhZCJdLCJleHAiOjE2MzkyNzU1MzgsImF1dGhvcml0aWVzIjpbIm5ld3Nfbm90aWNlX2VkaXQiLCJjb3Vyc2VfY2xhc3NfbGVhcm4iLCJzdHVfaG9tZXdvcmtfZGVsIiwiUk9MRV9DTEFTU1JPT00iLCJjbGFzc19jb3Vyc2VfZGVsIiwic3R1X3Blb3BsZV9hZGQiLCJjb3Vyc2Vfdm9pY2VfbGlzdCIsInN0dV9wZW9wbGVfZGVsIiwic3R1X2hvbWV3b3JrX2NoZWNrIiwic3R1X3Blb3BsZV9lZGl0IiwiUk9MRV9VU0VSIiwic3R1X2hvbWV3b3JrX2xpc3QiLCJhbGxfbGlzdCIsImNvdXJzZV9jYXRhbG9nX2xpc3QiLCJzdHVfaG9tZXdvcmtfYWRkIiwic3R1X2NsYXNzX2FkZCIsInN0dV9kYXRhX3N0YXRpc3RpY3MiLCJhZGRfY2xhc3Nfc3R1IiwibmV3c19ub3RpY2VfYWRkIiwic3R1X2FnZW50X2FkZCIsImNvdXJzZV92aWRlb19saXN0IiwiY2xhc3NfY291cnNlX2FkZCIsInN0dV9zdGFfdXBkYXRlIiwic3R1X2FnZW50X2VkaXQiLCJzdHVfY2xhc3NfY291cnNlIiwic3R1X2NsYXNzX2VkaXQiLCJuZXdzX25vdGljZV9kZWwiLCJjbGFzc19jb3Vyc2VfZWRpdCIsInN0dV9jbGFzc19kZWwiLCJjbGFzc19zdHVfZGVsIiwiY2xhc3NfZXhwb3J0X2xlYXJuIiwiY2xhc3Nfc3R1X2xpc3QiLCJzdHVfcmVnaXN0X3RhYmxlIiwic3R1X3Blb3BsZV9jaGVjayIsInN0dV9ob21ld29ya19lZGl0Il0sImp0aSI6Ijc5OGU4ZWI3LTgxMjktNGUxYS1hYmFhLTA2Njc3N2M0Zjk5MyIsImNsaWVudF9pZCI6ImZyb250ZW5kLWNsaWVudDIiLCJ1c2VybmFtZSI6IjEzODMzMDMxNTg0In0.TuZ2wfn7qg6y37Qzdk-wdhCf27rbyOml54x67t1fThtRpDTg0iz2DIzmTIOfPnwiIuRydXzXtEtPvRbBhY6TPzR0cZ2Ou0_JLeGxFOSsR1RX8ldWRG2JwVBfooVv0uFB7PVaBkcFhLqmmzVJ7aFcXMk7kiY8Kxu4ZL2VX4epnok-9_MqebzMeH12HWM89SBT2xzzg6IY3szrRs3km9n48FZstc2ZtJebiHsK85kGIVWeLCV217UpS3P3vmNLxNIgZ6t2Fsi5lG6kvzCrm_YICfPgjA_vDa7H--YY2yUh8kEP0ChU7FQRtDmZWD4DMFYCekg95d9XA3-vFGkTcSk6vA"
            controller.cookies = ["access_token": token, "UID": "iOS"]
            navigationController?.pushViewController(controller, animated: true)
        case .choosePhoto:
            navigationController?.pushViewController(PhotoViewController(), animated: true)
        case .scrollView:
            let controller = TestScrollViewController()
            navigationController?.pushViewController(controller, animated: true)
        }
    }
}
