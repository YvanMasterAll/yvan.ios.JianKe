//
//  API.swift
//  JianKe
//
//  Created by yiqiang on 2017/12/12.
//  Copyright © 2017年 yiqiang. All rights reserved.
//

import Foundation
import Moya
import CryptoSwift

//MARK: - Test API
public var STTestProvider: MoyaProvider = MoyaProvider<STTestApi>()
public enum STTestApi {
    case test
    case carousel
    case debate(pageIndex: Int)
    case answer(id: Int, pageIndex: Int, side: AnswerSide)
    case answerDetail(id: Int)
    case answerComment(id: Int, pageIndex: Int)
    case friend(id: Int, pageIndex: Int)
    case friendDynamic(id: Int, pageIndex: Int)
}
extension STTestApi: TargetType {
    //The target's base `URL`
    public var baseURL: URL {
        return URL(string: "http://47.94.111.82/v")!
    }
    //The path to be appended to `baseURL` to form the full `URL`.
    public var path: String {
        switch self {
        case .test:
            return "test"
        case .carousel:
            return "debate/carousel"
        case .debate(let pageIndex):
            return "debate/\(pageIndex)"
        case .answer(let id, let pageIndex, let side):
            return "debate/answer/\(side.rawValue)/\(id)/\(pageIndex)"
        case .answerDetail(let id):
            return "debate/answer/detail/\(id)"
        case .answerComment(let id, let pageIndex):
            return "debate/answer/comment/\(id)/\(pageIndex)"
        case .friend(let id, let pageIndex):
            return "debate/friend/\(id)/\(pageIndex)"
        case .friendDynamic(let id, let pageIndex):
            return "debate/friend/dynamic/\(id)/\(pageIndex)"
        }
    }
    //The HTTP method used in the request.
    public var method: Moya.Method {
        print("request(for: \(self.path))")
        return .get
    }
    //The headers to be incoded in the request.
    public var headers: [String : String]? {
        return nil
    }
    //Provides stub data for use in testing.
    public var sampleData: Data {
        return "".data(using: String.Encoding.utf8)!
    }
    //The type of HTTP task to be performed.
    public var task: Task {
        return .requestPlain
    }
    //Whether or not to perform Alamofire validation. Defaults to `false`.
    public var validate: Bool {
        return false
    }
}

//MARK: - Common
public enum Toggle: String {
    case on
    case off
}
public enum TrendType: String {
    case answer_topic = "回答辩题"
    case new_answer = "新观点"
    case new_topic = "新辩题"
}
public enum AnswerSide: String {
    case SY = "support" //声援
    case ST = "oppose" //殊途
}
public enum FollowType {
    case topic
    case person
}
public enum CommentType: String {
    case viewpoint
    case comment
}
public enum AttitudeStand: String {
    case support = "support" //声援
    case oppose = "oppose" //殊途
    case bravo = "bravo" //同归
    case neutral = "neutral" //中立
    case collect = "collect" //收藏
}
public enum AttitudeType {
    case viewpoint
    case comment
}

