//
//  RegisterViewController.swift
//  ShuTu
//
//  Created by yiqiang on 2018/1/19.
//  Copyright © 2018年 yiqiang. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

typealias RegisterBlock = (_ status: String) -> Void

class RegisterViewController: BaseViewController {

    @IBOutlet weak var registerButton: UIButton! {
        didSet {
            self.applyRegisterButton(enabled: false)
        }
    }
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var verifyButton: UIButton! {
        didSet {
            self.applyVerifyButton(enabled: false)
        }
    }
    @IBOutlet weak var vcodeTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBAction func goBack(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK: - 声明区域
    open var block: RegisterBlock?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        bindRx()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    //MARK: - 私有成员
    fileprivate var viewModel: RegisterViewModel!
    fileprivate let disposeBag = DisposeBag()
}

extension RegisterViewController {

    //MARK: - 初始化
    fileprivate func setupUI() {
        
    }
    fileprivate func bindRx() {
        self.viewModel = RegisterViewModel.init(disposeBag: disposeBag)
        //Inputs
        phoneTextField.rx.text.orEmpty
            .bind(to: viewModel.inputs.phone)
            .disposed(by: self.disposeBag)
        vcodeTextField.rx.text.orEmpty
            .bind(to: viewModel.inputs.vcode)
            .disposed(by: self.disposeBag)
        passwordTextField.rx.text.orEmpty
            .bind(to: viewModel.inputs.password)
            .disposed(by: self.disposeBag)
        registerButton.rx.tap
            .bind(to: viewModel.inputs.registerTap)
            .disposed(by: disposeBag)
        verifyButton.rx.tap
            .bind(to: viewModel.inputs.verifyTap)
            .disposed(by: disposeBag)
        //Outputs
        viewModel.outputs.phoneUsable?
            .drive(onNext: { enabled in
                self.applyVerifyButton(enabled: enabled)
            })
            .disposed(by: disposeBag)
        viewModel.outputs.phoneUsable!
            .drive(onNext: { usable in
                self.applyVerifyButton(enabled: usable)
            })
            .disposed(by: disposeBag)
        viewModel.outputs.registerUsable!
            .drive(onNext: { usable in
                self.applyRegisterButton(enabled: usable)
            })
            .disposed(by: disposeBag)
        viewModel.outputs.vcodeStatus
            .asObservable()
            .subscribe(onNext: { [weak self] result in
                switch result {
                case .failed:
                    self?.applyVerifyButton(enabled: true)
                case .ok:
                    self?.applyVerifyButton(enabled: false)
                default:
                    break
                }
            })
            .disposed(by: disposeBag)
        viewModel.outputs.registerStatus
            .asObservable()
            .subscribe(onNext: { [weak self] result in
                switch result {
                case .exist:
                    HUD.flash(.label("用户已注册"))
                case .failed:
                    HUD.flash(.label("注册失败"))
                case .ok:
                    HUD.flash(.label("注册成功"))
                    //通知登录界面
                    self?.block?("ok")
                    self?.dismiss(animated: true, completion: nil)
                default:
                    break
                }
            })
            .disposed(by: disposeBag)
        Environment.vtime.asObservable()
            .subscribe(onNext: { [weak self] time in
                if time == 0 {
                    self?.verifyButton.setTitle("发送验证码", for: .normal)
                    self?.applyVerifyButton(enabled: true)
                } else {
                    self?.verifyButton.setTitle("\(time)", for: .normal)
                }
            })
            .disposed(by: disposeBag)
    }
    
    //MARK: - 按钮状态变更
    fileprivate func applyVerifyButton(enabled: Bool) {
        self.verifyButton.isEnabled = enabled
        if enabled {
            self.verifyButton.setTitleColor(ColorPrimary, for: .normal)
        } else {
            self.verifyButton.setTitleColor(ColorPrimary.lighterByHSL(amount: 0.3), for: .normal)
        }
    }
    fileprivate func applyRegisterButton(enabled: Bool) {
        self.registerButton.isEnabled = enabled
        if enabled {
            self.registerButton.backgroundColor = ColorPrimary
        } else {
            self.registerButton.backgroundColor = ColorPrimary.lighterByHSL(amount: 0.3)
        }
    }
}
