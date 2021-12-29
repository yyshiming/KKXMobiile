//
//  SecondViewController.swift
//  Demo
//
//  Created by ming on 2021/12/2.
//

import UIKit

class SecondViewController: KKXScrollViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "SecondView"
        navigationBarConfiguration = .background()
        
        view.kkxEmptyDataView.titleLabel?.text = "还没有数据"
        view.kkxShowEmptyDataView = true
        view.kkxLoading = true
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
