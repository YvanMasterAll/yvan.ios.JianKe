//
//  DebateAddNewViewController.swift
//  ShuTu
//
//  Created by yiqiang on 2017/12/31.
//  Copyright © 2017年 yiqiang. All rights reserved.
//

import UIKit

class DebateAddNewViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        //隐藏导航栏
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    deinit {
        print("deinit: \(type(of: self))")
    }

}

extension DebateAddNewViewController {
    //初始化
    fileprivate func setupUI() {
        
    }
}
