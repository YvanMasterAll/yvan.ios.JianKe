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
    
    var id: Int?
    var thumbnail: String?
    var title: String?
    var desc: String?
    var yc: Int?
    var sc: Int?
    
    public init(){}
    public init?(map: Map){}
    
    public mutating func mapping(map: Map)
    {
        id <- map["id"]
        thumbnail <- map["thumbnail"]
        title <- map["title"]
        desc <- map["desc"]
        yc <- map["yc"]
        sc <- map["sc"]
    }
}

public struct DebateStory: Mappable {
    
    var id: Int?
    var images: [String]?
    var type: Int?
    var ga_prefix: String?
    var title: String?
    
    public init(){}
    public init?(map: Map){}
    
    public mutating func mapping(map: Map)
    {
        id <- map["id"]
        images <- map["images"]
        type <- map["type"]
        ga_prefix <- map["ga_prefix"]
        title <- map["title"]
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
