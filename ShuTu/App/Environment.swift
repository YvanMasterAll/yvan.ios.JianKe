//
//  Environment.swift
//  JianKeq
//
//  Created by yiqiang on 2017/12/11.
//  Copyright © 2017年 yiqiang. All rights reserved.
//

import Foundation

struct Environment {
    
    static var searchHistory: [String]? {
        get {
            return self.userDefaults.value(forKey: UserDefaultsKeys.History.rawValue) as! [String]?
        }
        set {
            self.userDefaults.setValue(newValue, forKey: UserDefaultsKeys.History.rawValue)
        }
    }
    
    static func addHistory(_ history: String) {
        if self.searchHistory == nil {
            self.userDefaults.setValue([history], forKey: UserDefaultsKeys.History.rawValue)
        } else {
            var histories = self.searchHistory!
            histories.insert(history, at: 0)
            if histories.count > 8 { //超过 8 条记录将会清理掉最后一条记录
                histories.removeLast()
            }
            self.userDefaults.setValue(histories, forKey: UserDefaultsKeys.History.rawValue)
        }
    }
    
    static func removeHistory(_ index: Int) {
        guard var histoies = self.searchHistory else { return }
        histoies.remove(at: index)
        self.searchHistory = histoies
    }
    
    static var searchHot: [String]? {
        get {
            return self.userDefaults.value(forKey: UserDefaultsKeys.Hot.rawValue) as! [String]?
        }
        set {
            self.userDefaults.setValue(newValue, forKey: UserDefaultsKeys.Hot.rawValue)
        }
    }
    
    static func addHot(_ hot: String) {
        if self.searchHistory == nil {
            self.userDefaults.setValue([hot], forKey: UserDefaultsKeys.Hot.rawValue)
        } else {
            var hots = self.searchHistory!
            hots.insert(hot, at: 0)
            if hots.count > 8 { //超过 8 条记录将会清理掉最后一条记录
                hots.removeLast()
            }
            self.userDefaults.setValue(hots, forKey: UserDefaultsKeys.Hot.rawValue)
        }
    }
    
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
        case History = "search_history"
        case Hot = "search_hot"
    }
}
