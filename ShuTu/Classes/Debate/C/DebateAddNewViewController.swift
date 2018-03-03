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

class DebateAddNewViewController: BaseViewController {

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
    fileprivate lazy var emojiView: EmojiView = { //表情键盘
        let emojiView = EmojiView.init(frame: CGRect.init(x: 0, y: SH, width: SW, height: 200))
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
    //初始化
    fileprivate func setupUI() {
        //Step
        self.stepButton.addTarget(self, action: #selector(self.send), for: .touchUpInside)
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
        self.actionAddAt.setIcon(icon: .fontAwesome(.smileO), textColor: GMColor.grey600Color(), backgroundColor: UIColor.clear, size: nil)
        self.actionAddAt.isUserInteractionEnabled = true
        let addEmojiTapGes = UITapGestureRecognizer(target: self, action: #selector(self.showEmoji))
        self.actionAddAt.addGestureRecognizer(addEmojiTapGes)
        //添加 ActionView 的阴影
        GeneralFactory.generateRectShadow(layer: self.actionView.layer, rect: CGRect(x: 0, y: -1, width: SW, height: 1), color: GMColor.grey800Color().cgColor)
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
                    self?.textField.borderInactiveColor = GMColor.red900Color()
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
    //Keyboard Notification
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
    //按钮事件
    @objc fileprivate func send() {
        HUD.show(.progress)
        self.viewModel.inputs.sendTap.onNext((self.textField.text!, self.richEditorView.contentHTML))
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

extension DebateAddNewViewController: TLPhotosPickerViewControllerDelegate, RichEditorDelegate, EmojiViewDelegate {
    //表情选择事件
    func emojiClicked(_ imageUrl: String) {
        self.richEditorView.insertImage(imageUrl, alt: "emoji")
    }
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
