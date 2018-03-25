//
//  Const.swift
//  JianKe
//
//  Created by yiqiang on 2017/12/11.
//  Copyright © 2017年 yiqiang. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

/// 常量

//MARK: - 尺寸
let SW = UIScreen.main.bounds.size.width
let SH = UIScreen.main.bounds.size.height
let TarBarHeight: CGFloat = 40

//MARK: - 版本信息
let AppVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String

//MARK: - 颜色
let ColorPrimary = UIColor(rgb: 0x0f88eb) //主色
let ColorSecondary = UIColor(rgb: 0x000000) //第二主色
let ColorSupport = UIColor(rgb: 0x000000) //辅助颜色
let ColorDot = UIColor(rgb: 0x000000) //点睛色

//MARK: - 信号
public enum ErrorCode: Int {
    case ok = 0
    case exists = 2
    case error = 99
    var code: Int {
        return self.rawValue
    }
}
public enum ResultType {
    case none
    case ok(message: String)
    case empty
    case failed(message: String)
    case exist
}
extension ResultType {
    var isVaild: Bool {
        switch self {
        case .ok:
            return true
        default:
            return false
        }
    }
}
let ErrorFailed = ResultType.failed(message: "失败")
let ErrorInvalidInput = ResultType.failed(message: "输入不合法")
let ErrorRequestFailed = ResultType.failed(message: "网络请求失败")
let OkSuccess = ResultType.ok(message: "成功")

//MARK: - 通知
let NotificationName3 = "GotoLoginVCNotification"
public enum AppState {
    case none //未知状态
    case logout //登出状态
    case login //登录状态
    case userinfo //更新用户信息
    case userinfo_part //局部更新用户信息, 关注数, 不清求网络
}
let AppStatus = PublishSubject<AppState>()
public enum TableState {
    case headTop
    case headBottom
    case headMid
    case canParentScroll
    case noParentScroll
    case none
}
let TableStatus = PublishSubject<TableState>()
let SonTableStatus = PublishSubject<TableState>()

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
 



