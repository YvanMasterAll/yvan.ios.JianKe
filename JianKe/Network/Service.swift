//
//  Service.swift
//  JianKe
//
//  Created by yiqiang on 2017/12/12.
//  Copyright © 2017年 yiqiang. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Moya

class UserService {
    //单例
    static let instance = UserService()
    private init() {}
    //字符长度界限
    let minCharactersCount = 6
    
    //用户名验证
    func validateUsername(_ username: String) -> Observable<Result> {
        //字符串长度检查
        if username.count == 0 {
            return .just(.empty)
        }
        if username.count < minCharactersCount {
            return .just(.empty)
        }
        
        return .just(Ok001)
    }
    
    //用户登录
    func signIn(_ username: String, _ password: String) -> Observable<Result> {
        return GithubProvider.rx.request(.Token(username: username, password: password))
            .mapObject(Auth.self)
            .asObservable()
            .observeOn(MainScheduler.instance)
            .map{ auth in
                if auth.token == nil {
                    return Error001
                } else {
                    //存储 Token
                    Environment.token = auth.token
                    return Ok001
                }
            }
            .catchError { error in
                return .just(Error001)
            }
    }
    
}
