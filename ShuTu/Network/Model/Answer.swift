//
//  Answer.swift
//  ShuTu
//
//  Created by yiqiang on 2017/12/24.
//  Copyright © 2017年 yiqiang. All rights reserved.
//

import Foundation
import ObjectMapper

public struct Answer: Mappable {
    
    var id: Int?
    var userid: Int?
    var username: String?
    var thumbnail: String?
    var answer: String?
    var ac: Int?
    var cc: Int?
    
    public init(){}
    public init?(map: Map) {}
    
    public mutating func mapping(map: Map) {
        id <- map["id"]
        userid <- map["userid"]
        username <- map["username"]
        thumbnail <- map["thumbnail"]
        answer <- map["answer"]
        ac <- map["ac"]
        cc <- map["cc"]
    }
}

