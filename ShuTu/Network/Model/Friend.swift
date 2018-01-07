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
    
    var name: String?
    var title: String?
    var content: String?
    var time: String?
    
    public init(){}
    public init?(map: Map) {}
    
    public mutating func mapping(map: Map) {
        name <- map["name"]
        title <- map["title"]
        content <- map["content"]
        time <- map["time"]
    }
}
