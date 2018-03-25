//
//  debate.swift
//  JianKe
//
//  Created by yiqiang on 2017/12/15.
//  Copyright © 2017年 yiqiang. All rights reserved.
//

import Foundation
import ObjectMapper

public struct Debate: Mappable {
    
    var id: Int?
    var portrait: String?
    var description: String?
    var puredesc: String?
    var content: String?
    var supports: Int?
    var opposes: Int?
    var follows: Int?
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
        id <- map["id"]
        portrait <- map["portrait"]
        opposes <- map["opposes"]
        supports <- map["supports"]
        follows <- map["follows"]
        title <- map["title"]
        type <- map["type"]
        status <- map["status"]
        userid <- map["userid"]
        description <- map["description"]
        content <- map["content"]
        cover_image <- map["cover_image"]
        createtime <- map["createtime"]
        
        self.cover_image = ModelHelper.handleUrl(self.cover_image)
        self.portrait = ModelHelper.handleUrl(self.portrait)
        self.description = ModelHelper.handleContent(description)
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
        id <- map["id"]
        topicid <- map["topicid"]
        title <- map["title"]
        description <- map["description"]
        opposes <- map["opposes"]
        supports <- map["supports"]
        createtime <- map["createtime"]
        status <- map["status"]
        
        self.description = ModelHelper.handleContent(description)
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
