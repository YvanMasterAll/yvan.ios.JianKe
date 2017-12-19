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
let Error001 = Result.failed(message: "失败")
let Error002 = Result.failed(message: "输入不合法")
let Error003 = Result.failed(message: "网络请求失败")
let Ok001 = Result.ok(message: "成功")



