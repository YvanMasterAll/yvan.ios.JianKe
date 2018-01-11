//
//  MeEditIntroViewController.swift
//  ShuTu
//
//  Created by yiqiang on 2018/1/10.
//  Copyright © 2018年 yiqiang. All rights reserved.
//

import UIKit

typealias MeEditIntroViewControllerBlock = (_ text: String) -> Void

class MeEditIntroViewController: UIViewController {

    @IBOutlet weak var textView: GrowingTextView!
    
    //声明区域
    open var intro: String!
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
    }
    
    deinit {
        print("deinit: \(type(of: self))")
    }
    
}

extension MeEditIntroViewController {
    //初始化
    fileprivate func setupUI() {
        //Navigation
        self.navigationItem.title = "个人简介"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "保存", style: .plain, target: self, action: #selector(self.saveIntro))
        //TextView
        self.textView.text = intro
    }
    //保存
    @objc fileprivate func saveIntro() {
        self.block?(self.textView.text!)
        self.navigationController?.popViewController(animated: true)
    }
}
