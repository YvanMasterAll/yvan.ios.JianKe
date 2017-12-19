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
    
    static var firstLaunch: String? {
        get {
            return self.userDefaults.value(forKey: UserDefaultsKeys.Launch.rawValue) as! String?
        }
        set {
            self.userDefaults.setValue(newValue, forKey: UserDefaultsKeys.Launch.rawValue)
        }
    }
    
    static var isFirstLaunch: Bool {
        guard let _ = firstLaunch else {
            //存储版本信息
            firstLaunch = "[\(Date.toString())] \(AppVersion)"
            version = AppVersion
            return true
        }
        return false
    }
    
    static var version: String? {
        get {
            return self.userDefaults.value(forKey: UserDefaultsKeys.Version.rawValue) as! String?
        }
        set {
            self.userDefaults.setValue(newValue, forKey: UserDefaultsKeys.Version.rawValue)
        }
    }
    
    static var isFirstLaunchOfNewVersion: Bool {
        guard let lastVersion = version else {
            return false
        }
        //判断版本更细
        if lastVersion != AppVersion {
            //存储当前版本
            version = AppVersion
            return true
        }
        
        return false
    }
    
    static func clear() {
        self.userDefaults.removeObject(forKey: UserDefaultsKeys.Token.rawValue)
    }
    
    private static let userDefaults: UserDefaults = UserDefaults.standard
    
    private enum UserDefaultsKeys: String {
        case Token = "user_auth_token"
        case Authorization = "user_auth"
        case Launch = "app_launch"
        case Version = "app_version"
    }
}
