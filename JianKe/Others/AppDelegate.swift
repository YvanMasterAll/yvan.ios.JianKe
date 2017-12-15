//
//  AppDelegate.swift
//  JianKe
//
//  Created by yiqiang on 2017/12/11.
//  Copyright © 2017年 yiqiang. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        //创建窗口
        self.window = UIWindow(frame: UIScreen.main.bounds)
        
        //测试 - 清空存储信息
        //Environment.clear()
        
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
        let tabBarController = UITabBarController()
        tabBarController.tabBar.backgroundColor = UIColor.white
        //ViewControllers
        let homeStoryBoard = UIStoryboard(name: "Home", bundle: nil)
        let homeViewController = homeStoryBoard.instantiateViewController(withIdentifier: "Home")
        tabBarController.viewControllers = [homeViewController]
        //TabBars
        homeViewController.tabBarItem = UITabBarItem(title: "排行榜", image: UIImage(named: "home_grey600"), selectedImage: UIImage(named: "home_primary"))
        tabBarController.tabBar.frame.size = CGSize(width: SW, height: TarBarHeight)
        //TabBar Top Shadow
        tabBarController.tabBar.layer.shadowOffset = CGSize(width: 0, height: 0)
        tabBarController.tabBar.layer.shadowColor = GMColor.grey600Color().cgColor
        tabBarController.tabBar.layer.shadowOpacity = 0.5
        tabBarController.tabBar.layer.shadowRadius = 2
        let path = UIBezierPath(roundedRect: CGRect(x: 0, y: -2, width: SW, height: 2), cornerRadius: 0)
        tabBarController.tabBar.layer.shadowPath = path.cgPath
        
        self.window?.rootViewController = tabBarController
        self.window?.makeKeyAndVisible()
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
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

