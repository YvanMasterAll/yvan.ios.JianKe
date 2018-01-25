//
//  TestAlertBox.swift
//  ShuTu
//
//  Created by yiqiang on 2018/1/25.
//  Copyright © 2018年 yiqiang. All rights reserved.
//

import UIKit

class TestAlertBox: AlertBox {
    
    //私有成员
    fileprivate lazy var label: UILabel = {
        let label = UILabel.init(frame: CGRect.init(x: 0, y: 0, width: 100, height: 100))
        label.text = "Hi"
        label.font = UIFont.systemFont(ofSize: 28)
        label.textColor = UIColor.red
        
        return label
    }()
    fileprivate var contentView: UIView!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        //测试文本
        self.addSubview(label)
    }
    
    init(_ frame: CGRect = CGRect.init(x: 0, y: 0, width: SW - 20, height: 200)) {
        super.init(frame: frame)
        
        //绑定 XIB
        contentView = loadViewFromNib()
        addSubview(contentView)
        addConstraints()
        //初始化
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    //初始化
    fileprivate func setupUI() {
        
    }
    
    //设置 XIB 约束
    fileprivate func addConstraints() {
        contentView.translatesAutoresizingMaskIntoConstraints = false
        var constraint = NSLayoutConstraint(item: contentView, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 0)
        addConstraint(constraint)
        constraint = NSLayoutConstraint(item: contentView, attribute: .trailing,relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: 0)
        addConstraint(constraint)
        constraint = NSLayoutConstraint(item: contentView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0)
        addConstraint(constraint)
        constraint = NSLayoutConstraint(item: contentView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0)
        addConstraint(constraint)
    }
    
}
