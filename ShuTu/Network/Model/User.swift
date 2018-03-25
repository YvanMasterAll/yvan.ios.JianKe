//
//  User.swift
//  ShuTu
//
//  Created by yiqiang on 2018/1/22.
//  Copyright © 2018年 yiqiang. All rights reserved.
//

import Foundation
import ObjectMapper

public struct User: Mappable {
    
    var id: Int?
    var realname: String?
    var nickname: String?
    var age: Int?
    var gender: String?
    var portrait: String?
    var signature: String?
    var phone: String?
    var email: String?
    var address: String?
    var college: String?
    
    public init(){}
    public init?(map: Map) {
        
        id <- map["id"]
        realname <- map["realname"]
        nickname <- map["nickname"]
        age <- map["age"]
        gender <- map["gender"]
        portrait <- map["portrait"]
        signature <- map["signature"]
        phone <- map["phone"]
        email <- map["email"]
        address <- map["address"]
        college <- map["college"]
        
        self.portrait = ModelHelper.handleUrl(self.portrait)
    }
    
    public mutating func mapping(map: Map) {
        
        id <- map["id"]
        realname <- map["realname"]
        nickname <- map["nickname"]
        age <- map["age"]
        gender <- map["gender"]
        portrait <- map["portrait"]
        signature <- map["signature"]
        phone <- map["phone"]
        email <- map["email"]
        address <- map["address"]
        college <- map["college"]
        
        self.portrait = ModelHelper.handleUrl(self.portrait)
    }
}

public struct UserInfo: Mappable {
    
    var id: Int?
    var realname: String?
    var nickname: String?
    var age: Int?
    var gender: String?
    var portrait: String?
    var signature: String?
    var phone: String?
    var email: String?
    var address: String?
    var college: String?
    var follows: Int?
    var followtopics: Int?
    var fans: Int?
    var supports: Int?

    public init(){}
    public init?(map: Map) {
        
        id <- map["id"]
        realname <- map["realname"]
        nickname <- map["nickname"]
        age <- map["age"]
        gender <- map["gender"]
        portrait <- map["portrait"]
        signature <- map["signature"]
        phone <- map["phone"]
        email <- map["email"]
        address <- map["address"]
        college <- map["college"]
        follows <- map["follows"]
        followtopics <- map["followtopics"]
        fans <- map["fans"]
        supports <- map["supports"]
        
        self.portrait = ModelHelper.handleUrl(self.portrait)
    }
    
    public mutating func mapping(map: Map) {
        
        id <- map["id"]
        realname <- map["realname"]
        nickname <- map["nickname"]
        age <- map["age"]
        gender <- map["gender"]
        portrait <- map["portrait"]
        signature <- map["signature"]
        phone <- map["phone"]
        email <- map["email"]
        address <- map["address"]
        college <- map["college"]
        follows <- map["follows"]
        followtopics <- map["followtopics"]
        fans <- map["fans"]
        supports <- map["supports"]
        
        self.portrait = ModelHelper.handleUrl(self.portrait)
    }
}


