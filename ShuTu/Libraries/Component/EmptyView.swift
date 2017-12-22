//
//  EmptyView.swift
//  ShuTu
//
//  Created by yiqiang on 2017/12/19.
//  Copyright © 2017年 yiqiang. All rights reserved.
//

import Foundation
import UIKit

@objc protocol EmptyViewDelegate {
    @objc optional func emptyViewClicked()
    @objc optional func emptyViewImage() -> String
}

public enum EmptyViewType {
    case empty
    case loading
}

class EmptyView {
    
    //声明区
    weak var delegate: EmptyViewDelegate?
    fileprivate var view: UIView!
    fileprivate var target: UIView!
    fileprivate var frame: CGRect!
    fileprivate var imageView: UIImageView!
    
    init(target: UIView, frame: CGRect) {
        self.target = target
        self.frame = frame

        setupUI()
    }
    
}

extension EmptyView {
    //显示 & 隐藏
    func show(type: EmptyViewType) {
        setupEmptyViewContent(type: type)
        self.view.isHidden = false
    }
    func hide() {
        self.view.isHidden = true
    }
    //初始化
    fileprivate func setupUI() {
        //EmptyView
        self.view = UIView(frame: self.frame)
        target.addSubview(self.view)
        self.view.backgroundColor = UIColor.white
        self.view.isHidden = true
        //添加点击事件
        let tapGes = UITapGestureRecognizer(target: self, action: #selector(self.clicked))
        self.view.addGestureRecognizer(tapGes)
    }
    fileprivate func setupEmptyViewContent(type: EmptyViewType) {
        //清空
        for view in self.view.subviews {
            view.removeFromSuperview()
        }
        
        switch type {
        case .empty:
            if let imageName = self.delegate?.emptyViewImage?() {
                self.imageView = UIImageView(image: UIImage(named: imageName))
            } else {
                self.imageView = UIImageView(image: UIImage(named: "image_empty"))
            }
            self.view.addSubview(self.imageView)
            self.imageView.center = self.view.center
            break
        case .loading:
            break
        }
    }
    //点击事件
    @objc fileprivate func clicked() {
        self.delegate?.emptyViewClicked?()
    }
}
