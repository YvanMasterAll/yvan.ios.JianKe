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
    
    //MARK: - 声明区域
    open var isLogin: Bool = Environment.tokenExists
    open var showNavbar: Bool = false //显示导航栏
    open var hideNavbar: Bool = false //退出时隐藏导航栏
    open var hideTabbar: Bool = false //隐藏底部菜单
    open var navBarTitle: String = "" //导航栏标题
    open var hasRequested: Bool = false //成功请求过数据

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
    
    //MARK: - 显示空页面
    func showBaseEmptyView() {
        self.shouldReload = true
        self.baseEmptyView.show(type: .empty(type: .box, options: nil), frame: self.view.bounds)
    }
    func showBaseEmptyView(_ description: String?, _ type: STEVEmptyType = .vase) {
        self.shouldReload = false
        var options = STEVEmptyOptions()
        options.hasDescription = true
        if let d = description {
            options.description = d
        }
        self.baseEmptyView.show(type: .empty(type: type, options: options), frame: self.view.bounds)
    }
    func showBaseEmptyView(_ description: String?, _ deHeight: CGFloat, _ type: STEVEmptyType = .vase) {
        self.shouldReload = false
        var options = STEVEmptyOptions()
        options.hasDescription = true
        if let d = description {
            options.description = d
        }
        let width = self.view.bounds.width
        let height = self.view.bounds.height - deHeight
        self.baseEmptyView.show(type: .empty(type: type, options: options), frame: CGRect.init(origin: self.view.bounds.origin, size: CGSize.init(width: width, height: height)))
    }
    
    /// 跳转到登录页
    func gotoLoginPage() {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationName3), object: nil, userInfo: ["type": "push"])
    }
    
    /// 更新用户信息
    func userinfoRefresh(_ handler: ((_ userinfo: UserInfo) -> Void)?) {
        if self.isLogin {
            MeService.instance.userinfo().asObservable()
                .subscribe(onNext: { response in
                    let userinfo = response.0
                    let result = response.1
                    switch result {
                    case .ok:
                        if let u = userinfo {
                            handler?(u)
                            AppStatus.onNext(AppState.userinfo)
                        }
                        break
                    default:
                        break
                    }
                })
                .disposed(by: self.disposeBag)
        }
    }
    
    /// 重新加载该页面
    func reload() { }
    
    /// 成功登录
    func loginIn() { }
    
    /// 退出登录
    func logOut() { }
    
    //MARK: - 用户信息发生更新
    func userinfoUpdated() { }
    func userinfoPartUpdated() { }
    
    //MARK: - 应用程序状态
    func appBeActive() { }
    func appInActive() { }
    func appInBackground() { }
    
    //MARK: - 私有成员
    fileprivate var baseEmptyView: STEmptyView!
    fileprivate var shouldReload: Bool = true
    fileprivate var disposeBag = DisposeBag()

}

extension BaseViewController {
    
    //MARK: - 初始化
    fileprivate func baseSetupUI() {
        //EmptyView
        self.baseEmptyView = STEmptyView.init(target: self.view)
        self.baseEmptyView.delegate = self
        //登录通知
        AppStatus.subscribe(onNext: { [unowned self] state in
            switch state {
            case .login:
                self.isLogin = true
                self.loginIn()
            case .logout:
                self.isLogin = false
                self.logOut()
            case .userinfo:
                self.userinfoUpdated()
            case .userinfo_part:
                self.userinfoPartUpdated()
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

extension BaseViewController: STEmptyViewDelegate {
    
    //MARK: - EmptyViewDelegate
    func emptyViewClicked() {
        if self.shouldReload {
            self.baseEmptyView.hide()
            self.reload()
        }
    }
}
