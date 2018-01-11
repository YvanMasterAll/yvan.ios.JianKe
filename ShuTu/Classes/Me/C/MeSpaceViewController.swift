//
//  MeSpaceViewController.swift
//  ShuTu
//
//  Created by yiqiang on 2018/1/10.
//  Copyright © 2018年 yiqiang. All rights reserved.
//

import UIKit
import PMSuperButton

class MeSpaceViewController: UIViewController {
    
    @IBOutlet weak var thumbnail: UIImageView! {
        didSet {
            self.thumbnail.layer.cornerRadius = self.thumbnail.frame.height/2
            self.thumbnail.layer.masksToBounds = true
        }
    }
    @IBOutlet weak var button: PMSuperButton! {
        didSet {
            self.button.contentEdgeInsets.left = 8
            self.button.contentEdgeInsets.right = 8
        }
    }
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            self.tableView.tableFooterView = UIView() //消除底部视图
            self.tableView.separatorStyle = .none //消除分割线
            self.tableView.showsVerticalScrollIndicator = false
            self.tableView.showsHorizontalScrollIndicator = false
        }
    }
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
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        //隐藏导航栏
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    deinit {
        print("deinit: \(type(of: self))")
    }

}

extension MeSpaceViewController {
    //初始化
    fileprivate func setupUI() {
        //Navigation
        self.navigationItem.title = ""
        //滚动通知
        NotificationCenter.default.addObserver(self, selector: #selector(self.subScrollViewDidScroll), name: NSNotification.Name(rawValue: NotificationName1), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.subTableViewDidRefresh), name: NSNotification.Name(rawValue: NotificationName2), object: nil)
    }
    //Notification
    @objc fileprivate func subScrollViewDidScroll() {
        
    }
    @objc fileprivate func subTableViewDidRefresh(_ notification: Notification) {
        let refresh = notification.userInfo!["refresh"] as! Bool
        self.tableView.isScrollEnabled = !refresh
    }
}

extension MeSpaceViewController: UITableViewDelegate, UITableViewDataSource {
    //TableView Delegate && DataSource
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //取消选中
        tableView.deselectRow(at: indexPath, animated: true)
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return SH - 64
    }
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return false
    }
}

