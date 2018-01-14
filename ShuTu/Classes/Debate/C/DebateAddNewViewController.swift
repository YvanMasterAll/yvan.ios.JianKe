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
import RichEditorView
import Photos
import Kingfisher

class DebateAddNewViewController: UIViewController {

    @IBOutlet weak var richEditorView: RichEditorView! {
        didSet {
            self.richEditorView.delegate = self
        }
    }
    @IBOutlet weak var stepButton: PMSuperButton! {
        didSet {
            self.buttonEnabled(false)
        }
    }
    @IBOutlet weak var actionViewBottomConstraint: NSLayoutConstraint!
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
        super.viewDidAppear(animated)
        
        self.stepButton.isEnabled = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        //隐藏导航栏
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        //添加 ActionView 的阴影
        GeneralFactory.generateRectShadow(layer: self.actionView.layer, rect: CGRect(x: 0, y: -1, width: SW, height: 1), color: GMColor.grey800Color().cgColor)
        self.view.bringSubview(toFront: self.actionView)
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
    fileprivate var keyboardHeight: CGFloat = 0
    fileprivate var currentStep: Int = 0 //步骤
    //第二步页面
    fileprivate lazy var secondTextField: HoshiTextField = {
        let textField = HoshiTextField(frame: CGRect.zero)
        textField.borderInactiveColor = ColorPrimary
        textField.borderActiveColor = GMColor.grey300Color()
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
        //NavigationBarView
        GeneralFactory.generateRectShadow(layer: self.navigationBar.layer, rect: CGRect(x: 0, y: self.navigationBar.frame.size.height, width: SW, height: 0.5), color: GMColor.grey800Color().cgColor)
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
                    self?.textField.borderInactiveColor = ColorPrimary
                } else {
                    self?.textField.borderInactiveColor = GMColor.red900Color()
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
    //Keyboard Notification
    @objc fileprivate func keyBoardWillShow(_ notification: Notification) {
        //获取键盘高度
        let kbInfo = notification.userInfo
        let kbRect = (kbInfo?[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let height = kbRect.height
        self.keyboardHeight = height

        UIView.animate(withDuration: 0.25, animations: { [weak self] () -> Void in
            self?.actionViewBottomConstraint.constant = height
            self?.view.layoutIfNeeded()
        })
    }
    @objc fileprivate func keyBoardWillHide(_ notification: Notification) {
        UIView.animate(withDuration: 0.25, animations: { [weak self] () -> Void in
            self?.actionViewBottomConstraint.constant = 0
            self?.view.layoutIfNeeded()
        })
    }
    //Step Action
    @objc fileprivate func stepChanged() {
        if self.currentStep == 0 { //跳转到第二步
            currentStep = 1
            self.textField.isHidden = true
            self.secondTextField.isHidden = false
            self.stepButton.setTitle("上一步", for: .normal)
        } else { //返回第一步
            currentStep = 0
            self.secondTextField.isHidden = true
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
    //插入图片
    fileprivate func insertImage() {
        guard self.selectedAssets.count == 1  else { return }
        
        let option = PHContentEditingInputRequestOptions.init()
        option.canHandleAdjustmentData = {(adjustmeta: PHAdjustmentData)
            -> Bool in
            return true
        }
        self.selectedAssets[0].phAsset?.requestContentEditingInput(with: option, completionHandler: { [weak self] (contentEditingInput:PHContentEditingInput?, info: [AnyHashable : Any]) in
            let originPath = contentEditingInput!.fullSizeImageURL!.absoluteString
            let imagePath = String(originPath[originPath.index(originPath.startIndex, offsetBy: 7)...])
            self?.richEditorView.insertImage(imagePath, alt: self?.selectedAssets[0].originalFileName ?? "")
        })
    }
}

extension DebateAddNewViewController: TLPhotosPickerViewControllerDelegate, RichEditorDelegate {
    //TLPhotosPickerViewControllerDelegate
    func dismissPhotoPicker(withTLPHAssets: [TLPHAsset]) {
        //获取选中图片
        self.selectedAssets = withTLPHAssets
        //插入图片
        self.insertImage()
    }
    func dismissComplete() {
        
    }
    func photoPickerDidCancel() {
        
    }
    func didExceedMaximumNumberOfSelection(picker: TLPhotosPickerViewController) {
        
    }
    //RichEditorDelegate
    func richEditorDidLoad(_ editor: RichEditorView) {
        self.richEditorView.setTextColor(GMColor.grey900Color())
        self.richEditorView.placeholder = "请输入问题描述"
        self.richEditorView.setFontSize(13)
        self.richEditorView.lineHeight = 15
    }

}
