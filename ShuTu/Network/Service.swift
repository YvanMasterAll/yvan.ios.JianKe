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
import ObjectMapper

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
    
    //手机号验证
    func validatePhone(_ phone: String) -> Observable<Bool> {
        return .just(RegularValidate.phoneNum(phone).isRight)
    }
    
    //获取验证码
    func getVcode(_ phone: String, handler: @escaping SMSGetCodeResultHandler) {
        SMSSDK.getVerificationCode(by: SMSGetCodeMethod.SMS, phoneNumber: phone, zone: "86", result: handler)
    }
    func verifyVcode(_ phone: String, _ vcode: String, handler: @escaping SMSGetCodeResultHandler) {
        SMSSDK.commitVerificationCode(vcode, phoneNumber: phone, zone: "86", result: handler)
    }
    
    //用户登录
    func signIn(_ username: String, _ password: String) -> Observable<Result2> {
        return ShuTuProvider2.rx.request(.login(username: username, password: password))
            .mapObject(Callback2.self)
            .asObservable()
            .observeOn(MainScheduler.instance)
            .map { result in
                let code = result.code
                if code == 0 {
                    //设置 Token
                    let token = result.token!
                    Environment.token = token
                    if let user = User.init(map: Map.init(mappingType: .fromJSON, JSON: result.data!)) {
                        self.saveUserInfo(user)
                    }
                    //登录通知
                    LoginStatus.onNext(LoginState.ok)
                    return Result2.ok(message: "登录成功")
                } else {
                    return Result2.failed(message: result.msg!)
                }
            }
            .catchError { error in
                return .just(Error003)
            }
    }
    
    //用户注册
    func register(_ username: String, _ password: String) -> Observable<Result2> {
        return ShuTuProvider2.rx.request(.register(username: username, password: password))
            .mapObject(Callback2.self)
            .asObservable()
            .observeOn(MainScheduler.instance)
            .map { result in
                let code = result.code
                if code == 0 {
                    //设置 Token
                    let token = result.token!
                    Environment.token = token
                    if let user = User.init(map: Map.init(mappingType: .fromJSON, JSON: result.data!)) {
                        self.saveUserInfo(user)
                    }
                    //登录通知
                    LoginStatus.onNext(LoginState.ok)
                    return Result2.ok(message: "注册成功")
                } else {
                    return Result2.failed(message: result.msg!)
                }
            }
            .catchError { error in
                return .just(Error003)
        }
    }
    
    //保存用户信息
    fileprivate func saveUserInfo(_ user: User) {
        if let protrait = user.portrait {
            Environment.protrait = protrait
        }
    }
}

class DebateService {
    //单例
    static let instance = DebateService()
    private init() {}
    
    //添加回答
    func answerAdd(_ topicid: Int, _ side: AnswerSide, _ viewpoint: String) -> Observable<Result2> {
        //处理页面图片
        let (vp, urls) = ServiceUtil.handleHtml(viewpoint)
        return ShuTuProvider2.rx.request(.viewpointadd(id: topicid, side: side, viewpoint: vp, urls: urls))
            .mapObject(Callback.self)
            .asObservable()
            .observeOn(MainScheduler.instance)
            .map{ result in
                let code = result.code
                if code == 0 {
                    return Result2.ok(message: result.msg!)
                } else {
                    return Result2.failed(message: result.msg!)
                }
            }
            .catchErrorJustReturn(Error001)
    }
    
    //态度事件
    func attitudeCheck(_ vpid: Int) -> Observable<(AnswerAttitude?, Result2)> {
        return ShuTuProvider2.rx.request(.attitudecheck(id: vpid))
            .mapObject(Callback.self)
            .asObservable()
            .observeOn(MainScheduler.instance)
            .map{ result in
                let code = result.code
                if code == 0 {
                    let attitude = [AnswerAttitude].init(JSONArray: result.data!)
                    return (attitude[0], Ok001)
                } else {
                    return (nil, Result2.failed(message: result.msg!))
                }
            }
            .catchErrorJustReturn((nil, Error001))
    }
    func attitudeAdd(_ vpid: Int, attitude: AttitudeStand, type: AttitudeType, toggle: Toggle) -> Observable<(AnswerAttitude?, Result2)> {
        return ShuTuProvider2.rx.request(.attitudeadd(id: vpid, attitude: attitude, type: type, toggle: toggle))
            .mapObject(Callback.self)
            .asObservable()
            .observeOn(MainScheduler.instance)
            .map{ result in
                let code = result.code
                if code == 0 {
                    switch type {
                    case .viewpoint:
                        let attitude = [AnswerAttitude].init(JSONArray: result.data!)
                        return (attitude[0], Ok001)
                    case .comment:
                        return (nil, Ok001)
                    }
                } else {
                    return (nil, Result2.failed(message: result.msg!))
                }
            }
            .catchErrorJustReturn((nil, Error001))
    }
    
