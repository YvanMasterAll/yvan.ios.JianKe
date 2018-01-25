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

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    var tabBarNavigationController: UINavigationController!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        //创建窗口
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.backgroundColor = UIColor.white
        //FPS 监听
        #if DEBUG
            GDPerformanceMonitor.sharedInstance.startMonitoring()
        #endif
        
        //初始化富文本编辑器
        RichEditorView.loadResource()
        
        //启动键盘管理
        IQKeyboardManager.shared().isEnabled = true
        IQKeyboardManager.shared().shouldResignOnTouchOutside = true //点击背景隐藏键盘
        IQKeyboardManager.shared().isEnableAutoToolbar = false //隐藏工具栏
        
        //测试 - 清空存储信息
        Environment.clear()
        
        //判断首次启动
        if Environment.isFirstLaunch {
            print("first launch")
        } else {
            if Environment.isFirstLaunchOfNewVersion {
                print("new version")
            } else {
                print("no version updated")
            }
        }

        //初始化 TabBar
        setupTabBar()
        
        //判断用户登录
//        if !Environment.tokenExists {
//            let LoginStoryBoard = UIStoryboard(name: "Login", bundle: nil)
//            let loginViewController = LoginStoryBoard.instantiateViewController(withIdentifier: "Login")
//            self.window?.rootViewController?.present(loginViewController, animated: false, completion: nil)
//        }
        
        return true
    }
    
    //初始化 TabBar
    func setupTabBar() {
        //MenuViewController
        let menuStoryboard = UIStoryboard.init(name: "Me", bundle: nil)
        let menuNavigationController = menuStoryboard.instantiateViewController(withIdentifier: "Me") as! UINavigationController
        //Tabbar Controller
        let tabBarController = UITabBarController()
        tabBarController.tabBar.tintColor = ColorPrimary
        tabBarController.tabBar.barTintColor = UIColor.white
        tabBarController.tabBar.backgroundImage = GeneralFactory.createImageWithColor(UIColor.clear)
        tabBarController.tabBar.shadowImage = GeneralFactory.createImageWithColor(UIColor.clear)
        //ViewControllers
        let debateStoryBoard = UIStoryboard(name: "Debate", bundle: nil)
        let friendStoryBoard = UIStoryboard(name: "Friend", bundle: nil)
        let dailyDebateStoryBoard = UIStoryboard(name: "DailyDebate", bundle: nil)
        let findStoryBoard = UIStoryboard(name: "Find", bundle: nil)
        let debateNavigationController = debateStoryBoard.instantiateViewController(withIdentifier: "Debate") as! UINavigationController
        let friendNavigationController = friendStoryBoard.instantiateViewController(withIdentifier: "Friend") as! UINavigationController
        let dailyDebateNavigationController = dailyDebateStoryBoard.instantiateViewController(withIdentifier: "DailyDebate") as! UINavigationController
        let findNavigationController = findStoryBoard.instantiateViewController(withIdentifier: "Find") as! UINavigationController
        tabBarController.viewControllers = [dailyDebateNavigationController, debateNavigationController, friendNavigationController, findNavigationController]
        //TabBars
        debateNavigationController.tabBarItem = UITabBarItem(title: "首页", image: UIImage(named: "icon_home_grey500"), selectedImage: UIImage(named: "icon_home_primary"))
//        debateNavigationController.tabBarItem.imageInsets.top = -4
//        debateNavigationController.tabBarItem.titlePositionAdjustment.vertical = -2
        debateNavigationController.tabBarItem.setTitleTextAttributes([NSAttributedStringKey.font: UIFont.systemFont(ofSize: 11)], for: .normal)
        friendNavigationController.tabBarItem = UITabBarItem(title: "消息", image: UIImage(named: "icon_friend_grey500"), selectedImage: UIImage(named: "icon_friend_primary"))
//        friendNavigationController.tabBarItem.imageInsets.top = -4
//        friendNavigationController.tabBarItem.titlePositionAdjustment.vertical = -2
        friendNavigationController.tabBarItem.setTitleTextAttributes([NSAttributedStringKey.font: UIFont.systemFont(ofSize: 11)], for: .normal)
        dailyDebateNavigationController.tabBarItem = UITabBarItem(title: "今日", image: UIImage(named: "icon_daily_grey500"), selectedImage: UIImage(named: "icon_daily_primary"))
//        dailyDebateNavigationController.tabBarItem.imageInsets.top = -4
//        dailyDebateNavigationController.tabBarItem.titlePositionAdjustment.vertical = -2
        dailyDebateNavigationController.tabBarItem.setTitleTextAttributes([NSAttributedStringKey.font: UIFont.systemFont(ofSize: 11)], for: .normal)
        findNavigationController.tabBarItem = UITabBarItem(title: "发现", image: UIImage(named: "icon_find_grey500"), selectedImage: UIImage(named: "icon_find_primary"))
        findNavigationController.tabBarItem.setTitleTextAttributes([NSAttributedStringKey.font: UIFont.systemFont(ofSize: 11)], for: .normal)
        tabBarController.tabBar.frame.size = CGSize(width: SW, height: TarBarHeight)
        //TabBar Top Shadow
//        tabBarController.tabBar.layer.shadowOffset = CGSize(width: 0, height: 0)
//        tabBarController.tabBar.layer.shadowColor = GMColor.grey500Color().cgColor
//        tabBarController.tabBar.layer.shadowOpacity = 0.5
//        tabBarController.tabBar.layer.shadowRadius = 1
//        let path = UIBezierPath(roundedRect: CGRect(x: 0, y: -0.5, width: SW, height: 0.5), cornerRadius: 0)
//        tabBarController.tabBar.layer.shadowPath = path.cgPath
        let gradient = GradientLayer.init(direction: .leftToRight, colors: [GMColor.grey300Color().withAlphaComponent(0.5), GMColor.grey300Color().withAlphaComponent(0)], cornerRadius: 0)
        tabBarController.tabBar.addGradient(gradient, frame: CGRect.init(x: 0, y: -2, width: SW, height: 2))
        //TabBar NavigaitonController
        let tabBarNavigationController = UINavigationController.init(rootViewController: tabBarController)
        tabBarController.navigationController?.setNavigationBarHidden(true, animated: false)
        tabBarController.navigationItem.backBarButtonItem = UIBarButtonItem.init(title: "", style: .plain, target: self, action: nil)
        
        //添加通知, 用户未登录时发起需要登录后的操作, 将会转到登录界面
        self.tabBarNavigationController = tabBarNavigationController
        NotificationCenter.default.addObserver(self, selector: #selector(self.gotoLogin(_:)), name:NSNotification.Name(rawValue: NotificationName3), object: nil)
        
        self.window?.rootViewController = SlideMenuController.init(mainViewController: self.tabBarNavigationController, leftMenuViewController: menuNavigationController)
        self.window?.makeKeyAndVisible()
    }
    
    @objc fileprivate func gotoLogin(_ notification: NSNotification) {
        guard let type = (notification.userInfo!["type"] as? String) else { return }
        if type == "push" { //跳转
            let loginStoryboard = UIStoryboard.init(name: "Login", bundle: nil)
            let loginVC = loginStoryboard.instantiateViewController(withIdentifier: "Login") as! LoginViewController
            loginVC.isPushed = true
            
            self.tabBarNavigationController.pushViewController(loginVC, animated: true)
        } else if type == "hud" { //提示
            HUD.flash(HUDContentType.label("请先登录"))
        }
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        //删除通知
        NotificationCenter.default.removeObserver(self)
    }


}

