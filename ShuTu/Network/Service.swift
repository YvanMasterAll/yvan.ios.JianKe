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
    let minCharactersCount = 3
    
    //用户名验证
    func validateUsername(_ username: String) -> Observable<Result2> {
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
    func signIn(_ username: String, _ password: String) -> Observable<Result2> {
        return ShuTuProvider2.rx.request(.login(username: username, password: password))
            .mapObject(Callback.self)
            .asObservable()
            .observeOn(MainScheduler.instance)
            .map { result in
                let code = result.code
                if code == 0 {
                    //设置 Token
                    let token = result.result!["token"] as! String
                    Environment.token = token
                    //登录通知
                    LoginStatus.onNext(LoginState.ok)
                    return Result2.ok(message: "登录成功")
                } else {
                    return Result2.failed(message: result.result!["msg"] as! String)
                }
            }
            .catchError { error in
                return .just(Error003)
            }
    }
    
}

class DebateService {
    //单例
    static let instance = DebateService()
    private init() {}
    
    //拉取 Debate
    func getDebate(pageIndex: Int) -> Observable<([Debate], Result2)> {
        return ShuTuProvider.rx.request(.debate(pageIndex: pageIndex))
            .mapArray(Debate.self)
            .asObservable()
            .observeOn(MainScheduler.instance)
            .map{ data in
                return (data, Ok001)
            }
            .catchErrorJustReturn(([], Error001))
    }
    
    //拉取回答
    func getAnswer(id: Int, pageIndex: Int, side: AnswerSide) -> Observable<([Answer], Result2)> {
        return ShuTuProvider.rx.request(.answer(id: id, pageIndex: pageIndex, side: side))
            .mapArray(Answer.self)
            .asObservable()
            .observeOn(MainScheduler.instance)
            .map{ data in
                return (data, Ok001)
            }
            .catchErrorJustReturn(([], Error001))
    }
    
    //拉取回答详情
    func getAnswerDetail(id: Int) -> Observable<(AnswerDetail, Result2)> {
        return ShuTuProvider.rx.request(.answerDetail(id: id))
            .mapObject(AnswerDetail.self)
            .asObservable()
            .observeOn(MainScheduler.instance)
            .map{ data in
                return (data, Ok001)
            }
            .catchErrorJustReturn((AnswerDetail(), Error001))
    }
    
    //拉取回答评论
    func getAnswerComment(id: Int, pageIndex: Int) -> Observable<([AnswerComment], Result2)> {
        return ShuTuProvider.rx.request(.answerComment(id: id, pageIndex: pageIndex))
            .mapArray(AnswerComment.self)
            .asObservable()
            .observeOn(MainScheduler.instance)
            .map { data in
                return (data, Ok001)
            }
            .catchErrorJustReturn(([], Error001))
    }
    
    //拉取轮播图片
    func getDebateCarousel() -> Observable<[DebateImage]>{
        return ShuTuProvider.rx.request(.carousel)
            .mapArray(DebateImage.self)
            .asObservable()
            .observeOn(MainScheduler.instance)
            .catchErrorJustReturn([])
    }
   
}

class FriendService {
    //单例
    static let instance = FriendService()
    private init() {}
    
    //拉取好友列表
    func getFriend(id: Int, pageIndex: Int) -> Observable<([Friend], Result2)> {
        return ShuTuProvider.rx.request(.friend(id: id, pageIndex: pageIndex))
            .mapArray(Friend.self)
            .asObservable()
            .observeOn(MainScheduler.instance)
            .map { data in
                return (data, Ok001)
            }
            .catchErrorJustReturn(([], Error001))
    }
    //拉取动态
    func getDynamic(id: Int, pageIndex: Int) -> Observable<([Dynamic], Result2)> {
        return ShuTuProvider.rx.request(.friendDynamic(id: id, pageIndex: pageIndex))
            .mapArray(Dynamic.self)
            .asObservable()
            .observeOn(MainScheduler.instance)
            .map { data in
                return (data, Ok001)
            }
            .catchErrorJustReturn(([], Error001))
    }
}

class TestService {
    //单例
    static let instance = TestService()
    private init() {}
    
}
