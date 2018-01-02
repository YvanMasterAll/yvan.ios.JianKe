//
//  DebateAddNewViewController.swift
//  ShuTu
//
//  Created by yiqiang on 2017/12/31.
//  Copyright © 2017年 yiqiang. All rights reserved.
//

import UIKit
import IQKeyboardManager

class DebateAddNewViewController: UIViewController {

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
        
//        //键盘监听
//        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardWillShow(_:)), name:NSNotification.Name.UIKeyboardWillShow, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardWillHide(_:)), name:NSNotification.Name.UIKeyboardWillHide, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        //隐藏导航栏
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        //添加 ActionView 的阴影
        GeneralFactory.generateRectShadow(layer: self.actionView.layer, rect: CGRect(x: 0, y: -1, width: SW, height: 1), color: GMColor.grey600Color().cgColor)
    }
    
//    override func viewDidAppear(_ animated: Bool) {
//        //禁用 IQKeyboardManager
//        IQKeyboardManager.shared().isEnabled = false
//    }
//
//    override func viewWillDisappear(_ animated: Bool) {
//        //启用 IQKeyboardManager
//        IQKeyboardManager.shared().isEnabled = true
//    }
    
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
}

extension DebateAddNewViewController {
    //初始化
    fileprivate func setupUI() {
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
//    @objc fileprivate func keyBoardWillShow(_ notification: Notification) {
//        //获取键盘高度
//        let kbInfo = notification.userInfo
//        let kbRect = (kbInfo?[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
//        let height = kbRect.height
//
//        UIView.animate(withDuration: 0.25, animations: { [weak self] () -> Void in
//            self?.actionViewBottomConstraint.constant = height
//            self?.view.layoutIfNeeded()
//        })
//    }
//    @objc fileprivate func keyBoardWillHide(_ notification: Notification) {
//        UIView.animate(withDuration: 0.25, animations: { [weak self] () -> Void in
//            self?.actionViewBottomConstraint.constant = 0
//            self?.view.layoutIfNeeded()
//        })
//    }
}

extension DebateAddNewViewController: TLPhotosPickerViewControllerDelegate {
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
}
