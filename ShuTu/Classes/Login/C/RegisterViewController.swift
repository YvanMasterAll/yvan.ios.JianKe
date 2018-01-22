//
//  RegisterViewController.swift
//  ShuTu
//
//  Created by yiqiang on 2018/1/19.
//  Copyright © 2018年 yiqiang. All rights reserved.
//

import UIKit

class RegisterViewController: UIViewController {

    @IBAction func goBack(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    deinit {
        print("deinit: \(type(of: self))")
    }

}

extension RegisterViewController {
    
}
