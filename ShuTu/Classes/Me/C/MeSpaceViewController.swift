//
//  MeSpaceViewController.swift
//  ShuTu
//
//  Created by yiqiang on 2018/1/10.
//  Copyright © 2018年 yiqiang. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxGesture

class MeSpaceViewController: BaseViewController {
    
    @IBOutlet weak var followView: UIView! {
        didSet {
            let followLabel = self.followView.viewWithTag(10001) as! UILabel
            followLabel.text = "我关注了 \(userinfo.follows ?? 0) 人"
            followView.isUserInteractionEnabled = true
            followView.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(self.gotoMeJoinFP)))
        }
    }
    @IBOutlet weak var followedView: UIView! {
        didSet {
            let followedLabel = self.followedView.viewWithTag(10001) as! UILabel
            followedLabel.text = "\(userinfo.fans ?? 0) 人关注了我"
            followedView.isUserInteractionEnabled = true
            followedView.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(self.gotoMeJoinFA)))
        }
    }
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var thumbnail: UIImageView! {
        didSet {
            self.thumbnail.layer.cornerRadius = self.thumbnail.frame.height/2
            self.thumbnail.layer.masksToBounds = true
        }
    }
    @IBOutlet weak var goEditButton: STButton! {
        didSet {
            self.goEditButton.contentEdgeInsets.left = 8
            self.goEditButton.contentEdgeInsets.right = 8
            self.goEditButton.addTarget(self, action: #selector(self.gotoEdit), for: .touchUpInside)
        }
    }
    @IBOutlet weak var tableView: BaseTableView!
    
    //MARK: - 声明区域
    open var userinfo: UserInfo!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        showNavbar = true
        hideNavbar = true
        navBarTitle = ""
        setupUI()
        bindRx()
    }
    
    override func userinfoUpdated() {
        if let u = Environment.userinfo {
            self.userinfo = u
            self.setupUserInfo()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: - 私有成员
    fileprivate var disposeBag = DisposeBag()
    fileprivate var scrollDragging: Bool = false
    fileprivate var tableStatus: TableState = .headBottom
    fileprivate var canScroll: Bool = true

}

extension MeSpaceViewController {

    //MARK: - 初始化
    fileprivate func setupUI() {
        setupUserInfo()
    }
    fileprivate func setupUserInfo() {
        if let t = userinfo.portrait {
            self.thumbnail.kf.setImage(with: URL.init(string: t))
        }
        self.username.text = userinfo.nickname
    }
    fileprivate func bindRx() {
        //SonTableStatue
        SonTableStatus.asObserver()
            .subscribe(onNext: { [weak self] state in
                switch state {
                case .canParentScroll:
                    self?.canScroll = true
                case .noParentScroll:
                    self?.canScroll = false
                default:
                    break
                }
            })
            .disposed(by: self.disposeBag)
    }
    
    //MARK: - 跳转事件
    @objc fileprivate func gotoEdit() {
        let meeditVC = GeneralFactory.getVCfromSb("Me", "MeEdit") as! MeEditViewController
        meeditVC.userinfo = userinfo
        self.navigationController?.pushViewController(meeditVC, animated: true)
    }
    @objc fileprivate func gotoMeJoinFA() {
        let meJoinVC = GeneralFactory.getVCfromSb("Me", "MeJoin") as! MeJoinViewController
        meJoinVC.navTitle = "关注我的人"
        meJoinVC.type = MeJoinType.fan
        self.navigationController?.pushViewController(meJoinVC, animated: true)
    }
    @objc fileprivate func gotoMeJoinFP() {
        let meJoinVC = GeneralFactory.getVCfromSb("Me", "MeJoin") as! MeJoinViewController
        meJoinVC.navTitle = "我关注的人"
        meJoinVC.type = MeJoinType.followperson
        self.navigationController?.pushViewController(meJoinVC, animated: true)
    }
}

extension MeSpaceViewController: UITableViewDelegate, UITableViewDataSource {
    
    //MARK: - TableView Delegate && DataSource
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
        return SH
    }
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    //MARK: - ScrollView Delegate
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.scrollDragging = true
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if self.scrollDragging {
            if self.canScroll {
                let height = self.tableView.tableHeaderView!.frame.height
                let scrollOffset = scrollView.contentOffset.y
                if Int(scrollOffset) >= Int(height) {
                    self.tableView.contentOffset.y = height
                    TableStatus.onNext(.headTop)
                    tableStatus = .headTop
                } else if scrollOffset <= 0 {
                    //self.tableView.contentOffset.y = 0
                    tableStatus = .headBottom
                    TableStatus.onNext(.headBottom)
                } else {
                    TableStatus.onNext(.headMid)
                }
            } else {
                let height = self.tableView.tableHeaderView!.frame.height
                switch tableStatus {
                case .headBottom:
                    self.canScroll = true
                    self.tableView.contentOffset.y = 0
                case .headTop:
                    self.tableView.contentOffset.y = height
                default:
                    break
                }
            }
        }
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.scrollDragging = false
    }
}

