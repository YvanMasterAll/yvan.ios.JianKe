//
//  DebateAddNewViewController.swift
//  ShuTu
//
//  Created by yiqiang on 2017/12/31.
//  Copyright © 2017年 yiqiang. All rights reserved.
//

import UIKit
import IQKeyboardManager
import SnapKit
import PMSuperButton
import RxCocoa
import RxSwift

class DebateAddNewViewController: UIViewController {

    @IBOutlet weak var stepButton: PMSuperButton! {
        didSet {
            self.buttonEnabled(false)
        }
    }
    @IBOutlet weak var actionViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var textView: RichTextView!
    @IBOutlet weak var textField: HoshiTextField!
    @IBOutlet weak var actionSet: UIImageView!
    @IBOutlet weak var actionAddAt: UIImageView!
    @IBOutlet weak var actionAddImage: UIImageView!
    @IBOutlet weak var actionView: UIView!
    @IBOutlet weak var navigationBar: UIView!
    @IBOutlet weak var navigationBarLeftImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        bindRx()
        
        //键盘监听
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardWillShow(_:)), name:NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardWillHide(_:)), name:NSNotification.Name.UIKeyboardWillHide, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.stepButton.isEnabled = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        //隐藏导航栏
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        //添加 ActionView 的阴影
        GeneralFactory.generateRectShadow(layer: self.actionView.layer, rect: CGRect(x: 0, y: -1, width: SW, height: 1), color: GMColor.grey600Color().cgColor)
    }
    
    deinit {
        //移除通知
        NotificationCenter.default.removeObserver(self)
        print("deinit: \(type(of: self))")
    }
    
    //私有成员
    fileprivate lazy var photoPicker: TLPhotosPickerViewController = {
        let photoPicker = TLPhotosPickerViewController()
        photoPicker.delegate = self
        photoPicker.didExceedMaximumNumberOfSelection = { [weak self] (picker) in
            //图片数超过设定
        }
        var configure = TLPhotosPickerConfigure()
        configure.maxSelectedAssets = 1
        configure.numberOfColumn = 3
        configure.allowedVideo = false
        photoPicker.configure = configure
        photoPicker.selectedAssets = self.selectedAssets
        
        return photoPicker
    }()
    fileprivate var selectedAssets = [TLPHAsset]()
    fileprivate var isKeyboardShow: Bool = false
    fileprivate var keyboardHeight: CGFloat = 0
    fileprivate var currentStep: Int = 0 //步骤
    //第二步页面
    fileprivate lazy var secondTextField: HoshiTextField = {
        let textField = HoshiTextField(frame: CGRect.zero)
        textField.borderInactiveColor = GMColor.grey500Color()
        textField.borderActiveColor = ColorPrimary
        textField.placeholderColor = GMColor.grey500Color()
        textField.placeholder = "搜索并添加相关话题"
        textField.borderStyle = UITextBorderStyle.none
        textField.font = UIFont.systemFont(ofSize: 14)
        textField.isHidden = true //隐藏
        self.view.addSubview(textField)
        
        return textField
    }()
    //ViewModel
    fileprivate var viewModel: DebateAddNewViewModel!
    fileprivate let disposeBag = DisposeBag()
}

