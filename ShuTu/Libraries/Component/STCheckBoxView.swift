//
//  STCheckBoxView.swift
//  ShuTu
//
//  Created by yiqiang on 2018/3/21.
//  Copyright © 2018年 yiqiang. All rights reserved.
//

import UIKit

/// 可选框

public struct STCheckBoxViewOptions {
    public var boxPadding: CGFloat = 4.0
}

@IBDesignable
open class STCheckBoxView: UIView {
    
    //MARK: - 常规属性
    @IBInspectable dynamic open var text: String = "可选框" {
        didSet {
            self.boxLabel.text = text
        }
    }
    @IBInspectable dynamic open var font: UIFont = UIFont.systemFont(ofSize: 11) {
        didSet {
            self.boxLabel.font = font
        }
    }
    @IBInspectable dynamic open var fontColor: UIColor = STColor.grey600Color() {
        didSet {
            self.boxLabel.textColor = fontColor
        }
    }
    @IBInspectable dynamic open var check: Bool = false {
        didSet {
            self.applyCheck()
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setupUI()
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    //MARK: - 私有成员
    fileprivate var options = STCheckBoxViewOptions()
    fileprivate lazy var boxButton: UIButton = {
        let x = options.boxPadding, y = x,
            w = bounds.height - options.boxPadding*2, h = w
        let button = UIButton.init(frame: CGRect.init(x: x, y: y, width: w, height: h))
        return button
    }()
    fileprivate lazy var boxLabel: UILabel = {
        let label = UILabel()
        label.text = self.text
        label.font = self.font
        label.textColor = fontColor
        return label
    }()

}

extension STCheckBoxView {

    //MARK: - 初始化
    fileprivate func setupUI() {
        //加载成员
        self.addSubview(boxButton)
        self.addSubview(boxLabel)
        boxLabel.snp.makeConstraints { make in
            make.centerY.equalTo(self)
            make.left.equalTo(self.boxButton.snp.right).offset(options.boxPadding)
        }
        self.applyCheck()
        //选中事件
        self.isUserInteractionEnabled = true
        self.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(self.handleCheck)))
        self.boxButton.addTarget(self, action: #selector(self.handleCheck), for: .touchUpInside)
    }
    //MARK: - 应用选中
    fileprivate func applyCheck() {
        if self.check {
            self.boxButton.setImage(UIImage.init(icon: .fontAwesome(.checkSquareO), size: boxButton.frame.size, textColor: ColorPrimary, backgroundColor: UIColor.clear), for: .normal)
        } else {
            self.boxButton.setImage(UIImage.init(icon: .fontAwesome(.squareO), size: boxButton.frame.size, textColor: STColor.grey600Color(), backgroundColor: UIColor.clear), for: .normal)
        }
    }
    @objc fileprivate func handleCheck() {
        self.check = !self.check
        self.applyCheck()
    }
}
