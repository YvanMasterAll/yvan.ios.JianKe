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
import RxCocoa
import RxSwift
import RichEditorView
import Photos
import Kingfisher

class DebateAddNewViewController: BaseViewController {

    @IBOutlet weak var richEditorView: RichEditorView! {
        didSet {
            self.richEditorView.delegate = self
        }
    }
    @IBOutlet weak var stepButton: STButton! {
        didSet {
            self.buttonEnabled(false)
        }
    }
    @IBOutlet weak var actionViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var textField: HoshiTextField!
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
    
    deinit {
        //移除通知
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK: - 私有成员
    fileprivate lazy var photoPicker: TLPhotosPickerViewController! = {
        //相册控制器
        let photoPicker = GeneralFactory.generatePhotoPicker(self.selectedAssets)
        photoPicker.delegate = self
        
        return photoPicker
    }()
    fileprivate var selectedAssets = [TLPHAsset]()
    fileprivate var keyboardHeight: CGFloat = 0
    fileprivate var currentStep: Int = 0 //步骤
    fileprivate lazy var emojiView: STEmojiView = { //表情键盘
        let emojiView = STEmojiView.init(frame: CGRect.init(x: 0, y: SH, width: SW, height: 200))
        emojiView.isHidden = false
        self.view.addSubview(emojiView)
        emojiView.snp.makeConstraints{ make in
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
            make.top.equalTo(self.actionView.snp.bottom)
            make.height.equalTo(200)
        }
        emojiView.delegate = self
        self.view.bringSubview(toFront: emojiView)
        
        return emojiView
    }()
    //ViewModel
    fileprivate var viewModel: DebateAddNewViewModel!
    fileprivate let disposeBag = DisposeBag()
}

extension DebateAddNewViewController {

    //MARK: - 初始化
    fileprivate func setupUI() {
        //Step
        self.stepButton.addTarget(self, action: #selector(self.send), for: .touchUpInside)
        //NavigationBarView
        GeneralFactory.generateRectShadow(layer: self.navigationBar.layer, rect: CGRect(x: 0, y: self.navigationBar.frame.size.height, width: SW, height: 0.5), color: STColor.grey800Color().cgColor)
        self.navigationBarLeftImage.setIcon(icon: .fontAwesome(.angleLeft), textColor: STColor.grey900Color(), backgroundColor: UIColor.clear, size: nil)
        self.navigationBarLeftImage.isUserInteractionEnabled = true
        let goBackTapGes = UITapGestureRecognizer(target: self, action: #selector(self.goBack))
        self.navigationBarLeftImage.addGestureRecognizer(goBackTapGes)
        self.view.bringSubview(toFront: self.navigationBar)
        //Action View
        self.actionAddImage.setIcon(icon: .fontAwesome(.fileImageO), textColor: STColor.grey600Color(), backgroundColor: UIColor.clear, size: nil)
        self.actionAddImage.isUserInteractionEnabled = true
        let addImageTapGes = UITapGestureRecognizer(target: self, action: #selector(self.gotoPhotoPicker))
        self.actionAddImage.addGestureRecognizer(addImageTapGes)
        self.actionAddAt.setIcon(icon: .fontAwesome(.smileO), textColor: STColor.grey600Color(), backgroundColor: UIColor.clear, size: nil)
        self.actionAddAt.isUserInteractionEnabled = true
        let addEmojiTapGes = UITapGestureRecognizer(target: self, action: #selector(self.showEmoji))
        self.actionAddAt.addGestureRecognizer(addEmojiTapGes)
        //添加 ActionView 的阴影
        GeneralFactory.generateRectShadow(layer: self.actionView.layer, rect: CGRect(x: 0, y: -1, width: SW, height: 1), color: STColor.grey800Color().cgColor)
        self.view.bringSubview(toFront: self.actionView)
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
                    self?.textField.borderInactiveColor = STColor.red900Color()
                }
            })
            .disposed(by: self.disposeBag)
        viewModel.outputs.sendResult
            .asObservable()
            .subscribe(onNext: { result in
                switch result {
                case .ok:
                    HUD.flash(.label("成功添加话题"))
                    break
                case .failed:
                    HUD.flash(.label("添加话题失败"))
                    break
                default:
                    HUD.hide()
                    break
                }
            })
            .disposed(by: self.disposeBag)
    }
    
    //MARK: - Keyboard Action
    @objc fileprivate func keyBoardWillShow(_ notification: Notification) {
        self.emojiView.isHidden = true
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
    
    //MARK: - 按钮事件
    @objc fileprivate func send() {
        HUD.show(.progress)
        self.viewModel.inputs.sendTap.onNext((self.textField.text!, self.richEditorView.contentHTML))
    }
    fileprivate func insertImage() {
        guard self.selectedAssets.count == 1  else { return }
        
        self.selectedAssets[0].fullResolutionImagePath(handler: { [unowned self] imagePath in
            self.richEditorView.insertImage(imagePath, alt: self.selectedAssets[0].originalFileName ?? "")
        })
    }
    @objc fileprivate func gotoPhotoPicker() {
        //隐藏 Tabbar
        self.hidesBottomBarWhenPushed = true
        self.present(self.photoPicker, animated: true, completion: nil)
        self.hidesBottomBarWhenPushed = false
    }
    @objc fileprivate func showEmoji() {
        //取消焦点
        self.textField.resignFirstResponder()
        self.richEditorView.blur()
        self.emojiView.isHidden = false
        
        UIView.animate(withDuration: 0.25, animations: { [weak self] () -> Void in
            self?.actionViewBottomConstraint.constant = 200
            self?.view.layoutIfNeeded()
        })
    }
    @objc fileprivate func goBack() {
        if (navigationController != nil) {
            navigationController?.popViewController(animated: true)
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
    
    //MARK: - 按钮状态变更
    fileprivate func buttonEnabled(_ enabled: Bool) {
        self.stepButton.isEnabled = enabled
        if enabled {
            self.stepButton.setTitleColor(STColor.grey900Color(), for: .normal)
        } else {
            self.stepButton.setTitleColor(STColor.grey300Color(), for: .normal)
        }
    }
}

extension DebateAddNewViewController: TLPhotosPickerViewControllerDelegate, RichEditorDelegate, STEmojiViewDelegate {
    
    //MARK: - STEmojiViewDelegate
    func emojiClicked(_ imageUrl: String) {
        self.richEditorView.insertEmoji(imageUrl, alt: "emoji")
    }
    
    //MARK: - TLPhotosPickerViewControllerDelegate
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
    
    //MARK: - RichEditorDelegate
    func richEditorDidLoad(_ editor: RichEditorView) {
        self.richEditorView.setTextColor(STColor.grey900Color())
        self.richEditorView.placeholder = "请输入问题描述"
        self.richEditorView.setFontSize(13)
        self.richEditorView.lineHeight = 15
    }

}
