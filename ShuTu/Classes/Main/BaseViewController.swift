//
//  BaseViewController.swift
//  ShuTu
//
//  Created by yiqiang on 2018/3/3.
//  Copyright © 2018年 yiqiang. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class BaseViewController: UIViewController {
    
    //声明区域
    open var hasMenu: Bool = false {
        didSet {
            
        }
    }
    open var isLogin: Bool = Environment.tokenExists
    open var showNavbar: Bool = false
    open var hideNavbar: Bool = false
    open var hideTabbar: Bool = false
    open var navBarTitle: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.baseSetupUI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if self.showNavbar {
            self.navigationItem.title = self.navBarTitle
            self.navigationItem.backBarButtonItem = UIBarButtonItem.init(title: "", style: .plain, target: self, action: nil)
            self.navigationController?.setNavigationBarHidden(false, animated: false)
        } else {
            self.navigationController?.setNavigationBarHidden(true, animated: false)
            self.navigationItem.backBarButtonItem = UIBarButtonItem.init(title: "", style: .plain, target: self, action: nil)
        }
        if self.hideTabbar {
            self.hidesBottomBarWhenPushed = true
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if self.hideNavbar {
            self.navigationController?.setNavigationBarHidden(true, animated: false)
        }
    }
    
    deinit {
        print("deinit: \(type(of: self))")
    }
    
    //显示空页面
    func showBaseEmptyView() {
        self.baseEmptyView.show(type: .empty(size: nil), frame: self.view.bounds)
    }
    func reload() { //重新加载该页面
        
    }
    //跳转到登录页
    func gotoLoginPage() {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationName3), object: nil, userInfo: ["type": "push"])
    }
    //成功登录
    func loginIn() {
        
    }
    //退出登录
    func loginOut() {
        
    }
    //应用程序状态
    func appBeActive() {
        
    }
    func appInActive() {
        
    }
    func appInBackground() {
        
    }
    
    //私有
    fileprivate var baseEmptyView: EmptyView!
    fileprivate var disposeBag = DisposeBag()

}

extension BaseViewController {
    //初始化
    fileprivate func baseSetupUI() {
        //EmptyView
        self.baseEmptyView = EmptyView.init(target: self.view)
        self.baseEmptyView.delegate = self
        //登录通知
        LoginStatus.subscribe(onNext: { [unowned self] state in
            switch state {
            case .ok:
                self.isLogin = true
                self.loginIn()
            case .out:
                self.isLogin = false
                self.loginOut()
            default:
                break
            }
        }).disposed(by: self.disposeBag)
        //应用程序状态通知
        UIApplication.shared.rx.state.asObservable()
            .subscribe(onNext: { [unowned self] state in
                switch state {
                case .active:
                    self.appBeActive()
                    break
                case .inactive:
                    self.appInActive()
                    break
                case .background:
                    self.appInBackground()
                    break
                }
            })
            .disposed(by: self.disposeBag)
    }
}

extension BaseViewController: EmptyViewDelegate {
    //EmptyViewDelegate
    func emptyViewClicked() {
        self.baseEmptyView.hide()
        self.reload()
    }
}