//MARK: - API
public var STProvider: MoyaProvider = MoyaProvider<STApi>(
    endpointClosure: shutuEndpointClosure,
    requestClosure: shutuRequestClosure
)
public enum STApi {
    case login(username: String, password: String)
    case logout
    case register(username: String, password: String)
    case today(pageIndex: Int)
    case topics(pageIndex: Int)
    case topicadd(title: String, content: String, urls: [URL])
    case topicsearch(title: String, pageIndex: Int)
    case viewpoint(id: Int, pageIndex: Int, side: AnswerSide)
    case viewpointadd(id: Int, side: AnswerSide, anony: Bool, viewpoint: String, urls: [URL])
    case viewpointcheck(id: Int)
    case comments(id: Int, pageIndex: Int, type: CommentType)
    case commentadd(id: Int, content: String)
    case commentadd2(id: Int, cmid: Int, content: String) //回复评论
    case friends(pageIndex: Int)
    case findtopic
    case findcollect
    case findperson
    case followcheck(type: FollowType, id: Int)
    case followadd(type: FollowType, id: Int, toggle: Toggle)
    case attitudecheck(id: Int)
    case attitudeadd(id: Int, attitude: AttitudeStand, type: AttitudeType, toggle: Toggle)
    case trend(pageIndex: Int) //关注动态
    case trend2(pageIndex: Int) //用户动态
    case vote(id: Int, attitude: AttitudeStand)
    case collects(pageIndex: Int)
    case supports(pageIndex: Int)
    case mefollows(pageIndex: Int)
    case mefans(pageIndex: Int)
    case followtopics(pageIndex: Int)
    case metopics(pageIndex: Int)
    case meviewpoints(pageIndex: Int)
    case userinfo
    case setuserinfo(infos: [String: Any])
    
}
extension STApi: TargetType {
    //The target's base `URL`
    public var baseURL: URL {
        return URL(string: "http://127.0.0.1:8181/api/v1")!
    }
    //The path to be appended to `baseURL` to form the full `URL`.
    public var path: String {
        switch self {
        case .login:            return "/login"
        case .logout:           return "/logout"
        case .today:            return "/todays"
        case .topics:           return "/topics"
        case .topicadd:         return "/topic/add"
        case .topicsearch:      return "/topic/search"
        case .viewpoint:        return "/viewpoints"
        case .viewpointadd:     return "/viewpoint/add"
        case .viewpointcheck:   return "/viewpoint/check"
        case .comments:         return "/comments"
        case .commentadd:       return "/comment/add"
        case .commentadd2:      return "/comment/add"
        case .friends:          return "/friendship"
        case .register:         return "/register"
        case .findtopic:        return "/trecommend"
        case .findcollect:      return "/collect"
        case .findperson:       return "/urecommend"
        case .followcheck(let type, _):
            switch type {
            case .topic:        return "/topic/isfollowed"
            case .person:       return "/friend/isfollowed"
            }
        case .followadd(let type, _, _):
            switch type {
            case .topic:        return "/topic/follow"
            case .person:       return "/friend/follow"
            }
        case .attitudecheck(_): return "/viewpoint/actcheck"
        case .attitudeadd(_, _, let type, _):
            switch type {
            case .viewpoint:    return "/viewpoint/act"
            case .comment:      return "/comment/act"
            }
        case .trend:            return "/trend"
        case .trend2:           return "/trend2"
        case .vote:             return "/tcvote"
        case .collects:         return "/home/collects"
        case .supports:         return "/home/supports"
        case .mefollows:        return "/home/follows"
        case .mefans:           return "/home/fans"
        case .followtopics:     return "/home/followTopics"
        case .metopics:         return "/home/topics"
        case .meviewpoints:     return "/home/viewpoints"
        case .userinfo:         return "/home/getUserInfo"
        case .setuserinfo:      return "/home/setUserInfo"
        }
    }
    //The HTTP method used in the request.
    public var method: Moya.Method {
        print("request(for: \(self.path))")
        switch self {
        case .login, .register, .viewpointadd, .followadd, .attitudecheck, .attitudeadd, .commentadd, .commentadd2, .topicadd, .vote, .setuserinfo:
            return .post
        default:
            return .get
        }
    }
    //The headers to be incoded in the request.
    public var headers: [String : String]? {
        return nil
    }
    //Provides stub data for use in testing.
    public var sampleData: Data {
        return "".data(using: String.Encoding.utf8)!
    }
    //The type of HTTP task to be performed.
    public var task: Task {
        switch self {
        case .login(let username, let password), .register(let username, let password):
            return .requestParameters(parameters: ["username": username, "password": password.sha1()], encoding: URLEncoding.default)
        case .today(let pageIndex), .topics(let pageIndex), .friends(let pageIndex):
            return .requestParameters(parameters: ["page": pageIndex], encoding: URLEncoding.default)
        case .topicsearch(let title, let pageIndex):
            return .requestParameters(parameters: ["text": title, "page": pageIndex], encoding: URLEncoding.default)
        case .viewpoint(let id, let pageIndex, let side):
            return .requestParameters(parameters: ["topicid": id, "page": pageIndex, "stand": side.rawValue], encoding: URLEncoding.default)
        case .comments(let id, let pageIndex, let type):
            return .requestParameters(parameters: ["id": id, "page": pageIndex, "type": type.rawValue], encoding: URLEncoding.default)
        case .commentadd(let id, let content):
            return .requestParameters(parameters: ["vpid": id, "content": content, "anonymous": "f"], encoding: URLEncoding.default)
        case .commentadd2(let id, let cmid, let content):
            return .requestParameters(parameters: ["vpid": id, "commentid": cmid, "content": content, "anonymous": "f"], encoding: URLEncoding.default)
        case .followcheck(let type, let id):
            switch type {
            case .topic:
                return .requestParameters(parameters: ["topicid": id], encoding: URLEncoding.default)
            case .person:
                return .requestParameters(parameters: ["fuserid": id], encoding: URLEncoding.default)
            }
        case .followadd(let type, let id, let toggle):
            switch type {
            case .topic:
                return .requestParameters(parameters: ["topicid": id, "toggle": toggle.rawValue], encoding: URLEncoding.default)
            case .person:
                return .requestParameters(parameters: ["fuserid": id, "toggle": toggle.rawValue], encoding: URLEncoding.default)
            }
        case .topicadd(let title, let content, let files):
            let parameters: [String: Any] = ["title": title, "content": content]
            if files.count > 0 {
                var formData: [MultipartFormData] = []
                for file in files {
                    formData.append(MultipartFormData.init(provider: .file(file), name: ""))
                }
                return .uploadCompositeMultipart(formData, urlParameters: parameters)
            } else {
                return .requestParameters(parameters: parameters, encoding: URLEncoding.default)
            }
        case .viewpointadd(let id, let side, let anony, let viewpoint, let files):
            let parameters: [String: Any] = ["topicid": id, "content": viewpoint, "stand": side.rawValue, "anonymous": anony ? "t":"f"]
            if files.count > 0 {
                var formData: [MultipartFormData] = []
                for file in files {
                    formData.append(MultipartFormData.init(provider: .file(file), name: ""))
                }
                return .uploadCompositeMultipart(formData, urlParameters: parameters)
            } else {
                return .requestParameters(parameters: parameters, encoding: URLEncoding.default)
            }
        case .viewpointcheck(let id):
            return .requestParameters(parameters: ["topicid": id], encoding: URLEncoding.default)
        case .attitudecheck(let id):
            return .requestParameters(parameters: ["vpid": id], encoding: URLEncoding.default)
        case .attitudeadd(let id, let attitude, let type, let toggle):
            switch type {
            case .viewpoint:
                return .requestParameters(parameters: ["vpid": id, "act": attitude.rawValue, "toggle": toggle.rawValue], encoding: URLEncoding.default)
            case .comment:
                return .requestParameters(parameters: ["cmid": id, "act": attitude.rawValue, "toggle": toggle.rawValue], encoding: URLEncoding.default)
            }
        case .trend(let pageIndex), .trend2(let pageIndex), .collects(let pageIndex), .supports(let pageIndex), .mefollows(let pageIndex), .mefans(let pageIndex), .followtopics(let pageIndex), .metopics(let pageIndex), .meviewpoints(let pageIndex):
            return .requestParameters(parameters: ["page": pageIndex], encoding: URLEncoding.default)
        case .vote(let id, let attitude):
            return .requestParameters(parameters: ["topicid": id, "attitude": attitude.rawValue], encoding: URLEncoding.default)
        case .setuserinfo(let infos):
            if let url = infos["url"] as? String {
                let file = URL.init(fileURLWithPath: url)
                return .uploadCompositeMultipart([MultipartFormData.init(provider: .file(file), name: "")], urlParameters: infos)
            }
            return .requestParameters(parameters: infos, encoding: URLEncoding.default)
        default:
            return .requestPlain
        }
    }
    //Whether or not to perform Alamofire validation. Defaults to `false`.
    public var validate: Bool {
        return false
    }
}
let shutuRequestClosure = { (endpoint: Endpoint<STApi>, done: MoyaProvider.RequestResultClosure) in
    var request: URLRequest
    do {
        try request = endpoint.urlRequest()
        request.httpShouldHandleCookies = true
        if let token = Environment.token {
            request.setValue("TurnstileSession=\(token);AppVersion=\(AppVersion)", forHTTPHeaderField: "Cookie")
        } else {
            request.setValue("AppVersion=\(AppVersion)", forHTTPHeaderField: "Cookie")
        }
        done(.success(request))
    } catch {
        done(.failure(MoyaError.requestMapping(endpoint.url)))
    }
}
let shutuEndpointClosure = { (target: STApi) -> Endpoint<STApi> in
    let defaultEndpoint = MoyaProvider.defaultEndpointMapping(for: target)

    return defaultEndpoint
}
