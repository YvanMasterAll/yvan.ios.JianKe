//
//  DebateAnswerAddNewViewController.swift
//  ShuTu
//
//  Created by yiqiang on 2017/12/31.
//  Copyright © 2017年 yiqiang. All rights reserved.
//

import UIKit
import PMSuperButton

class DebateAnswerAddNewViewController: UIViewController {
    
    @IBOutlet weak var navigationBar: UIView!
    @IBOutlet weak var navigationBarLeftImage: UIImageView!
    @IBOutlet weak var stepButton: PMSuperButton!
    @IBOutlet weak var textView: RichTextView!
    @IBOutlet weak var actionView: UIView!
    @IBOutlet weak var actionAddImage: UIImageView!
    @IBOutlet weak var actionAddAt: UIImageView!
    @IBOutlet weak var actionSet: UIImageView!
    @IBOutlet weak var actionViewBottomConstraint: NSLayoutConstraint!
    
    //声明区
    open var section: Answer!

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        
        //键盘监听
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardWillShow(_:)), name:NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardWillHide(_:)), name:NSNotification.Name.UIKeyboardWillHide, object: nil)
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
    
    deinit {
        //移除通知
        NotificationCenter.default.removeObserver(self)
        print("deinit: \(type(of: self))")
    }
    
    //私有成员
    fileprivate var isKeyboardShow: Bool = false
    fileprivate var keyboardHeight: CGFloat = 0
    
}

extension DebateAnswerAddNewViewController {
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
}
