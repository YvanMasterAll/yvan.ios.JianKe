//
//  news.swift
//  JianKe
//
//  Created by yiqiang on 2017/12/15.
//  Copyright © 2017年 yiqiang. All rights reserved.
//

import Foundation
import ObjectMapper

public struct News: Mappable{
    
    var date: String?
    var stories: [NewsStory]?
    
    public init(){}
    public init?(map: Map){}
    
    public mutating func mapping(map: Map)
    {
        date <- map["date"]
        stories <- map["stories"]
    }
}

public struct NewsStory: Mappable {
    
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

public struct NewsImage: Mappable {
    
    var id: Int?
    var image: String?
    
    public init(){}
    public init?(map: Map) {}
    
    public mutating func mapping(map: Map) {
        id <- map["id"]
        image <- map["image"]
    }
}
