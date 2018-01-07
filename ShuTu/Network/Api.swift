//
//  API.swift
//  JianKe
//
//  Created by yiqiang on 2017/12/12.
//  Copyright © 2017年 yiqiang. All rights reserved.
//

import Foundation
import Moya

//GitHub Provider
public var GithubProvider = MoyaProvider<GitHubApi>(
    endpointClosure: githubEndpointClosure,
    requestClosure: githubRequestClosure,
    plugins: [NetworkLoggerPlugin(verbose: false, responseDataFormatter: StubResponse.jsonResponseDataFormatter)]
)

//ZhiHu Provider
public var ZhihuProvider = MoyaProvider<ZhihuApi>()

//Test Provider
public var ShuTuProvider = MoyaProvider<ShuTuApi>()

//Test Api
public enum ShuTuApi {
    case test
    case carousel
    case debate(pageIndex: Int)
    case answer(id: Int, pageIndex: Int, side: AnswerSide)
    case answerDetail(id: Int)
    case answerComment(id: Int, pageIndex: Int)
    case friend(id: Int, pageIndex: Int)
    case friendDynamic(id: Int, pageIndex: Int)
}
public enum AnswerSide: String {
    case SY = "y"
    case ST = "s"
}
extension ShuTuApi: TargetType {
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

//ZhiHu API
public enum ZhihuApi {
    case getLaunchImg
    case getNewsList
    case getMoreNews(String)
    case getThemeList
    case getThemeDesc(Int)
    case getNewsDesc(Int)
}
extension ZhihuApi: TargetType {
    //The target's base `URL`
    public var baseURL: URL {
        return URL(string: "http://news-at.zhihu.com/api")!
    }
    //The path to be appended to `baseURL` to form the full `URL`.
    public var path: String {
        switch self {
        case .getLaunchImg:
            return "7/prefetch-launch-images/750*1142"
        case .getNewsList:
            return "4/news/latest"
        case .getMoreNews(let date):
            return "4/news/before/\(date)"
        case .getThemeList:
            return "4/themes"
        case .getThemeDesc(let id):
            return "4/theme/\(id)"
        case .getNewsDesc(let id):
            return "4/news/\(id)"
        }
    }
    //The HTTP method used in the request.
    public var method: Moya.Method {
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

//GitHub API
public enum GitHubApi {
    case Token(username: String, password: String)
    case RepoSearch(query: String, page:Int)
    case TrendingReposSinceLastWeek(language: String, page:Int)
    case Repo(fullname: String)
    case RepoReadMe(fullname: String)
    case Pulls(fullname: String)
    case Issues(fullname: String)
    case Commits(fullname: String)
    case User
}
extension GitHubApi: TargetType {
    //The target's base `URL`
    public var baseURL: URL {
        return URL(string: "https://api.github.com")!
    }
    //The path to be appended to `baseURL` to form the full `URL`.
    public var path: String {
        switch self {
        case .Token(_, _):
            return "/authorizations"
        case .RepoSearch(_,_),
             .TrendingReposSinceLastWeek(_,_):
            return "/search/repositories"
        case .Repo(let fullname):
            return "/repos/\(fullname)"
        case .RepoReadMe(let fullname):
            return "/repos/\(fullname)/readme"
        case .Pulls(let fullname):
            return "/repos/\(fullname)/pulls"
        case .Issues(let fullname):
            return "/repos/\(fullname)/issues"
        case .Commits(let fullname):
            return "/repos/\(fullname)/commits"
        case .User:
            return "/user"
            
        }
    }
    //The HTTP method used in the request.
    public var method: Moya.Method {
        switch self {
        case .Token(_, _):
            return .post
        case .RepoSearch(_),
             .TrendingReposSinceLastWeek(_,_),
             .Repo(_),
             .RepoReadMe(_),
             .Pulls(_),
             .Issues(_),
             .Commits(_),
             .User:
            return .get
        }
    }
    //The headers to be incoded in the request.
    public var headers: [String : String]? {
        return nil
    }
    //Provides stub data for use in testing.
    public var sampleData: Data {
        switch self {
        case   .RepoSearch(_),
               .TrendingReposSinceLastWeek(_,_):
            return StubResponse.fromJSONFile()
        default:
            return "".data(using: String.Encoding.utf8)!
        }
    }
    //The type of HTTP task to be performed.
    public var task: Task {
        switch self {
        case .Token(_, _):
            return .requestParameters(parameters: [
                "scopes": ["public_repo", "user"],
                "note": "(\(NSDate()))"
                ], encoding: JSONEncoding.default)
        case .Repo(_),
             .RepoReadMe(_),
             .User,
             .Pulls,
             .Issues,
             .Commits:
            return .requestPlain
        case .RepoSearch(let query,let page):
            return .requestParameters(parameters: [
                "q": query.urlEscaped, "page":page
                ], encoding: URLEncoding.default)
        case .TrendingReposSinceLastWeek(let language,let page):
            let lastWeek = Calendar.current.date(byAdding: .weekOfYear, value: -1, to: Date())
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            return .requestParameters(parameters: [
                "q" :"language:\(language) " + "created:>" + formatter.string(from: lastWeek!), "sort" : "stars", "order" : "desc", "page":page
                ], encoding: URLEncoding.default)
        }
    }
    //Whether or not to perform Alamofire validation. Defaults to `false`.
    public var validate: Bool {
        return false
    }
}
let githubRequestClosure = { (endpoint: Endpoint<GitHubApi>, done: MoyaProvider.RequestResultClosure) in
    var request: URLRequest
    do {
        try request = endpoint.urlRequest()
        //request.httpShouldHandleCookies = false
        done(.success(request))
    } catch {
        done(.failure(MoyaError.requestMapping(endpoint.url)))
    }
}
let githubEndpointClosure = { (target: GitHubApi) -> Endpoint<GitHubApi> in
    let url = target.baseURL.appendingPathComponent(target.path).absoluteString
    let defaultEndpoint = MoyaProvider.defaultEndpointMapping(for: target)
    
    switch target {
    case .Token(let userString, let passwordString):
        let credentialData = "\(userString):\(passwordString)".data(using: String.Encoding.utf8)
        let base64Credentials = credentialData?.base64EncodedString()
        return defaultEndpoint.adding(newHTTPHeaderFields: ["Authorization": "Basic \(base64Credentials!)"])
    default:
        if !Environment.tokenExists {
            return defaultEndpoint
        }
        
        return defaultEndpoint.adding(newHTTPHeaderFields: ["Authorization": "token \(Environment.token!)"])
    }
}
