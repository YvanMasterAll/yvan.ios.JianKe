//
//  Friend.swift
//  ShuTu
//
//  Created by yiqiang on 2018/1/4.
//  Copyright © 2018年 yiqiang. All rights reserved.
//

import Foundation
import ObjectMapper

public struct Friend: Mappable {
    
    var id: Int?
    var userid: Int?
    var username: String?
    var thumbnail: String?
    var sign: String?

    public init(){}
    public init?(map: Map) {}
    
    public mutating func mapping(map: Map) {
        id <- map["id"]
        userid <- map["userid"]
        username <- map["username"]
        thumbnail <- map["thumbnail"]
        sign <- map["sign"]
    }
}

public struct Dynamic: Mappable {
    
    var userid: Int?
    var topicid: Int?
    var vpid: Int?
    var category: String?
    var status: String?
    var type: String?
    var content: String?
    var stand: String?
    var title: String?
    var nickname: String?
    var portrait: String?
    var createtime: String?
    
    public init(){}
    public init?(map: Map) {}
    
    public mutating func mapping(map: Map) {
        userid <- map["userid"]
        topicid <- map["topicid"]
        vpid <- map["vpid"]
        category <- map["category"]
        status <- map["status"]
        type <- map["type"]
        content <- map["content"]
        stand <- map["stand"]
        title <- map["title"]
        nickname <- map["nickname"]
        portrait <- map["portrait"]
        createtime <- map["createtime"]
    }
}
