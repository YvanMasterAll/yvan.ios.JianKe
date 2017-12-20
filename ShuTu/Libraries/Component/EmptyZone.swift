//
//  EmptyZone.swift
//  ShuTu
//
//  Created by yiqiang on 2017/12/19.
//  Copyright © 2017年 yiqiang. All rights reserved.
//

import Foundation
import UIKit

typealias EmptyZoneClicked = () -> Void

class EmptyZone: UIView {
    
    //声明区
    var emptyZoneClicked: EmptyZoneClicked?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //显示 & 隐藏
    func show() {
        self.isHidden = false
    }
    func hide() {
        self.isHidden = true
    }
}

extension EmptyZone {
    //初始化
    fileprivate func setupUI() {
        self.backgroundColor = UIColor.purple
        self.isHidden = true
        //添加点击事件
        let tapGes = UITapGestureRecognizer(target: self, action: #selector(self.clicked))
        self.addGestureRecognizer(tapGes)
    }
    //点击事件
    @objc fileprivate func clicked() {
        self.emptyZoneClicked?()
    }
}
