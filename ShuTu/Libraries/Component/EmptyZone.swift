//
//  EmptyZone.swift
//  ShuTu
//
//  Created by yiqiang on 2017/12/19.
//  Copyright © 2017年 yiqiang. All rights reserved.
//

import Foundation
import UIKit

@objc protocol EmptyZoneDelegate {
    @objc optional func emptyZoneClicked()
    @objc optional func emptyZoneImage() -> String
}

public enum EmptyZoneType {
    case empty
    case loading
}

class EmptyZone {
    
    //声明区
    weak var delegate: EmptyZoneDelegate?
    fileprivate var EmptyView: UIView!
    fileprivate var target: UIView!
    fileprivate var frame: CGRect!
    fileprivate var imageView: UIImageView!
    
    init(target: UIView, frame: CGRect) {
        self.target = target
        self.frame = frame

        setupUI()
    }
    
    //显示 & 隐藏
    func show(type: EmptyZoneType) {
        setupEmptyViewContent(type: type)
        self.EmptyView.isHidden = false
    }
    func hide() {
        self.EmptyView.isHidden = true
    }
}

extension EmptyZone {
    //初始化
    fileprivate func setupUI() {
        //EmptyView
        self.EmptyView = UIView(frame: self.frame)
        target.addSubview(self.EmptyView)
        self.EmptyView.backgroundColor = UIColor.white
        self.EmptyView.isHidden = true
        //添加点击事件
        let tapGes = UITapGestureRecognizer(target: self, action: #selector(self.clicked))
        self.EmptyView.addGestureRecognizer(tapGes)
    }
    fileprivate func setupEmptyViewContent(type: EmptyZoneType) {
        //清空
        for view in self.EmptyView.subviews {
            view.removeFromSuperview()
        }
        
        switch type {
        case .empty:
            if let imageName = self.delegate?.emptyZoneImage?() {
                self.imageView = UIImageView(image: UIImage(named: imageName))
            } else {
                self.imageView = UIImageView(image: UIImage(named: "image_empty"))
            }
            self.EmptyView.addSubview(self.imageView)
            self.imageView.center = self.EmptyView.center
            break
        case .loading:
            break
        }
    }
    //点击事件
    @objc fileprivate func clicked() {
        self.delegate?.emptyZoneClicked?()
    }
}
