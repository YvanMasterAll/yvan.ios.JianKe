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

class LoginViewController: BaseViewController {

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    @IBAction func gotoRegister(_ sender: Any) {
        let registerVC = GeneralFactory.getVCfromSb("Login", "Register") as! RegisterViewController
        registerVC.block = { status in
            if status == "ok" {
                //注册成功
                if self.isPushed {
                    self.navigationController?.popViewController(animated: true)
                } else {
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }
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
    
    //MARK: - 声明区域
    open var isPushed: Bool = false //true, 表示登录页在其它页面被打开
    
    //MARK: - 私有成员
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

    //MARK: - 初始化
    fileprivate func setupUI() {
        self.loginButton.backgroundColor = ColorPrimary
        applyLoginButton(enabled: false)
    }
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
            .drive(onNext: { [weak self] result in
                //关闭等待
                HUD.hide()
                guard let _ = self else { return }
                switch result {
                case .ok:
                    if self!.isPushed {
                        self?.navigationController?.popViewController(animated: true)
                    } else {
                        self!.dismiss(animated: true, completion: nil)
                    }
                case .empty:
                    break;
                case let .failed(message):
                    HUD.flash(HUDContentType.label(message))
                default:
                    break
                }
            })
            .disposed(by: disposeBag)
    }
    
    /// 按钮状态变更
    fileprivate func applyLoginButton(enabled: Bool) {
        self.loginButton.isEnabled = enabled
        if enabled {
            self.loginButton.backgroundColor = ColorPrimary
        } else {
            self.loginButton.backgroundColor = ColorPrimary.lighterByHSL(amount: 0.3)
        }
    }
    
}
