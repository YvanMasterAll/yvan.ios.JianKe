//
//  debate.swift
//  JianKe
//
//  Created by yiqiang on 2017/12/15.
//  Copyright © 2017年 yiqiang. All rights reserved.
//

import Foundation
import ObjectMapper

public struct Debate: Mappable{
    
    var portrait: String?
    var description: String?
    var puredesc: String?
    var content: String?
    var supports: Int?
    var opposes: Int?
    var follows: Int?
    var id: Int?
    var title: String?
    var type: String?
    var status: String?
    var userid: Int?
    var cover_image: String?
    var createtime: String?
    
    public init(){}
    public init?(map: Map){}
    
    public mutating func mapping(map: Map)
    {
        portrait <- map["portrait"]
        opposes <- map["opposes"]
        supports <- map["supports"]
        follows <- map["follows"]
        id <- map["id"]
        title <- map["title"]
        type <- map["type"]
        status <- map["status"]
        userid <- map["userid"]
        description <- map["description"]
        content <- map["content"]
        cover_image <- map["cover_image"]
        createtime <- map["createtime"]
    }
}

public struct DebateCollect: Mappable {
    
    var id: Int?
    var topicid: Int?
    var title: String?
    var description: String?
    var supports: Int?
    var opposes: Int?
    var createtime: String?
    var status: String?
    
    public init(){}
    public init?(map: Map){}
    
    public mutating func mapping(map: Map)
    {
        opposes <- map["opposes"]
        supports <- map["supports"]
        id <- map["id"]
        title <- map["title"]
        status <- map["status"]
        topicid <- map["topicid"]
        description <- map["description"]
        createtime <- map["createtime"]
    }
}

public struct DebateImage: Mappable {
    
    var id: Int?
    var image: String?
    
    public init(){}
    public init?(map: Map) {}
    
    public mutating func mapping(map: Map) {
        id <- map["id"]
        image <- map["image"]
    }
}