    //关注事件
    func followCheck(_ topicid: Int) -> Observable<Result2> {
        return ShuTuProvider2.rx.request(.followcheck(type: FollowType.topic, id: topicid))
            .mapObject(Callback.self)
            .asObservable()
            .observeOn(MainScheduler.instance)
            .map{ result in
                let code = result.code
                if code == 0 {
                    return Result2.exist
                } else {
                    return Result2.empty
                }
            }
            .catchErrorJustReturn(Error001)
    }
    func followAdd(_ topicid: Int, _ toggle: Toggle) -> Observable<Result2> {
        return ShuTuProvider2.rx.request(.followadd(type: FollowType.topic, id: topicid, toggle: toggle))
            .mapObject(Callback.self)
            .asObservable()
            .observeOn(MainScheduler.instance)
            .map{ result in
                let code = result.code
                if code == 0 {
                    return Result2.ok(message: result.msg!)
                } else if code == 1 {
                    return Result2.exist
                } else {
                    return Result2.failed(message: result.msg!)
                }
            }
            .catchErrorJustReturn(Error001)
    }
    
    //拉取今日话题
    func getDailyTopics(pageIndex: Int) -> Observable<([Debate], Result2)> {
        return ShuTuProvider2.rx.request(.today(pageIndex: pageIndex))
            .mapObject(Callback.self)
            .asObservable()
            .observeOn(MainScheduler.instance)
            .map{ result in
                let code = result.code
                if code == 0 {
                    let data = [Debate].init(JSONArray: result.data!)
                    return (data, Ok001)
                } else {
                    return ([], Result2.failed(message: result.msg!))
                }
            }
            .catchErrorJustReturn(([], Error001))
    }
    
    //拉取话题
    func getTopics(pageIndex: Int) -> Observable<([Debate], Result2)> {
        return ShuTuProvider2.rx.request(.topics(pageIndex: pageIndex))
            .mapObject(Callback.self)
            .asObservable()
            .observeOn(MainScheduler.instance)
            .map{ result in
                let code = result.code
                if code == 0 {
                    var data = [Debate].init(JSONArray: result.data!)
                    //获取描述的纯文本内容
                    for i in 0..<data.count {
                        let html = data[i].content!
                        data[i].puredesc = ServiceUtil.handleHtml2(html)
                    }
                    return (data, Ok001)
                } else {
                    return ([], Result2.failed(message: result.msg!))
                }
            }
            .catchErrorJustReturn(([], Error001))
    }
    
    //添加话题
    func topicAdd(_ title: String, _ content: String) -> Observable<Result2> {
        //处理页面图片
        let (tp, urls) = ServiceUtil.handleHtml(content)
        return ShuTuProvider2.rx.request(.topicadd(title: title, content: tp, urls: urls))
            .mapObject(Callback.self)
            .asObservable()
            .observeOn(MainScheduler.instance)
            .map{ result in
                let code = result.code
                if code == 0 {
                    return Result2.ok(message: result.msg!)
                } else {
                    return Result2.failed(message: result.msg!)
                }
            }
            .catchErrorJustReturn(Error001)
    }
    
