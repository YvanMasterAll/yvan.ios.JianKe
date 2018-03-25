//
//  ModelHelper.swift
//  ShuTu
//
//  Created by yiqiang on 2018/3/23.
//  Copyright © 2018年 yiqiang. All rights reserved.
//

import Foundation

class ModelHelper {
    
    /// 处理匿名
    public static func handleAnonymous(_ anonymous: String?) -> Bool {
        if let a = anonymous, a == "t" {
            return true
        }
        
        return false
    }
    
    /// 处理网址
    public static func handleUrl(_ url: String?) -> String? {
        //URLEncode
        if let u = url {
            return ServiceUtil.urlEncode(u)
        }
        
        return nil
    }
    
    /// 处理网页内容
    public static func handleContent(_ content: String?) -> String? {
        if let c = content {
            return ServiceUtil.updateHtmlStyle(c, nil)
        }

        return nil
    }
}
