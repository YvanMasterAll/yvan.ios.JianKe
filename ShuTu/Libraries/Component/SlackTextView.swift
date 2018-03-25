//
//  SlackTextView.swift
//  ShuTu
//
//  Created by yiqiang on 2017/12/29.
//  Copyright © 2017年 yiqiang. All rights reserved.
//

import UIKit
import SnapKit

@IBDesignable
class SlackTextView: UIView {
    
    //MARK: - 声明区域
    @IBInspectable
    open var placeHolder: String?
    
    //MARK: - 私有成员
    fileprivate var textView: STGrowingTextView!
    fileprivate var sendButton: UIButton!
    fileprivate var MR: CGFloat = 8
    fileprivate var BT_W: CGFloat = 50 //按钮宽度
    fileprivate var TV_H: CGFloat = 40 //textView 高度
    fileprivate var V_H: CGFloat { //view 高度
        get {
            return TV_H + MR
        }
    }
    fileprivate var textViewHeightC: NSLayoutConstraint!
    fileprivate var viewHeightC: NSLayoutConstraint!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.commonInit()
    }
    
    fileprivate func commonInit() {
        self.associateConstraints()
        
        self.backgroundColor = UIColor.red
    }
    
    private func associateConstraints() {
        //获取高度约束
        for constraint in constraints {
            if (constraint.firstAttribute == .height) {
                if (constraint.relation == .equal) {
                    viewHeightC = constraint
                    viewHeightC.constant = V_H
                }
            }
        }
        if (viewHeightC == nil) {
            viewHeightC = NSLayoutConstraint(item: self, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: V_H)
            addConstraint(viewHeightC!)
        }
    }
    
    override func layoutSubviews() {
        
        self.sendButton = UIButton()
        self.addSubview(sendButton)
        sendButton.backgroundColor = UIColor.blue
        self.sendButton.snp.makeConstraints{ make in
            make.width.equalTo(BT_W)
            make.height.equalTo(TV_H)
            make.bottom.equalTo(-MR/2)
            make.right.equalTo(-MR)
        }
        self.textView = STGrowingTextView()
        textView.delegate = self
        textView.backgroundColor = UIColor.red
        textView.maxLength = 140
        textView.trimWhiteSpaceWhenEndEditing = false
        textView.placeHolderColor = UIColor(white: 0.8, alpha: 1.0)
        textView.minHeight = 25.0
        textView.maxHeight = 170.0
        textView.backgroundColor = UIColor.white
        textView.layer.cornerRadius = 4.0
        //        textView.placeHolder = self.placeHolder
        textView.placeHolder = "say something..."
        self.addSubview(textView)
        //添加高度约束
//        textViewHeightC = NSLayoutConstraint(item: self.textView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: TV_H)
//        textView.addConstraint(textViewHeightC!)
        textView.snp.makeConstraints{ make in
            make.top.equalTo(MR/2)
            make.left.equalTo(MR/2)
            make.right.equalTo(sendButton.snp.left).offset(-MR/2)
        }
        
    }
}

extension SlackTextView: STGrowingTextViewDelegate {
    //STGrowingTextViewDelegate
    func textViewDidChangeHeight(_ textView: STGrowingTextView, height: CGFloat) {
        UIView.animate(withDuration: 0.3, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.7, options: [.curveLinear], animations: { () -> Void in
            self.viewHeightC.constant = height + self.MR
        }, completion: nil)
    }
}

