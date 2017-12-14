//
//  User.swift
//  JianKe
//
//  Created by yiqiang on 2017/12/12.
//  Copyright © 2017年 yiqiang. All rights reserved.
//

import Foundation
import ObjectMapper

public struct User : Mappable{
    
    var name: String?
    
    public init(){}
    public init?(map: Map){}
    public mutating func mapping(map: Map)
    {
        name <- map["name"]
    }
    
}