extension DebateAddNewViewController {
    //初始化
    fileprivate func setupUI() {
        //Step
        self.secondTextField.snp.makeConstraints { make in
            make.height.equalTo(50)
            make.left.equalTo(14)
            make.right.equalTo(14)
            make.top.equalTo(self.navigationBar.snp.bottom).offset(4)
        }
        self.stepButton.addTarget(self, action: #selector(self.stepChanged), for: .touchUpInside)
        //TextView
        self.textView.delegate = self
        //NavigationBarView
        GeneralFactory.generateRectShadow(layer: self.navigationBar.layer, rect: CGRect(x: 0, y: self.navigationBar.frame.size.height, width: SW, height: 0.5), color: GMColor.grey900Color().cgColor)
        self.navigationBarLeftImage.setIcon(icon: .fontAwesome(.angleLeft), textColor: GMColor.grey900Color(), backgroundColor: UIColor.clear, size: nil)
        self.navigationBarLeftImage.isUserInteractionEnabled = true
        let goBackTapGes = UITapGestureRecognizer(target: self, action: #selector(self.goBack))
        self.navigationBarLeftImage.addGestureRecognizer(goBackTapGes)
        self.view.bringSubview(toFront: self.navigationBar)
        //Action View
        self.actionAddImage.setIcon(icon: .fontAwesome(.fileImageO), textColor: GMColor.grey600Color(), backgroundColor: UIColor.clear, size: nil)
        self.actionAddImage.isUserInteractionEnabled = true
        let addImageTapGes = UITapGestureRecognizer(target: self, action: #selector(self.gotoPhotoPicker))
        self.actionAddImage.addGestureRecognizer(addImageTapGes)
        self.actionAddAt.setIcon(icon: .fontAwesome(.at), textColor: GMColor.grey600Color(), backgroundColor: UIColor.clear, size: nil)
        self.actionAddAt.isUserInteractionEnabled = true
        self.actionSet.setIcon(icon: .fontAwesome(.cog), textColor: GMColor.grey600Color(), backgroundColor: UIColor.clear, size: nil)
        self.actionSet.isUserInteractionEnabled = true
    }
    fileprivate func bindRx() {
        //View Model
        self.viewModel = DebateAddNewViewModel(disposeBag: self.disposeBag)
        //Rx
        (self.textField as UITextField).rx.text.orEmpty
            .bind(to: self.viewModel.inputs.title)
            .disposed(by: self.disposeBag)
        self.viewModel.outputs.titleUsable?.asObservable()
            .subscribe(onNext: { [weak self] usable in
                self?.buttonEnabled(usable)
                if usable {
                    self?.textField.borderActiveColor = ColorPrimary
                    self?.textField.borderInactiveColor = GMColor.grey50Color()
                } else {
                    self?.textField.borderActiveColor = GMColor.red500Color()
                    self?.textField.borderInactiveColor = GMColor.red500Color()
                }
            })
            .disposed(by: self.disposeBag)
    }
    //NavigationBarItem Action
    @objc fileprivate func goBack() {
        if (navigationController != nil) {
            navigationController?.popViewController(animated: true)
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
    //ActionView Action
    @objc fileprivate func gotoPhotoPicker() {
        //隐藏 Tabbar
        self.hidesBottomBarWhenPushed = true
        self.present(self.photoPicker, animated: true, completion: nil)
        self.hidesBottomBarWhenPushed = false
    }
    //TextView Editor
    fileprivate func textViewAddImage() {
        if let asset = self.selectedAssets.first {
            if let image = asset.fullResolutionImage {
                self.textView.insertImage(image, mode: .FitTextView)
            } else {
                //获取图片资源错误
            }
        }
    }
    //Keyboard Notification
    @objc fileprivate func keyBoardWillShow(_ notification: Notification) {
        isKeyboardShow = true
        //获取键盘高度
        let kbInfo = notification.userInfo
        let kbRect = (kbInfo?[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        var height = kbRect.height
        let offHeight = SH - height
        self.keyboardHeight = height
        
        if self.textView.isFirstResponder {
            height += -self.textView.frame.origin.y + 20 + 4
            self.textView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: self.textView.frame.height - offHeight + self.actionView.frame.height + 20 + 4, right: 0)
        }

        UIView.animate(withDuration: 0.25, animations: { [weak self] () -> Void in
            self?.actionViewBottomConstraint.constant = height
            self?.view.layoutIfNeeded()
        })
    }
    @objc fileprivate func keyBoardWillHide(_ notification: Notification) {
        isKeyboardShow = true
        
        UIView.animate(withDuration: 0.25, animations: { [weak self] () -> Void in
            self?.textView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            self?.actionViewBottomConstraint.constant = 0
            self?.view.layoutIfNeeded()
        })
    }
    //Step Action
    @objc fileprivate func stepChanged() {
        if self.currentStep == 0 { //跳转到第二步
            currentStep = 1
            self.textView.isHidden = true
            self.textField.isHidden = true
            self.secondTextField.isHidden = false
            self.stepButton.setTitle("上一步", for: .normal)
        } else { //返回第一步
            currentStep = 0
            self.secondTextField.isHidden = true
            self.textView.isHidden = false
            self.textField.isHidden = false
            self.stepButton.setTitle("下一步", for: .normal)
        }
    }
    //Button Enabled
    fileprivate func buttonEnabled(_ enabled: Bool) {
        self.stepButton.isEnabled = enabled
        if enabled {
            self.stepButton.setTitleColor(GMColor.grey900Color(), for: .normal)
        } else {
            self.stepButton.setTitleColor(GMColor.grey300Color(), for: .normal)
        }
    }
}

extension DebateAddNewViewController: TLPhotosPickerViewControllerDelegate, UITextViewDelegate {
    //TLPhotosPickerViewControllerDelegate
    func dismissPhotoPicker(withTLPHAssets: [TLPHAsset]) {
        //获取选中图片
        self.selectedAssets = withTLPHAssets
        //添加图片
        self.textViewAddImage()
    }
    func dismissComplete() {
        
    }
    func photoPickerDidCancel() {
        
    }
    func didExceedMaximumNumberOfSelection(picker: TLPhotosPickerViewController) {
        
    }
    //TextViewDelegate
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        if self.isKeyboardShow { //焦点改变
            let height = keyboardHeight - self.textView.frame.origin.y + 20 + 4
            let offHeight = SH - keyboardHeight
            self.textView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: self.textView.frame.height - offHeight + self.actionView.frame.height + 20 + 4, right: 0)
            
            UIView.animate(withDuration: 0.25, animations: { [weak self] () -> Void in
                self?.actionViewBottomConstraint.constant = height
                self?.view.layoutIfNeeded()
            })
        }
        
        return true
    }

}
