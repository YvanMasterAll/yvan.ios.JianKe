//
//  LoginViewModel.swift
//  JianKe
//
//  Created by yiqiang on 2017/12/12.
//  Copyright © 2017年 yiqiang. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

public protocol LoginViewModelInput {
    var username: PublishSubject<String?>{ get }
    var password: PublishSubject<String?>{ get }
    var loginTap: PublishSubject<Void>{ get }
}
public protocol LoginViewModelOutput {
    var usernameUsable: Driver<ResultType>{ get }
    var passwordUsable: Driver<Bool>{ get }
    var loginButtonEnabled: Driver<Bool>{ get }
    var loginResult: Driver<ResultType>{ get }
}
public protocol LoginViewModelType {
    var inputs: LoginViewModelInput { get }
    var outputs: LoginViewModelOutput { get }
}

public class LoginViewModel: LoginViewModelInput, LoginViewModelOutput, LoginViewModelType {

    //MARK: - inputs
    public var username = PublishSubject<String?>()
    public var password = PublishSubject<String?>()
    public var loginTap = PublishSubject<Void>()

    //MARK: - outputs
    public var usernameUsable: Driver<ResultType>
    public var passwordUsable: Driver<Bool>
    public var loginButtonEnabled: Driver<Bool>
    public var loginResult: Driver<ResultType>

    //MARK: - gets
    public var inputs: LoginViewModelInput { return self }
    public var outputs: LoginViewModelOutput { return self }
    
    init() {
        //服务实例
        let service = UserService.instance
        usernameUsable = username.asDriver(onErrorJustReturn: nil)
            .flatMapLatest { username in
                return service.validateUsername(username!)
                    .asDriver(onErrorJustReturn: ErrorFailed)
            }
        passwordUsable = password
            .map{ $0!.count > 0 }
            .asDriver(onErrorJustReturn: false)
        loginButtonEnabled = Driver.combineLatest(usernameUsable, passwordUsable)
            { usernameUsable, passwordUsable in
                return usernameUsable.isVaild && passwordUsable
            }
        let usernameAndPassword = Driver.combineLatest(username.asDriver(onErrorJustReturn: nil), password.asDriver(onErrorJustReturn: nil))
            { ($0, $1) }
        loginResult = loginTap.asDriver(onErrorJustReturn: ())
            .withLatestFrom(usernameAndPassword)
            .flatMapLatest { username, password in
                //显示等待
                HUD.show(.progress)
                return service.signIn(username!, password!)
                    .asDriver(onErrorJustReturn: ErrorFailed)
            }
    }
}
