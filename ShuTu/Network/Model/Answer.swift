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
    var topicid: Int?
    var title: String?
    var nickname: String?
    var portrait: String?
    var content: String?
    var pureanswer: String?
    var stand: String?
    var supports: Int?
    var comments: Int?
    var anonymous: String?
    var isanonymous: Bool = false
    
    public init(){}
    public init?(map: Map) {}
    
    public mutating func mapping(map: Map) {
        id <- map["vpid"]
        userid <- map["userid"]
        topicid <- map["topicid"]
        nickname <- map["nickname"]
        portrait <- map["portrait"]
        content <- map["content"]
        stand <- map["stand"]
        supports <- map["supports"]
        comments <- map["comments"]
        anonymous <- map["anonymous"]
        
        self.isanonymous = ModelHelper.handleAnonymous(anonymous)
        self.portrait = ModelHelper.handleUrl(self.portrait)
        self.content = ModelHelper.handleContent(content)
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
    
    var id: Int?
    var vpid: Int?
    var userid: Int?
    var nickname: String?
    var portrait: String?
    var commment: String?
    var type: String?
    var createtime: String?
    var supports: Int?
    var supported: Int?
    var replyed: Int?

    public init(){}
    public init?(map: Map) {}
    
    public mutating func mapping(map: Map) {
        id <- map["id"]
        vpid <- map["vpid"]
        userid <- map["userid"]
        nickname <- map["nickname"]
        portrait <- map["portrait"]
        commment <- map["content"]
        type <- map["type"]
        createtime <- map["createtime"]
        supports <- map["supports"]
        supported <- map["supported"]
        replyed <- map["replyed"]
        
        self.portrait = ModelHelper.handleUrl(self.portrait)
    }
}

public struct AnswerAttitude: Mappable {
    
    var support: Int?
    var oppose: Int?
    var bravo: Int?
    var collect: Int?
    
    public init(){}
    public init?(map: Map) {
        support <- map["support"]
        oppose <- map["oppose"]
        bravo <- map["bravo"]
        collect <- map["collect"]
    }
    
    public mutating func mapping(map: Map) {
        support <- map["support"]
        oppose <- map["oppose"]
        bravo <- map["bravo"]
        collect <- map["collect"]
    }
}
