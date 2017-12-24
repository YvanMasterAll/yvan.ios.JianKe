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
    case none
    case empty
    case loading
}

class EmptyView {
    
    //声明区
    weak var delegate: EmptyViewDelegate?
    fileprivate var view: UIView!
    fileprivate var target: UIView!
    fileprivate var imageView: UIImageView!
    
    init(target: UIView) {
        self.target = target

        setupUI()
    }
    
}

extension EmptyView {
    //显示 & 隐藏
    func show(type: EmptyViewType, frame: CGRect) {
        setupEmptyViewContent(type: type, frame: frame)
        self.view.isHidden = false
    }
    func hide() {
        self.view.isHidden = true
    }
    //初始化
    fileprivate func setupUI() {
        //EmptyView
        self.view = UIView(frame: CGRect.zero)
        target.addSubview(self.view)
        self.view.backgroundColor = UIColor.white
        self.view.isHidden = true
        //添加点击事件
        let tapGes = UITapGestureRecognizer(target: self, action: #selector(self.clicked))
        self.view.addGestureRecognizer(tapGes)
    }
    fileprivate func setupEmptyViewContent(type: EmptyViewType, frame: CGRect) {
        //清空
        for view in self.view.subviews {
            view.removeFromSuperview()
        }
        //填充 View
        self.view.frame = frame
        
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
        default:
            break
        }
    }
    //点击事件
    @objc fileprivate func clicked() {
        self.delegate?.emptyViewClicked?()
    }
}
