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

class DebateService {
    //单例
    static let instance = DebateService()
    private init() {}
    
    //拉取 Debate
    func getDebate(pageIndex: Int) -> Observable<[Debate]> {
        return ShuTuProvider.rx.request(.debate(pageIndex: pageIndex))
            .mapArray(Debate.self)
            .asObservable()
            .observeOn(MainScheduler.instance)
            .catchErrorJustReturn([])
    }
    
    //拉取回答
    func getAnswer(id: Int, pageIndex: Int, side: AnswerSide) -> Observable<([Answer], Result)> {
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
    func getAnswerDetail(id: Int) -> Observable<(AnswerDetail, Result)> {
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
    func getAnswerComment(id: Int, pageIndex: Int) -> Observable<([AnswerComment], Result)> {
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

class TestService {
    //单例
    static let instance = TestService()
    private init() {}
    
}