    //搜索话题
    func getTopics(title: String, pageIndex: Int) -> Observable<([Debate], Result2)> {
        return ShuTuProvider2.rx.request(.topicsearch(title: title, pageIndex: pageIndex))
            .mapObject(Callback.self)
            .asObservable()
            .observeOn(MainScheduler.instance)
            .map{ result in
                let code = result.code
                if code == 0 {
                    var data = [Debate].init(JSONArray: result.data!)
                    //获取描述的纯文本内容
                    for i in 0..<data.count {
                        let html = data[i].description!
                        data[i].puredesc = ServiceUtil.handleHtml2(html)
                    }
                    return (data, Ok001)
                } else {
                    return ([], Result2.failed(message: result.msg!))
                }
            }
            .catchErrorJustReturn(([], Error001))
    }
    
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
        return ShuTuProvider2.rx.request(.viewpoint(id: id, pageIndex: pageIndex, side: side))
            .mapObject(Callback.self)
            .asObservable()
            .observeOn(MainScheduler.instance)
            .map{ result in
                let code = result.code
                if code == 0 {
                    var data = [Answer].init(JSONArray: result.data!)
                    //获取描述的纯文本内容
                    for i in 0..<data.count {
                        let html = data[i].answer!
                        data[i].pureanswer = ServiceUtil.handleHtml2(html)
                    }
                    return (data, Ok001)
                } else {
                    return ([], Result2.failed(message: result.msg!))
                }
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
        return ShuTuProvider2.rx.request(.comments(id: id, pageIndex: pageIndex, type: CommentType.viewpoint))
            .mapObject(Callback.self)
            .asObservable()
            .observeOn(MainScheduler.instance)
            .map{ result in
                let code = result.code
                if code == 0 {
                    let data = [AnswerComment].init(JSONArray: result.data!)
                    return (data, Ok001)
                } else {
                    return ([], Result2.failed(message: result.msg!))
                }
            }
            .catchErrorJustReturn(([], Error001))
    }
    func getDeepComment(id: Int, pageIndex: Int) -> Observable<([AnswerComment], Result2)> {
        return ShuTuProvider2.rx.request(.comments(id: id, pageIndex: pageIndex, type: CommentType.comment))
            .mapObject(Callback.self)
            .asObservable()
            .observeOn(MainScheduler.instance)
            .map{ result in
                let code = result.code
                if code == 0 {
                    let data = [AnswerComment].init(JSONArray: result.data!)
                    return (data, Ok001)
                } else {
                    return ([], Result2.failed(message: result.msg!))
                }
            }
            .catchErrorJustReturn(([], Error001))
    }
    func commentAdd(id: Int, content: String) -> Observable<Result2> {
        return ShuTuProvider2.rx.request(.commentadd(id: id, content: content))
            .mapObject(Callback.self)
            .asObservable()
            .observeOn(MainScheduler.instance)
            .map { result in
                let code = result.code
                if code == 0 {
                    return Ok001
                } else {
                    return Result2.failed(message: result.msg!)
                }
            }
            .catchError { error in
                return .just(Error003)
        }
    }
    func commentAdd(id: Int, cmid: Int, content: String) -> Observable<Result2> {
        return ShuTuProvider2.rx.request(.commentadd2(id: id, cmid: cmid, content: content))
            .mapObject(Callback.self)
            .asObservable()
            .observeOn(MainScheduler.instance)
            .map { result in
                let code = result.code
                if code == 0 {
                    return Ok001
                } else {
                    return Result2.failed(message: result.msg!)
                }
            }
            .catchError { error in
                return .just(Error003)
        }
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
    
    //获取动态
    func trend(_ pageIndex: Int) -> Observable<([Dynamic], Result2)> {
        return ShuTuProvider2.rx.request(.trend(pageIndex: pageIndex))
            .mapObject(Callback.self)
            .asObservable()
            .observeOn(MainScheduler.instance)
            .map{ result in
                let code = result.code
                if code == 0 {
                    let data = [Dynamic].init(JSONArray: result.data!)
                    return (data, Ok001)
                } else {
                    return ([], Result2.failed(message: result.msg!))
                }
            }
            .catchErrorJustReturn(([], Error001))
    }
    
    //拉取好友列表
    func getFriend(id: Int, pageIndex: Int) -> Observable<([User], Result2)> {
        return ShuTuProvider2.rx.request(.friends(pageIndex: pageIndex))
            .mapObject(Callback.self)
            .asObservable()
            .observeOn(MainScheduler.instance)
            .map{ result in
                let code = result.code
                if code == 0 {
                    let data = [User].init(JSONArray: result.data!)
                    return (data, Ok001)
                } else {
                    return ([], Result2.failed(message: result.msg!))
                }
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

class FindService {
    //单例
    static let instance = FindService()
    private init() {}
    
    //关注好友事件
    func followAdd(_ topicid: Int, _ toggle: Toggle) -> Observable<Result2> {
        return ShuTuProvider2.rx.request(.followadd(type: FollowType.person, id: topicid, toggle: toggle))
            .mapObject(Callback.self)
            .asObservable()
            .observeOn(MainScheduler.instance)
            .map{ result in
                let code = result.code
                if code == 0 {
                    return Result2.ok(message: result.msg!)
                } else if code == 1 {
                    return Result2.exist
                } else {
                    return Result2.failed(message: result.msg!)
                }
            }
            .catchErrorJustReturn(Error001)
    }
    
    //投票
    func vote(_ id: Int, _ attitude: AttitudeStand) -> Observable<Result2> {
        return ShuTuProvider2.rx.request(.vote(id: id, attitude: attitude))
            .mapObject(Callback.self)
            .asObservable()
            .observeOn(MainScheduler.instance)
            .map { result in
                let code = result.code
                if code == 0 {
                    return Ok001
                } else {
                    return Result2.failed(message: result.msg!)
                }
            }
            .catchError { error in
                return .just(Error003)
        }
    }
    
    //发现话题
    func findTopic() -> Observable<([Debate], Result2)> {
        return ShuTuProvider2.rx.request(.findtopic)
            .mapObject(Callback.self)
            .asObservable()
            .observeOn(MainScheduler.instance)
            .map{ result in
                let code = result.code
                if code == 0 {
                    let data = [Debate].init(JSONArray: result.data!)
                    return (data, Ok001)
                } else {
                    return ([], Result2.failed(message: result.msg!))
                }
            }
            .catchErrorJustReturn(([], Error001))
    }
    //发现征集
    func findCollect() -> Observable<([DebateCollect], Result2)> {
        return ShuTuProvider2.rx.request(.findcollect)
            .mapObject(Callback.self)
            .asObservable()
            .observeOn(MainScheduler.instance)
            .map{ result in
                let code = result.code
                if code == 0 {
                    let data = [DebateCollect].init(JSONArray: result.data!)
                    return (data, Ok001)
                } else {
                    return ([], Result2.failed(message: result.msg!))
                }
            }
            .catchErrorJustReturn(([], Error001))
    }
    //发现感兴趣的人
    func findPerson() -> Observable<([User], Result2)> {
        return ShuTuProvider2.rx.request(.findperson)
            .mapObject(Callback.self)
            .asObservable()
            .observeOn(MainScheduler.instance)
            .map{ result in
                let code = result.code
                if code == 0 {
                    let data = [User].init(JSONArray: result.data!)
                    return (data, Ok001)
                } else {
                    return ([], Result2.failed(message: result.msg!))
                }
            }
            .catchErrorJustReturn(([], Error001))
    }
}

class MeService {
    //单例
    static let instance = MeService()
    private init() {}
    
    //获取用户信息
    func userinfo() -> Observable<(UserInfo?, Result2)> {
        return ShuTuProvider2.rx.request(.userinfo)
            .mapObject(Callback2.self)
            .asObservable()
            .observeOn(MainScheduler.instance)
            .map{ result in
                let code = result.code
                if code == 0 {
                    let data = UserInfo.init(map: Map.init(mappingType: .fromJSON, JSON: result.data!))
                    return (data, Ok001)
                } else {
                    return (nil, Result2.failed(message: result.msg!))
                }
            }
            .catchErrorJustReturn((nil, Error001))
    }
    
    //保存用户信息
    fileprivate func saveUserInfo(_ userinfo: UserInfo) {
        if let followtopics = userinfo.followtopics {
            Environment.followtopics = followtopics
        }
        if let followpersons = userinfo.follows {
            Environment.followpersons = followpersons
        }
        if let fans = userinfo.fans {
            Environment.fans = fans
        }
    }
    
    //获取动态
    func trend(_ pageIndex: Int) -> Observable<([Dynamic], Result2)> {
        return ShuTuProvider2.rx.request(.trend2(pageIndex: pageIndex))
            .mapObject(Callback.self)
            .asObservable()
            .observeOn(MainScheduler.instance)
            .map{ result in
                let code = result.code
                if code == 0 {
                    let data = [Dynamic].init(JSONArray: result.data!)
                    return (data, Ok001)
                } else {
                    return ([], Result2.failed(message: result.msg!))
                }
            }
            .catchErrorJustReturn(([], Error001))
    }
    
    //获取关注的人
    func follows(_ pageIndex: Int) -> Observable<([User], Result2)> {
        return ShuTuProvider2.rx.request(.mefollows(pageIndex: pageIndex))
            .mapObject(Callback.self)
            .asObservable()
            .observeOn(MainScheduler.instance)
            .map{ result in
                let code = result.code
                if code == 0 {
                    let data = [User].init(JSONArray: result.data!)
                    return (data, Ok001)
                } else {
                    return ([], Result2.failed(message: result.msg!))
                }
            }
            .catchErrorJustReturn(([], Error001))
    }
    
    //获取关注我的人
    func fans(_ pageIndex: Int) -> Observable<([User], Result2)> {
        return ShuTuProvider2.rx.request(.mefans(pageIndex: pageIndex))
            .mapObject(Callback.self)
            .asObservable()
            .observeOn(MainScheduler.instance)
            .map{ result in
                let code = result.code
                if code == 0 {
                    let data = [User].init(JSONArray: result.data!)
                    return (data, Ok001)
                } else {
                    return ([], Result2.failed(message: result.msg!))
                }
            }
            .catchErrorJustReturn(([], Error001))
    }
    
    //获取关注的话题
    func followtopics(_ pageIndex: Int) -> Observable<([Debate], Result2)> {
        return ShuTuProvider2.rx.request(.followtopics(pageIndex: pageIndex))
            .mapObject(Callback.self)
            .asObservable()
            .observeOn(MainScheduler.instance)
            .map{ result in
                let code = result.code
                if code == 0 {
                    var data = [Debate].init(JSONArray: result.data!)
                    //获取描述的纯文本内容
                    for i in 0..<data.count {
                        let html = data[i].description!
                        data[i].puredesc = ServiceUtil.handleHtml2(html)
                    }
                    return (data, Ok001)
                } else {
                    return ([], Result2.failed(message: result.msg!))
                }
            }
            .catchErrorJustReturn(([], Error001))
    }
    
    //获取观点
    func viewpoints(_ pageIndex: Int) -> Observable<([Answer], Result2)> {
        return ShuTuProvider2.rx.request(.meviewpoints(pageIndex: pageIndex))
            .mapObject(Callback.self)
            .asObservable()
            .observeOn(MainScheduler.instance)
            .map{ result in
                let code = result.code
                if code == 0 {
                    var data = [Answer].init(JSONArray: result.data!)
                    //获取描述的纯文本内容
                    for i in 0..<data.count {
                        let html = data[i].answer!
                        data[i].pureanswer = ServiceUtil.handleHtml2(html)
                    }
                    return (data, Ok001)
                } else {
                    return ([], Result2.failed(message: result.msg!))
                }
            }
            .catchErrorJustReturn(([], Error001))
    }
    
    //获取话题
    func topics(_ pageIndex: Int) -> Observable<([Debate], Result2)> {
        return ShuTuProvider2.rx.request(.metopics(pageIndex: pageIndex))
            .mapObject(Callback.self)
            .asObservable()
            .observeOn(MainScheduler.instance)
            .map{ result in
                let code = result.code
                if code == 0 {
                    var data = [Debate].init(JSONArray: result.data!)
                    //获取描述的纯文本内容
                    for i in 0..<data.count {
                        let html = data[i].description!
                        data[i].puredesc = ServiceUtil.handleHtml2(html)
                    }
                    return (data, Ok001)
                } else {
                    return ([], Result2.failed(message: result.msg!))
                }
            }
            .catchErrorJustReturn(([], Error001))
    }
    
    //获取支持
    func supports(_ pageIndex: Int) -> Observable<([Answer], Result2)> {
        return ShuTuProvider2.rx.request(.supports(pageIndex: pageIndex))
            .mapObject(Callback.self)
            .asObservable()
            .observeOn(MainScheduler.instance)
            .map{ result in
                let code = result.code
                if code == 0 {
                    var data = [Answer].init(JSONArray: result.data!)
                    //获取描述的纯文本内容
                    for i in 0..<data.count {
                        let html = data[i].answer!
                        data[i].pureanswer = ServiceUtil.handleHtml2(html)
                    }
                    return (data, Ok001)
                } else {
                    return ([], Result2.failed(message: result.msg!))
                }
            }
            .catchErrorJustReturn(([], Error001))
    }
    
    //获取收藏
    func collects(_ pageIndex: Int) -> Observable<([Answer], Result2)> {
        return ShuTuProvider2.rx.request(.collects(pageIndex: pageIndex))
            .mapObject(Callback.self)
            .asObservable()
            .observeOn(MainScheduler.instance)
            .map{ result in
                let code = result.code
                if code == 0 {
                    var data = [Answer].init(JSONArray: result.data!)
                    //获取描述的纯文本内容
                    for i in 0..<data.count {
                        let html = data[i].answer!
                        data[i].pureanswer = ServiceUtil.handleHtml2(html)
                    }
                    return (data, Ok001)
                } else {
                    return ([], Result2.failed(message: result.msg!))
                }
            }
            .catchErrorJustReturn(([], Error001))
    }
}
    

class TestService {
    //单例
    static let instance = TestService()
    private init() {}
    
}

class ServiceUtil {
    ///获取页面代码中的图片资源
    static func handleHtml(_ html: String) -> (String, [URL]) {
        var html2 = html
        var urls: [URL] = []
        let pattern = "<img[^>]*>"
        let subs = html.regexGetSub(pattern: pattern, str: html)
        for i in 0..<subs.count {
            let sub = subs[i]
            let pattern2 = "src=\"[^\"]*\""
            let subs2 = html.regexGetSub(pattern: pattern2, str: sub)
            if subs2.count == 1 {
                var imagePath = subs2[0]
                imagePath = (imagePath as NSString).replacingOccurrences(of: "src=", with: "")
                imagePath = (imagePath as NSString).replacingOccurrences(of: "\"", with: "")
                let imageUrl = URL.init(fileURLWithPath: imagePath)
                if imageUrl.isFileURL {
                    urls.append(imageUrl)
                    html2 = (html2 as NSString).replacingOccurrences(of: sub, with: "{{image_\(i)}}")
                }
            }
        }
        
        return (html2, urls)
    }
    ///获得纯净的文本
    static func handleHtml2(_ o: String) -> String {
        var html = o
        html = html.replacingOccurrences(of: "<img[^>]*>", with: "", options: .regularExpression, range: html.startIndex..<html.endIndex)
        html = html.replacingOccurrences(of: "<a[\\s\\S]*</a>", with: "", options: .regularExpression, range: html.startIndex..<html.endIndex)
        let htmlrange = html.range(of: "<body>[\\s\\S]*body>", options: .regularExpression, range: html.startIndex..<html.endIndex, locale: Locale.current)
        if let range = htmlrange {
            html = String(html[range])
        }
        html = (html as NSString).replacingOccurrences(of: "<div>", with: "")
        html = (html as NSString).replacingOccurrences(of: "</div>", with: "")
        html = (html as NSString).replacingOccurrences(of: "<body>", with: "")
        html = (html as NSString).replacingOccurrences(of: "</body>", with: "")
        html = (html as NSString).replacingOccurrences(of: "<p>", with: "")
        html = (html as NSString).replacingOccurrences(of: "</p>", with: "")
        html = (html as NSString).replacingOccurrences(of: "<br>", with: "")
        html = (html as NSString).replacingOccurrences(of: "<br/>", with: "")
        html = (html as NSString).replacingOccurrences(of: "<b>", with: "")
        html = (html as NSString).replacingOccurrences(of: "</b>", with: "")
        html = (html as NSString).replacingOccurrences(of: "<i>", with: "")
        html = (html as NSString).replacingOccurrences(of: "</i>", with: "")
        
        return html
    }
}

//常用验证
enum RegularValidate {
    case email(_: String)
    case phoneNum(_: String)
    case carNum(_: String)
    case username(_: String)
    case password(_: String)
    case nickname(_: String)
    
    case URL(_: String)
    case IP(_: String)
    
    var isRight: Bool {
        var predicateStr:String!
        var currObject:String!
        switch self {
        case let .email(str):
            predicateStr = "^([a-z0-9_\\.-]+)@([\\da-z\\.-]+)\\.([a-z\\.]{2,6})$"
            currObject = str
        case let .phoneNum(str):
            predicateStr = "^((13[0-9])|(15[^4,\\D]) |(17[0,0-9])|(18[0,0-9]))\\d{8}$"
            currObject = str
        case let .carNum(str):
            predicateStr = "^[A-Za-z]{1}[A-Za-z_0-9]{5}$"
            currObject = str
        case let .username(str):
            predicateStr = "^[A-Za-z0-9]{6,20}+$"
            currObject = str
        case let .password(str):
            predicateStr = "^[a-zA-Z0-9]{6,20}+$"
            currObject = str
        case let .nickname(str):
            predicateStr = "^[\\u4e00-\\u9fa5]{4,8}$"
            currObject = str
        case let .URL(str):
            predicateStr = "^(https?:\\/\\/)?([\\da-z\\.-]+)\\.([a-z\\.]{2,6})([\\/\\w \\.-]*)*\\/?$"
            currObject = str
        case let .IP(str):
            predicateStr = "^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$"
            currObject = str
        }
        
        let predicate =  NSPredicate(format: "SELF MATCHES %@" ,predicateStr)
        return predicate.evaluate(with: currObject)
    }
}
