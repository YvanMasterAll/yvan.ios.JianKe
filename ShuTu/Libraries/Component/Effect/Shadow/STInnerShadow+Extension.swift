//
//  STInnerShadow+Extension.swift
//  ShuTu
//
//  Created by yiqiang on 2018/3/23.
//  Copyright © 2018年 yiqiang. All rights reserved.
//

import Foundation
import UIKit

/// https://github.com/noblakit01/SwiftyShadow
/// 生成阴影
/// 1.内阴影
/// 2.外阴影
/// 3.底部阴影

/**
 //内阴影
 view.layer.shadowRadius = 8
 view.layer.shadowOpacity = 0.8
 view.layer.shadowColor = STColor.grey500Color().cgColor
 view.layer.shadowOffset = CGSize.zero
 view.generateInnerShadow()
 //外阴影
 imageView.layer.cornerRadius = 120
 imageView.layer.shadowRadius = 20
 imageView.layer.shadowOpacity = 0.8
 imageView.layer.shadowColor = UIColor.black.cgColor
 imageView.layer.shadowOffset = CGSize.zero
 imageView.generateOuterShadow()
 //底部阴影
 imageView.layer.shadowRadius = 20
 imageView.layer.shadowOpacity = 0.8
 imageView.layer.shadowColor = UIColor.black.cgColor
 imageView.layer.shadowOffset = CGSize.zero
 imageView.generateEllipticalShadow()
 */

extension UIView {
    
    /// 生成外阴影
    open func generateOuterShadow() {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = layer.cornerRadius
        view.layer.shadowRadius = layer.shadowRadius
        view.layer.shadowOpacity = layer.shadowOpacity
        view.layer.shadowColor = layer.shadowColor
        view.layer.shadowOffset = CGSize.zero
        view.clipsToBounds = false
        view.backgroundColor = .white
        
        superview?.insertSubview(view, belowSubview: self)
        
        let constraints = [
            NSLayoutConstraint(item: view, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: view, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: view, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: view, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: 0.0),
            ]
        superview?.addConstraints(constraints)
    }
    
    /// 生成内阴影
    open func generateInnerShadow() {
        let view = STInnerShadowView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.shadowLayer.cornerRadius = layer.cornerRadius
        view.shadowLayer.shadowRadius = layer.shadowRadius
        view.shadowLayer.shadowOpacity = layer.shadowOpacity
        view.shadowLayer.shadowColor = layer.shadowColor
        view.shadowLayer.shadowOffset = CGSize.zero
        view.clipsToBounds = false
        view.backgroundColor = .clear
        
        superview?.insertSubview(view, aboveSubview: self)
        view.isUserInteractionEnabled = false
        
        let constraints = [
            NSLayoutConstraint(item: view, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: view, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: view, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: view, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: 0.0),
            ]
        superview?.addConstraints(constraints)
    }
    
    /// 生成底部阴影
    open func generateEllipticalShadow() {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = layer.cornerRadius
        view.layer.shadowRadius = layer.shadowRadius
        view.layer.shadowOpacity = layer.shadowOpacity
        view.layer.shadowColor = layer.shadowColor
        view.layer.shadowOffset = CGSize.zero
        view.clipsToBounds = false
        view.backgroundColor = .white
        
        let ovalRect = CGRect(x: 0, y: frame.size.height + 10, width: frame.size.width, height: 15)
        let path = UIBezierPath(ovalIn: ovalRect)
        
        view.layer.shadowPath = path.cgPath
        
        superview?.insertSubview(view, belowSubview: self)
        
        let constraints = [
            NSLayoutConstraint(item: view, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: view, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: view, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: view, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: 0.0),
            ]
        superview?.addConstraints(constraints)
    }
}
