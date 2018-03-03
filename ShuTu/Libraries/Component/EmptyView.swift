//
//  EmptyView.swift
//  ShuTu
//
//  Created by yiqiang on 2017/12/19.
//  Copyright © 2017年 yiqiang. All rights reserved.
//

import Foundation
import UIKit
import SnapKit
import NVActivityIndicatorView
import Lottie

///为空控件
///加载时, 空数据, 请求错误

@objc protocol EmptyViewDelegate {
    @objc optional func emptyViewClicked()
}

public enum EmptyViewType {
    case none
    case empty(size: CGFloat?)
    case empty2
    case loading(type: EmptyViewLoadingType)
}

public enum EmptyViewLoadingType {
    case rotate
    case indicator1
}

class EmptyView {
    
    //声明区
    weak var delegate: EmptyViewDelegate?
    fileprivate var view: UIView!
    fileprivate var target: UIView!
    fileprivate var imageView: UIImageView!
    fileprivate var indicatorView: NVActivityIndicatorView!
    
    init(target: UIView) {
        self.target = target

        setupUI()
    }
    
}

extension EmptyView {
    ///显示
    /// - parameter type: 显示类型
    /// - parameter frame: 显示区域
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
    }
    //显示
    fileprivate func setupEmptyViewContent(type: EmptyViewType, frame: CGRect) {
        //清空视图
        for view in self.view.subviews {
            view.removeFromSuperview()
        }
        //填充视图
        self.view.frame = frame
        switch type {
        case .empty(let size):
            let imageSize = CGSize.init(width: 120, height: 120)
            self.imageView = UIImageView.init(frame: CGRect.zero)
            var image = UIImage.init(named: "image_empty")
            if size != nil {
                image = image?.reSizeImage(CGSize.init(width: imageSize.width * size!, height: imageSize.height * size!))
            } else {
                image = image?.reSizeImage(imageSize)
            }
            self.imageView.image = image
            self.view.addSubview(self.imageView)
            self.imageView.snp.makeConstraints { make in
                make.center.equalTo(self.view)
            }
            //添加点击事件
            let tapGes = UITapGestureRecognizer(target: self, action: #selector(self.clicked))
            self.view.removeGestureRecognizer(tapGes)
            self.view.addGestureRecognizer(tapGes)
            
            break
        case .empty2:
            let w = self.view.width
            let h = self.view.height
            let animateView = LOTAnimationView.init(name: "crying_emoji")
            animateView.frame = CGRect.init(x: (w - 200)/2, y: (h - 150)/2, width: 200, height: 150)
            self.view.addSubview(animateView)
            animateView.play()
        case .loading(let type):
            setupLoading(type: type)
            break
        default:
            break
        }
    }
    fileprivate func setupLoading(type: EmptyViewLoadingType) {
        switch type {
        case .rotate:
            self.imageView = UIImageView(image: UIImage(named: "loading"))
            self.view.addSubview(self.imageView)
            self.imageView.snp.makeConstraints { make in
                make.center.equalTo(self.view)
            }
            
            let animation = rotateAnimation()
            self.imageView.layer.add(animation, forKey: nil)
            
            break
        case .indicator1:
            self.indicatorView = NVActivityIndicatorView.init(frame: CGRect.init(x: 0, y: 0, width: 30, height: 30), type: NVActivityIndicatorType.ballBeat, color: GMColor.grey500Color(), padding: 0)
            self.view.addSubview(indicatorView)
            self.indicatorView.snp.makeConstraints{ make in
                make.center.equalTo(self.view)
            }
            self.indicatorView.startAnimating()
            
            break
        }
    }
    //动画
    fileprivate func rotateAnimation() -> CABasicAnimation {
        let animation = CABasicAnimation()
        animation.keyPath = "transform.rotation.z"
        animation.duration = 2
        animation.isCumulative = true
        animation.toValue = CGFloat.pi * 2
        animation.repeatCount = MAXFLOAT
        animation.isRemovedOnCompletion = false
        return animation
    }
    //点击事件
    @objc fileprivate func clicked() {
        self.delegate?.emptyViewClicked?()
    }
}
