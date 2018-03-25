//
//  STTestAlertBox.swift
//  ShuTu
//
//  Created by yiqiang on 2018/1/25.
//  Copyright © 2018年 yiqiang. All rights reserved.
//

import UIKit

/**
 //AlertBox 测试
 let alertBox = STTestAlertBox.init()
 let alertModal = STAlertModal.init(alertBox: alertBox)
 alertModal.show(.fade)
 */

class STTestAlertBox: STAlertBox {
    
    //MARK: - 私有成员
    fileprivate lazy var label: UILabel = {
        let label = UILabel.init(frame: CGRect.init(x: 0, y: 0, width: 100, height: 100))
        label.text = "Hi"
        label.font = UIFont.systemFont(ofSize: 28)
        label.textColor = UIColor.red
        
        return label
    }()
    fileprivate var contentView: UIView!
    
    init(_ frame: CGRect = CGRect.init(x: 0, y: 0, width: SW - 20, height: 200)) {
        super.init(frame: frame)
        
        //Xib
        contentView = loadViewFromNib()
        addSubview(contentView)
        setupContentView()
        
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        //测试文本
        self.addSubview(label)
    }
    
    //MARK: - 初始化
    fileprivate func setupUI() {
        
    }
    fileprivate func setupContentView() {
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
