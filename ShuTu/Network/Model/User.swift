//
//  User.swift
//  ShuTu
//
//  Created by yiqiang on 2018/1/22.
//  Copyright © 2018年 yiqiang. All rights reserved.
//

import Foundation
import ObjectMapper

public struct User: Mappable {
    
    var userid: Int?
    var username: String?
    
    public init(){}
    public init?(map: Map) {}
    
    public mutating func mapping(map: Map) {
        userid <- map["userid"]
        username <- map["username"]
    }
}
