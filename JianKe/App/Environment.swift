//
//  Environment.swift
//  JianKeq
//
//  Created by yiqiang on 2017/12/11.
//  Copyright © 2017年 yiqiang. All rights reserved.
//

import Foundation

struct Environment {
    
    static var token: String? {
        get {
            return self.userDefaults.value(forKey: UserDefaultsKeys.Token.rawValue) as! String?
        }
        set {
            self.userDefaults.setValue(newValue, forKey: UserDefaultsKeys.Token.rawValue)
        }
    }
    
    static var tokenExists: Bool {
        guard let _ = token else {
            return false
        }
        return true
    }
    
    static func clear() {
        self.userDefaults.removeObject(forKey: UserDefaultsKeys.Token.rawValue)
    }
    
    private static let userDefaults: UserDefaults = UserDefaults.standard
    
    private enum UserDefaultsKeys: String {
        case Token = "user_auth_token"
        case Authorization = "user_auth"
    }
}
