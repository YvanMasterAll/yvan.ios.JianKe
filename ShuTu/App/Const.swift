//
//  Const.swift
//  JianKe
//
//  Created by yiqiang on 2017/12/11.
//  Copyright © 2017年 yiqiang. All rights reserved.
//

import Foundation
import UIKit

//尺寸
let SW = UIScreen.main.bounds.size.width
let SH = UIScreen.main.bounds.size.height
let TarBarHeight: CGFloat = 40

//版本信息
let AppVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String

//颜色
let ColorPrimary = UIColor(rgb: 0x0f88eb) //主色
let ColorSecondary = UIColor(rgb: 0x000000) //第二主色
let ColorSupport = UIColor(rgb: 0x000000) //辅助颜色
let ColorDot = UIColor(rgb: 0x000000) //点睛色

//信号
public enum Result2 {
    case ok(message: String)
    case empty
    case failed(message: String)
}
extension Result2 {
    var isVaild: Bool {
        switch self {
        case .ok:
            return true
        default:
            return false
        }
    }
}
let Error001 = Result2.failed(message: "失败")
let Error002 = Result2.failed(message: "输入不合法")
let Error003 = Result2.failed(message: "网络请求失败")
let Ok001 = Result2.ok(message: "成功")

//通知
let NotificationName1 = "SubScrollViewDidScrollNotification" //子滚动条滚动通知
let NotificationName2 = "SubTableViewDidRefreshNotification" //子表刷新通知
let NotificationName3 = "GotoLoginVCNotification" //转到登录页面通知

//登录绑定
import RxSwift
import RxCocoa
public enum LoginState {
    case none //未知状态
    case out //登出状态
    case ok //登录状态
}
let LoginStatus = PublishSubject<LoginState>()

/*
 常用操作记录
 ----------
 
 - 未登录通知
 
 NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationName3), object: nil, userInfo: ["type": "push"]) //type: ["push", "hud"]
 
 - 显示隐藏导航栏
 
    self.navigationController?.setNavigationBarHidden(false, animated: false)
 
 - 隐藏 TabBar
 
    self.hidesBottomBarWhenPushed = true
 
 */
 



