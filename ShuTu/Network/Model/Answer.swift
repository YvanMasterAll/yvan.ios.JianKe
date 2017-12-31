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
    var debateId: Int?
    var title: String?
    var username: String?
    var thumbnail: String?
    var answer: String?
    var side: String?
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

public struct AnswerDetail: Mappable {
    
    var answerId: Int?
    var body: String?
    var css: [String]?
    
    public init(){}
    public init?(map: Map) {}
    
    public mutating func mapping(map: Map) {
        answerId <- map["answerId"]
        body <- map["body"]
        css <- map["css"]
    }
}

public struct AnswerComment: Mappable {
    
    var answerId: Int?
    var username: String?
    var thumbnail: String?
    var commment: String?
    var date: String?
    var hasTalk: Bool? //是否有二层对话
    var zan: Int?
    
    public init(){}
    public init?(map: Map) {}
    
    public mutating func mapping(map: Map) {
        answerId <- map["answerId"]
        username <- map["username"]
        thumbnail <- map["thumbnail"]
        commment <- map["comment"]
        date <- map["date"]
        hasTalk <- map["hasTalk"]
        zan <- map["zan"]
    }
    
}
