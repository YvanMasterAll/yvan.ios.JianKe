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

public enum Result {
    case ok(message: String)
    case empty
    case failed(message: String)
}

extension Result {
    var isVaild: Bool {
        switch self {
        case .ok:
            return true
        default:
            return false
        }
    }
}

//Using RxSwift DelegateProxy as a delegate for UIApplicationDelegate
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
