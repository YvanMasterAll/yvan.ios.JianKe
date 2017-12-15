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
    
    var id : Int?
    
    public init(){}
    public init?(map: Map){}
    
    public mutating func mapping(map: Map)
    {
        id <- map["id"]
    }
}
