//
//  Protocol.swift
//  JianKe
//
//  Created by yiqiang on 2017/12/12.
//  Copyright © 2017年 yiqiang. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import Moya
import ObjectMapper

///将应用程序的运行状态变更绑定到Rx
fileprivate class RxUIApplicationDelegateProxy: DelegateProxy<AnyObject, AnyObject>, UIApplicationDelegate, DelegateProxyType {
    //注册 UIApplication
    init(parentObject: UIApplication) {
        super.init(parentObject: parentObject, delegateProxy: RxUIApplicationDelegateProxy.self)
    }
    static func registerKnownImplementations() {
        self.register { RxUIApplicationDelegateProxy(parentObject: $0) }
    }
    //拷贝 appDelegate
    static func setCurrentDelegate(_ delegate: AnyObject?, to object: AnyObject) {
        let app: UIApplication = object as! UIApplication
        app.delegate = delegate as? UIApplicationDelegate
    }
    static func currentDelegate(for object: AnyObject) -> AnyObject? {
        let app: UIApplication = object as! UIApplication
        return app.delegate
    }
    //引用 appDelegate, 必须是强引用, 保证 appDelegate 不被释放
    override func setForwardToDelegate(_ delegate: AnyObject?, retainDelegate: Bool) {
        super.setForwardToDelegate(delegate, retainDelegate: true)
    }
}
//扩展 RxSwift - AppDelegate
extension Reactive where Base: UIApplication {
    //delegate
    var delegate: DelegateProxy<AnyObject, AnyObject> {
        return RxUIApplicationDelegateProxy.proxy(for: base)
    }
    //再次激活
    var didBecomeActive: Observable<UIApplicationState> {
        return delegate
            .methodInvoked(#selector(UIApplicationDelegate.applicationDidBecomeActive(_:)))
            .map{ _ in
                return .active
        }
    }
    //回到后台
    var didEnterBackground: Observable<UIApplicationState> {
        return delegate
            .methodInvoked(#selector(UIApplicationDelegate.applicationDidEnterBackground(_:)))
            .map{ _ in
                return .background
        }
    }
    //临时状态 - 按下 Home 建
    var willResignActive: Observable<UIApplicationState> {
        
        return delegate
            .methodInvoked(#selector(UIApplicationDelegate.applicationWillResignActive(_:)))
            .map{ _ in
                return .inactive
        }
    }
    //应用程序被终止 - 很少使用
    var willTerminate: Observable<Void> {
        return delegate
            .methodInvoked(#selector(UIApplicationDelegate.applicationWillTerminate(_:)))
            .map{ _ in }
    }
    //状态变更集
    var state: Observable<UIApplicationState> {
        return Observable.of(
            didBecomeActive,
            didEnterBackground,
            willResignActive
            )
            .merge()
            .startWith(base.applicationState)
    }
}

//服务端响应的数据处理
class StubResponse { //Stub<存根>
    static var stubJsonPath = ""
    static func fromJSONFile(filePath: String = stubJsonPath) -> Data {
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: filePath)) else {
            fatalError("Invalid data from json file")
        }
        return data
    }
    static func jsonResponseDataFormatter(_ data: Data) -> Data {
        do {
            let dataAsJSON = try JSONSerialization.jsonObject(with: data)
            let prettyData =  try JSONSerialization.data(withJSONObject: dataAsJSON, options: .prettyPrinted)
            return prettyData
        } catch {
            return data // fallback to original data if it can't be serialized.
        }
    }
}
public extension Response {
    /// Maps data received from the signal into an object which implements the Mappable protocol.
    /// If the conversion fails, the signal errors.
    public func mapObject<T: BaseMappable>(_ type: T.Type, context: MapContext? = nil) throws -> T {
        guard let object = Mapper<T>(context: context).map(JSONObject: try mapJSON()) else {
            throw MoyaError.jsonMapping(self)
        }
        return object
    }
    /// Maps data received from the signal into an array of objects which implement the Mappable
    /// protocol.
    /// If the conversion fails, the signal errors.
    public func mapArray<T: BaseMappable>(_ type: T.Type, context: MapContext? = nil) throws -> [T] {
        //        print(self.mapJSON())
        guard let array = try mapJSON() as? [[String : Any]] else {
            throw MoyaError.jsonMapping(self)
        }
        return Mapper<T>(context: context).mapArray(JSONArray: array)
    }
}
// MARK: - ImmutableMappable
public extension Response {
    /// Maps data received from the signal into an object which implements the ImmutableMappable
    /// protocol.
    /// If the conversion fails, the signal errors.
    public func mapObject<T: ImmutableMappable>(_ type: T.Type, context: MapContext? = nil) throws -> T {
        return try Mapper<T>(context: context).map(JSONObject: try mapJSON())
    }
    /// Maps data received from the signal into an array of objects which implement the ImmutableMappable
    /// protocol.
    /// If the conversion fails, the signal errors.
    public func mapArray<T: ImmutableMappable>(_ type: T.Type, context: MapContext? = nil) throws -> [T] {
        guard let array = try mapJSON() as? [[String : Any]] else {
            throw MoyaError.jsonMapping(self)
        }
        return try Mapper<T>(context: context).mapArray(JSONArray: array)
    }
}
/// Extension for processing Responses into Mappable objects through ObjectMapper
public extension PrimitiveSequence where TraitType == SingleTrait, ElementType == Response {
    /// Maps data received from the signal into an object
    /// which implements the Mappable protocol and returns the result back
    /// If the conversion fails, the signal errors.
    public func mapObject<T: BaseMappable>(_ type: T.Type, context: MapContext? = nil) -> Single<T> {
        return flatMap { response -> Single<T> in
            return Single.just(try response.mapObject(type, context: context))
        }
    }
    /// Maps data received from the signal into an array of objects
    /// which implement the Mappable protocol and returns the result back
    /// If the conversion fails, the signal errors.
    public func mapArray<T: BaseMappable>(_ type: T.Type, context: MapContext? = nil) -> Single<[T]> {
        return flatMap { response -> Single<[T]> in
            return Single.just(try response.mapArray(type, context: context))
        }
    }
}
// MARK: - ImmutableMappable
public extension PrimitiveSequence where TraitType == SingleTrait, ElementType == Response {
    /// Maps data received from the signal into an object
    /// which implements the ImmutableMappable protocol and returns the result back
    /// If the conversion fails, the signal errors.
    public func mapObject<T: ImmutableMappable>(_ type: T.Type, context: MapContext? = nil) -> Single<T> {
        return flatMap { response -> Single<T> in
            return Single.just(try response.mapObject(type, context: context))
        }
    }
    /// Maps data received from the signal into an array of objects
    /// which implement the ImmutableMappable protocol and returns the result back
    /// If the conversion fails, the signal errors.
    public func mapArray<T: ImmutableMappable>(_ type: T.Type, context: MapContext? = nil) -> Single<[T]> {
        return flatMap { response -> Single<[T]> in
            return Single.just(try response.mapArray(type, context: context))
        }
    }
}
/// Extension for processing Responses into Mappable objects through ObjectMapper
public extension ObservableType where E == Response {
    /// Maps data received from the signal into an object
    /// which implements the Mappable protocol and returns the result back
    /// If the conversion fails, the signal errors.
    public func mapObject<T: BaseMappable>(_ type: T.Type, context: MapContext? = nil) -> Observable<T> {
        return flatMap { response -> Observable<T> in
            return Observable.just(try response.mapObject(T.self, context: context))
        }
    }
    /// Maps data received from the signal into an array of objects
    /// which implement the Mappable protocol and returns the result back
    /// If the conversion fails, the signal errors.
    public func mapArray<T: BaseMappable>(_ type: T.Type, context: MapContext? = nil) -> Observable<[T]> {
        return flatMap { response -> Observable<[T]> in
            return Observable.just(try response.mapArray(T.self, context: context))
        }
    }
}
// MARK: - ImmutableMappable
public extension ObservableType where E == Response {
    /// Maps data received from the signal into an object
    /// which implements the ImmutableMappable protocol and returns the result back
    /// If the conversion fails, the signal errors.
    public func mapObject<T: ImmutableMappable>(_ type: T.Type, context: MapContext? = nil) -> Observable<T> {
        return flatMap { response -> Observable<T> in
            return Observable.just(try response.mapObject(T.self, context: context))
        }
    }
    /// Maps data received from the signal into an array of objects
    /// which implement the ImmutableMappable protocol and returns the result back
    /// If the conversion fails, the signal errors.
    public func mapArray<T: ImmutableMappable>(_ type: T.Type, context: MapContext? = nil) -> Observable<[T]> {
        return flatMap { response -> Observable<[T]> in
            return Observable.just(try response.mapArray(T.self, context: context))
        }
    }
}
