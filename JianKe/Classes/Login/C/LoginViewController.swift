//
//  LoginViewController.swift
//  JianKe
//
//  Created by yiqiang on 2017/12/12.
//  Copyright © 2017年 yiqiang. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class LoginViewController: UIViewController {

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    //私有成员
    fileprivate let viewModel = LoginViewModel()
    fileprivate let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        
        setupUI()
        bindRx()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension LoginViewController {
    //初始化
    fileprivate func setupUI() {
        self.loginButton.backgroundColor = ColorPrimary
        applyLoginButton(enabled: false)
    }
    
    //登录按钮状态
    fileprivate func applyLoginButton(enabled: Bool) {
        self.loginButton.isEnabled = enabled
        if enabled {
            self.loginButton.backgroundColor = ColorPrimary
        } else {
            self.loginButton.backgroundColor = ColorPrimary.lighter(amount: 0.3)
        }
    }
    
    //Rx 绑定
    fileprivate func bindRx() {
        //inputs
        usernameTextField.rx.text.orEmpty
            .bind(to: viewModel.inputs.username)
            .disposed(by: disposeBag)
        passwordTextField.rx.text.orEmpty
            .bind(to: viewModel.inputs.password)
            .disposed(by: disposeBag)
        loginButton.rx.tap
            .bind(to: viewModel.inputs.loginTap)
            .disposed(by: disposeBag)
        //outputs
        viewModel.outputs.usernameUsable
            .drive()
            .disposed(by: disposeBag)
        viewModel.outputs.passwordUsable
            .drive()
            .disposed(by: disposeBag)
        viewModel.outputs.loginButtonEnabled
            .drive(onNext: { enabled in
                self.applyLoginButton(enabled: enabled)
            })
            .disposed(by: disposeBag)
        viewModel.outputs.loginResult
            .drive(onNext: { result in
                //关闭等待
                HUD.hide()
                switch result {
                case let .ok(message):
                    print(message)
                case .empty:
                    print("empty")
                case let .failed(message):
                    print(message)
                }
            })
            .disposed(by: disposeBag)
    }
}
