//
//  Result.swift
//  ShuTu
//
//  Created by yiqiang on 2018/1/22.
//  Copyright © 2018年 yiqiang. All rights reserved.
//

import Foundation
import ObjectMapper

public struct Callback: Mappable {
    
    var code: Int!
    var result: [String: Any]?
    
    public init(){}
    public init?(map: Map) {}
    
    public mutating func mapping(map: Map) {
        code <- map["code"]
        result <- map["result"]
    }
}

