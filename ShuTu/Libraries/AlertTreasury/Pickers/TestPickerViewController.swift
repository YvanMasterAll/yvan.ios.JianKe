//
//  TestPickerViewController.swift
//  ShuTu
//
//  Created by yiqiang on 2018/1/25.
//  Copyright © 2018年 yiqiang. All rights reserved.
//

import UIKit

/**
 // AlertPicker 测试
 let textPickerVC = TestPickerViewController()
 let alert = UIAlertController.init(style: .alert)
 textPickerVC.preferredContentSize.height = 200
 alert.setValue(textPickerVC, forKey: "contentViewController")
 alert.show(animated: true, vibrate: true, tapDismiss: true) //tapDismiss: 点击窗口外消失
 
 优点
 @简单
 @IOS 原生组件, 兼容性毋庸置疑
 缺点
 @宽度不能定义
 @没有转场动画
 */

class TestPickerViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillLayoutSubviews() {
        
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        //绑定 XIB 文件
        Bundle(for: TestPickerViewController.self).loadNibNamed("TestPickerViewController", owner: self, options: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
