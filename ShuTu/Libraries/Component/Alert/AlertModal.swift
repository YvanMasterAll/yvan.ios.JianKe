//
//  AlertModal.swift
//  ShuTu
//
//  Created by yiqiang on 2018/1/25.
//  Copyright © 2018年 yiqiang. All rights reserved.
//

import Foundation
import UIKit
import Stellar

/// 模态框, 弥补 UIAlertController 宽度不能设置的缺陷

public enum AlertModalStyle {
    case none
    case fade
}

open class AlertModal {
    
    //私有成员
    fileprivate static let restorationIdentifier = "AlertModalContainer"
    fileprivate lazy var containerView: UIView = { //容器
        let view = UIView.init(frame: CGRect.init(x: 0, y: 0, width: SW, height: SH))
        view.backgroundColor = UIColor.clear
        
        return view
    }()
    fileprivate lazy var coverView: UIView = { //遮挡层
        let view = UIView.init(frame: CGRect.zero)
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        //关闭事件
        let tapGes = UITapGestureRecognizer.init(target: AlertModal.self, action: #selector(AlertModal.hide))
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(tapGes)
        
        return view
    }()
    fileprivate var alertBox: AlertBox! //模态框
    
    init(alertBox: AlertBox) {
        self.alertBox = alertBox
        
        self.setupUI()
    }
    
    //初始化
    fileprivate func setupUI() {
        if self.alertBox is TestAlertBox {
            self.containerView.addSubview(self.coverView)
            self.coverView.snp.makeConstraints { make in
                make.left.equalTo(self.containerView)
                make.right.equalTo(self.containerView)
                make.top.equalTo(self.containerView)
                make.bottom.equalTo(self.containerView)
            }
            alertBox.backgroundColor = UIColor.blue
            self.containerView.addSubview(alertBox)
            alertBox.center = containerView.center
            self.containerView.restorationIdentifier = AlertModal.restorationIdentifier
        }
    }
    
    //显示 & 隐藏
    public func show(_ style: AlertModalStyle) {
        //强引用
        let bself = self
        //隐藏
        containerView.layer.opacity = 0
        if let window = UIApplication.shared.keyWindow {
            window.addSubview(self.containerView)
        }
        switch style {
        case .none:
            DispatchQueue.main.async {
                bself.containerView.layer.opacity = 1
            }
            break
        case .fade:
            DispatchQueue.main.async {
                bself.containerView.layer.makeOpacity(1).duration(0.4).then().animate()
            }
            break
        }
    }
    @objc static fileprivate func hide() {
        if let window = UIApplication.shared.keyWindow {
            for view in window.subviews where view.restorationIdentifier == AlertModal.restorationIdentifier {
                view.removeFromSuperview()
            }
        }
    }
    
}
