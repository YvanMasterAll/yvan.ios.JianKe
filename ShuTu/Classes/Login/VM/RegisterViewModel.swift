//
//  RegisterViewModel.swift
//  ShuTu
//
//  Created by yiqiang on 2018/2/1.
//  Copyright © 2018年 yiqiang. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

public struct RegisterViewModelInput {
    var phone: PublishSubject<String>
    var vcode: PublishSubject<String>
    var password: PublishSubject<String>
    var registerTap: PublishSubject<Void>
    var verifyTap: PublishSubject<Void>
}
public struct RegisterViewModelOutput {
    var phoneUsable: Driver<Bool>?
    var vcodeUsable: Driver<Bool>?
    var registerUsable: Driver<Bool>?
    var vcodeStatus: Variable<Result2>
    var passwordUsable: Driver<Bool>?
    var registerStatus: Variable<Result2>
}

public class RegisterViewModel {
    fileprivate struct RegisterModel {
        var disposeBag: DisposeBag
        var staticPhone: String
    }
    //Inputs
    open var inputs: RegisterViewModelInput = {
        return RegisterViewModelInput.init(phone: PublishSubject<String>(), vcode: PublishSubject<String>(), password: PublishSubject<String>(), registerTap: PublishSubject<Void>(), verifyTap: PublishSubject<Void>())
    }()
    //Outputs
    open var outputs: RegisterViewModelOutput = {
        return RegisterViewModelOutput.init(phoneUsable: nil, vcodeUsable: nil, registerUsable: nil, vcodeStatus: Variable<Result2>(.empty), passwordUsable: nil, registerStatus: Variable<Result2>(.empty))
    }()
    //私有成员
    fileprivate var registerModel: RegisterModel!
    fileprivate var service = UserService.instance
    
    init(disposeBag: DisposeBag) {
        //Model
        registerModel = RegisterModel.init(disposeBag: disposeBag, staticPhone: "")
        
        outputs.phoneUsable = inputs.phone.asDriver(onErrorJustReturn: "")
            .flatMapLatest{ phone in
                return self.service.validatePhone(phone)
                    .asDriver(onErrorJustReturn: false)
            }
        outputs.vcodeUsable = inputs.vcode.asDriver(onErrorJustReturn: "")
            .flatMapLatest { vcode in
                if vcode.count == 6 {
                    return Observable.just(true).asDriver(onErrorJustReturn: false)
                } else {
                    return Observable.just(false).asDriver(onErrorJustReturn: false)
                }
            }
        outputs.passwordUsable = inputs.password.asDriver(onErrorJustReturn: "")
            .flatMapLatest { password in
                if password.count >= 6 {
                    return Observable.just(true).asDriver(onErrorJustReturn: false)
                } else {
                    return Observable.just(false).asDriver(onErrorJustReturn: false)
                }
        }
        outputs.registerUsable = Driver.combineLatest(outputs.phoneUsable!, outputs.vcodeUsable!, outputs.passwordUsable!) { phoneUsable, vcodeUsable, passwordUsable in
            return phoneUsable && vcodeUsable && passwordUsable
        }
        let phoneAndPhoneUsable = Driver.combineLatest(inputs.phone.asDriver(onErrorJustReturn: ""), outputs.phoneUsable!) { ($0, $1) }
        inputs.verifyTap.asDriver(onErrorJustReturn: ())
            .withLatestFrom(phoneAndPhoneUsable)
            .asObservable()
            .subscribe(onNext: { [weak self] (phone, usable) in
                guard usable else {
                    HUD.flash(.label("获取验证码失败"))
                    self?.outputs.vcodeStatus.value = Error001
                    return
                }
                if Environment.vtime.value > 0 {
                    HUD.flash(.label("请勿频繁操作"))
                    self?.outputs.vcodeStatus.value = Error001
                    return
                }
                
                HUD.show(.progress)
                //保存手机号
                self?.registerModel.staticPhone = phone
                //获取验证码
                self?.service.getVcode(phone, handler: { error in
                    if error != nil {
                        HUD.flash(.label("获取验证码失败"))
                        self?.outputs.vcodeStatus.value = Error001
                    } else {
                        //计时
                        Environment.setVtime()
                        HUD.flash(.label("成功获取验证码"))
                        self?.outputs.vcodeStatus.value = Ok001
                    }
                })
            })
            .disposed(by: registerModel.disposeBag)
        let formData = Driver.combineLatest(inputs.phone.asDriver(onErrorJustReturn: ""), inputs.password.asDriver(onErrorJustReturn: ""), inputs.vcode.asDriver(onErrorJustReturn: "")) { ($0, $1, $2) }
        inputs.registerTap.asDriver(onErrorJustReturn: ())
            .withLatestFrom(formData)
            .drive(onNext: { (phone, password, vcode) in
                //遮盖
                HUD.show(.progress)
                //测试
                self.service.register(phone, password)
                    .asObservable()
                    .subscribe(onNext: { result in
                        self.outputs.registerStatus.value = result
                    })
                    .disposed(by: self.registerModel.disposeBag)
                return
                
                //验证码验证
//                self.service.verifyVcode(phone, vcode, handler: { error in
//                    if error != nil {
//                        //验证码错误
//                        HUD.flash(.label("验证码错误"))
//                        self.outputs.registerStatus.value = .empty
//                    } else {
//                        //验证码正确, 发起注册
//                        self.service.register(phone, password)
//                            .asObservable()
//                            .subscribe(onNext: { result in
//                                self.outputs.registerStatus.value = result
//                            })
//                            .disposed(by: self.registerModel.disposeBag)
//                    }
//                })
            })
            .disposed(by: registerModel.disposeBag)
    }

}
