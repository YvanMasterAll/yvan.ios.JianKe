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
    
    @IBAction func gotoRegister(_ sender: Any) {
        let storyBoard = UIStoryboard.init(name: "Login", bundle: nil)
        let registerVC = storyBoard.instantiateViewController(withIdentifier: "Register")
        self.present(registerVC, animated: true, completion: nil)
    }
    @IBAction func goBackAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBOutlet weak var goBack: UIButton! {
        didSet {
            if self.isPushed {
                self.goBack.isHidden = false
            } else {
                self.goBack.isHidden = true
            }
        }
    }
    
    //声明区域
    open var isPushed: Bool = false
    
    //私有成员
    fileprivate let viewModel = LoginViewModel()
    fileprivate let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        
        setupUI()
        bindRx()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //隐藏导航栏
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    deinit {
        print("deinit: \(type(of: self))")
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
            self.loginButton.backgroundColor = ColorPrimary.lighterByHSL(amount: 0.3)
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
                case .ok:
                    if self.isPushed {
                        self.navigationController?.popViewController(animated: true)
                    } else {
                        self.dismiss(animated: true, completion: nil)
                    }
                case .empty:
                    break;
                case let .failed(message):
                    HUD.flash(HUDContentType.labeledError(title: message, subtitle: nil))
                }
            })
            .disposed(by: disposeBag)
    }
}
