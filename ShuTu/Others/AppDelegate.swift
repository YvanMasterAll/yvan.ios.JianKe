//
//  AppDelegate.swift
//  JianKe
//
//  Created by yiqiang on 2017/12/11.
//  Copyright © 2017年 yiqiang. All rights reserved.
//

import UIKit
import IQKeyboardManager
import RichEditorView
import WatchdogInspector

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    //MARK: - 成员
    var window: UIWindow?
    var tabBarNavigationController: UINavigationController!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        //创建窗口
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.backgroundColor = UIColor.white
        
        //FPS
        #if DEBUG
            TWWatchdogInspector.setEnableMainthreadStallingException(false)
            TWWatchdogInspector.setUseLogs(false)
            TWWatchdogInspector.start()
        #endif
        
        //初始化富文本编辑器
        //RichEditorView.loadResource()
        
        //启动键盘管理
        IQKeyboardManager.shared().isEnabled = true
        IQKeyboardManager.shared().shouldResignOnTouchOutside = true //点击背景隐藏键盘
        IQKeyboardManager.shared().isEnableAutoToolbar = false //隐藏工具栏
        
        //判断首次使用
        if Environment.isFirstLaunch {
            print("first launch")
        } else {
            if Environment.isFirstLaunchOfNewVersion {
                print("new version")
            } else {
                print("no version updated")
            }
        }

        //TabBar
        setupTabBar()
        
        return true
    }
    
    /// TabBar
    func setupTabBar() {
        
        //ViewControllers
        let tabBarController = UITabBarController()
        let menuNavigationController = GeneralFactory.getVCfromSb("Me", "Me") as! UINavigationController
        let debateNavigationController = GeneralFactory.getVCfromSb("Debate", "Debate") as! UINavigationController
        let friendNavigationController = GeneralFactory.getVCfromSb("Friend", "Friend") as! UINavigationController
        let dailyDebateNavigationController = GeneralFactory.getVCfromSb("DailyDebate", "DailyDebate") as! UINavigationController
        let findNavigationController = GeneralFactory.getVCfromSb("Find", "Find") as! UINavigationController
        //TabBar
        tabBarController.tabBar.tintColor = ColorPrimary
        tabBarController.tabBar.barTintColor = UIColor.white
        tabBarController.tabBar.backgroundImage = GeneralFactory.createImageWithColor(UIColor.clear)
        tabBarController.tabBar.shadowImage = GeneralFactory.createImageWithColor(UIColor.clear)
        let tabBarNavigationController = UINavigationController.init(rootViewController: tabBarController)
        tabBarController.navigationController?.setNavigationBarHidden(true, animated: false)
        tabBarController.navigationItem.backBarButtonItem = UIBarButtonItem.init(title: "", style: .plain, target: self, action: nil)
        tabBarController.viewControllers = [dailyDebateNavigationController, debateNavigationController, friendNavigationController, findNavigationController]
        //TabBars
        debateNavigationController.tabBarItem = UITabBarItem(title: "首页", image: UIImage(named: "icon_home_grey500"), selectedImage: UIImage(named: "icon_home_primary"))
        debateNavigationController.tabBarItem.setTitleTextAttributes([NSAttributedStringKey.font: UIFont.systemFont(ofSize: 11)], for: .normal)
        friendNavigationController.tabBarItem = UITabBarItem(title: "消息", image: UIImage(named: "icon_friend_grey500"), selectedImage: UIImage(named: "icon_friend_primary"))
        friendNavigationController.tabBarItem.setTitleTextAttributes([NSAttributedStringKey.font: UIFont.systemFont(ofSize: 11)], for: .normal)
        dailyDebateNavigationController.tabBarItem = UITabBarItem(title: "今日", image: UIImage(named: "icon_daily_grey500"), selectedImage: UIImage(named: "icon_daily_primary"))
        dailyDebateNavigationController.tabBarItem.setTitleTextAttributes([NSAttributedStringKey.font: UIFont.systemFont(ofSize: 11)], for: .normal)
        findNavigationController.tabBarItem = UITabBarItem(title: "发现", image: UIImage(named: "icon_find_grey500"), selectedImage: UIImage(named: "icon_find_primary"))
        findNavigationController.tabBarItem.setTitleTextAttributes([NSAttributedStringKey.font: UIFont.systemFont(ofSize: 11)], for: .normal)
        tabBarController.tabBar.frame.size = CGSize(width: SW, height: TarBarHeight)
        //Gradient
        let gradient = STGradientLayer.init(direction: .leftToRight, colors: [STColor.grey300Color().withAlphaComponent(0.5), STColor.grey300Color().withAlphaComponent(0)], cornerRadius: 0)
        tabBarController.tabBar.addGradient(gradient, frame: CGRect.init(x: 0, y: -2, width: SW, height: 2))
        //Notification - 未登录用户跳转至登录页
        self.tabBarNavigationController = tabBarNavigationController
        NotificationCenter.default.addObserver(self, selector: #selector(self.gotoLogin(_:)), name:NSNotification.Name(rawValue: NotificationName3), object: nil)
        //Show
        self.window?.rootViewController = STSlideMenuController.init(mainViewController: self.tabBarNavigationController, leftMenuViewController: menuNavigationController)
        self.window?.makeKeyAndVisible()
    }
    
    /// 跳转到登录页
    @objc fileprivate func gotoLogin(_ notification: NSNotification) {
        guard let type = (notification.userInfo!["type"] as? String) else { return }
        if type == "push" { //跳转到登录页
            let loginVC = GeneralFactory.getVCfromSb("Login", "Login") as! LoginViewController
            loginVC.isPushed = true
            self.tabBarNavigationController.pushViewController(loginVC, animated: true)
        } else if type == "hud" { //仅提示, 不跳转
            HUD.flash(HUDContentType.label("请先登录"))
        }
    }

    func applicationWillResignActive(_ application: UIApplication) {
       
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        
    }

    func applicationWillTerminate(_ application: UIApplication) {
        //删除通知
        NotificationCenter.default.removeObserver(self)
    }


}

