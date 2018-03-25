//
//  DebateAnswerAddNewViewController.swift
//  ShuTu
//
//  Created by yiqiang on 2017/12/31.
//  Copyright © 2017年 yiqiang. All rights reserved.
//

import UIKit
import Photos
import RichEditorView
import RxCocoa
import RxSwift

class DebateAnswerAddNewViewController: BaseViewController {
    
    @IBOutlet weak var anonyCheckBox: STCheckBoxView!
    @IBOutlet weak var stSide: STButton! {
        didSet {
            let imageView = UIImageView.init(image: UIImage.init(icon: .fontAwesome(.check), size: CGSize.init(width: 14, height: 14), textColor: UIColor.white, backgroundColor: UIColor.clear))
            imageView.frame.origin = CGPoint.init(x: self.stSide.width - 14, y: 0)
            imageView.tag = 10001
            imageView.isHidden = true
            self.stSide.addSubview(imageView)
            self.stSide.addTarget(self, action: #selector(self.stSideClicked), for: .touchUpInside)
        }
    }
    @IBOutlet weak var sySide: STButton! {
        didSet {
            let imageView = UIImageView.init(image: UIImage.init(icon: .fontAwesome(.check), size: CGSize.init(width: 14, height: 14), textColor: UIColor.white, backgroundColor: UIColor.clear))
            imageView.frame.origin = CGPoint.init(x: self.sySide.width - 14, y: 0)
            imageView.tag = 10001
            imageView.isHidden = true
            self.sySide.addSubview(imageView)
            self.sySide.addTarget(self, action: #selector(self.sySideClicked), for: .touchUpInside)
        }
    }
    @IBOutlet weak var richEditorView: RichEditorView! {
        didSet {
            self.richEditorView.delegate = self
        }
    }
    @IBOutlet weak var navigationBar: UIView!
    @IBOutlet weak var navigationBarLeftImage: UIImageView!
    @IBOutlet weak var stepButton: STButton! {
        didSet {
            self.enableButton(false)
            self.stepButton.addTarget(self, action: #selector(self.send), for: .touchUpInside)
        }
    }
    @IBOutlet weak var actionView: UIView!
    @IBOutlet weak var actionAddImage: UIImageView!
    @IBOutlet weak var actionAddAt: UIImageView!
    @IBOutlet weak var actionViewBottomConstraint: NSLayoutConstraint!
    
    //MARK: - 声明区域
    open var section: Debate!

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
    
    deinit {
        //移除通知
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK: - 私有成员
    fileprivate var disposeBag = DisposeBag()
    fileprivate var viewModel: DebateAnswerAddNewViewModel!
    fileprivate var isKeyboardShow: Bool = false
    fileprivate var keyboardHeight: CGFloat = 0
    fileprivate lazy var photoPicker: TLPhotosPickerViewController! = {
        //相册控制器
        let photoPicker = GeneralFactory.generatePhotoPicker(self.selectedAssets)
        photoPicker.delegate = self
        
        return photoPicker
    }()
    fileprivate var selectedAssets = [TLPHAsset]()
    fileprivate var sy: Bool = true //立场
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
    
}

extension DebateAnswerAddNewViewController {

    //MARK: - 初始化
    fileprivate func setupUI() {
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
        //初始立场
        self.setSide(true)
        //阴影
        GeneralFactory.generateRectShadow(layer: self.actionView.layer, rect: CGRect(x: 0, y: -1, width: SW, height: 1), color: STColor.grey800Color().cgColor)
    }
    fileprivate func bindRx() {
        //View Model
        viewModel = DebateAnswerAddNewViewModel.init(disposeBag: self.disposeBag)
        //Rx
        viewModel.outputs.sendResult
            .asObservable()
            .subscribe(onNext: { result in
                switch result {
                case .ok:
                    HUD.flash(.label("成功添加观点"))
                    break
                case .failed:
                    HUD.flash(.label("添加观点失败"))
                    break
                default:
                    HUD.hide()
                    break
                }
            })
            .disposed(by: self.disposeBag)
    }
    
    //MARK: - 按钮事件
    @objc fileprivate func sySideClicked() {
        self.setSide(true)
    }
    @objc fileprivate func stSideClicked() {
        self.setSide(false)
    }
    @objc fileprivate func goBack() {
        if (navigationController != nil) {
            navigationController?.popViewController(animated: true)
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
    @objc fileprivate func showEmoji() {
        //取消焦点
        self.richEditorView.blur()
        self.emojiView.isHidden = false
        
        UIView.animate(withDuration: 0.25, animations: { [weak self] () -> Void in
            self?.actionViewBottomConstraint.constant = 200
            self?.view.layoutIfNeeded()
        })
    }
    fileprivate func setSide(_ sy: Bool) {
        self.sy = sy
        if sy {
            (sySide.viewWithTag(10001) as! UIImageView).isHidden = false
            (stSide.viewWithTag(10001) as! UIImageView).isHidden = true
        } else {
            (sySide.viewWithTag(10001) as! UIImageView).isHidden = true
            (stSide.viewWithTag(10001) as! UIImageView).isHidden = false
        }
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
    
    //MARK: - 按钮状态变更
    fileprivate func enableButton(_ enable: Bool) {
        self.stepButton.isEnabled = enable
        if enable {
            self.stepButton.setTitleColor(ColorPrimary, for: .normal)
        } else {
            self.stepButton.setTitleColor(ColorPrimary.lighter(by: 0.2), for: .normal)
        }
    }
    @objc fileprivate func send() {
        let side = self.sy ? AnswerSide.SY:AnswerSide.ST
        HUD.show(.progress)
        self.viewModel.inputs.sendTap.onNext((self.section.id!, self.richEditorView.contentHTML, side, self.anonyCheckBox.check))
    }
}

extension DebateAnswerAddNewViewController: TLPhotosPickerViewControllerDelegate, RichEditorDelegate, STEmojiViewDelegate {
    
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
        self.richEditorView.placeholder = "请输入观点详情"
        self.richEditorView.setFontSize(13)
        self.richEditorView.lineHeight = 15
    }
    func richEditor(_ editor: RichEditorView, contentDidChange content: String) {
        self.enableButton(content.count>10 ? true:false)
    }
    
}
