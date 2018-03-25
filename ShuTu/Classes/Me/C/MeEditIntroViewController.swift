//
//  MeEditIntroViewController.swift
//  ShuTu
//
//  Created by yiqiang on 2018/1/10.
//  Copyright © 2018年 yiqiang. All rights reserved.
//

import UIKit

typealias MeEditIntroViewControllerBlock = (_ text: String) -> Void

class MeEditIntroViewController: BaseViewController {

    @IBOutlet weak var textView: STGrowingTextView!
    
    //MARK: - 声明区域
    open var signature: String!
    open var block: MeEditIntroViewControllerBlock?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //显示导航栏
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.navigationItem.title = "个人简介"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "保存", style: .plain, target: self, action: #selector(self.saveSignature))
    }
    
}

extension MeEditIntroViewController {

    //MARK: - 初始化
    fileprivate func setupUI() {
        //TextView
        self.textView.text = signature
    }
    
    /// 保存
    @objc fileprivate func saveSignature() {
        self.block?(self.textView.text!)
        self.navigationController?.popViewController(animated: true)
    }
}
