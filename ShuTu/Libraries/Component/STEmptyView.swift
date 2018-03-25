//
//  STEmptyView.swift
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

/// 为空控件

@objc protocol STEmptyViewDelegate {
    @objc optional func emptyViewClicked()
}

public enum STEmptyViewType {
    case none
    case empty(type: STEVEmptyType, options: STEVEmptyOptions?)
    case loading(type: STEVLoadingType)
}
public struct STEVEmptyOptions {
    var imageRate: CGFloat = 1 //图片大小
    var hasDescription: Bool = false //显示描述
    var description: String = "没有数据" //描述
}
public enum STEVEmptyType {
    case box
    case cry
    case vase
}
public enum STEVLoadingType {
    case rotate
    case indicator1
}

class STEmptyView {
    
    //MARK: - 声明区
    weak var delegate: STEmptyViewDelegate?
    fileprivate var view: UIView!
    fileprivate var target: UIView!
    fileprivate var imageView: UIImageView!
    fileprivate var descriptionLabel: UILabel!
    fileprivate var indicatorView: NVActivityIndicatorView!
    fileprivate var emptyOptions: STEVEmptyOptions!
    
    init(target: UIView) {
        self.target = target

        setupUI()
    }
    
}

extension STEmptyView {
    
    //MARK: - 初始化
    fileprivate func setupUI() {
        //EmptyView
        self.view = UIView(frame: CGRect.zero)
        target.addSubview(self.view)
        self.view.backgroundColor = UIColor.white
        self.view.isHidden = true
    }
    
    //MARK: - 显示 & 隐藏
    func show(type: STEmptyViewType, frame: CGRect) {
        setupEmptyView(type: type, frame: frame)
        self.view.isHidden = false
    }
    func hide() {
        self.view.isHidden = true
    }
    
    //MARK: - 加载成员
    fileprivate func setupEmptyView(type: STEmptyViewType, frame: CGRect) {
        //清空视图
        for view in self.view.subviews {
            view.removeFromSuperview()
        }
        //填充视图
        self.view.frame = frame
        switch type {
        case .empty(let type, let config):
            self.setupEmpty(type: type, config: config)
            break
        case .loading(let type):
            setupLoading(type: type)
            break
        default:
            break
        }
    }
    fileprivate func setupEmpty(type: STEVEmptyType, config: STEVEmptyOptions?) {
        if let c = config {
            self.emptyOptions = c
        } else {
            self.emptyOptions = STEVEmptyOptions()
        }
        switch type {
        case .box:
            loadEmpty("image_empty", CGSize.init(width: 120, height: 120))
            break
        case .vase:
            loadEmpty("image_empty_vase", CGSize.init(width: 90, height: 90))
            break
        case .cry:
            let w = self.view.width
            let h = self.view.height
            let animateView = LOTAnimationView.init(name: "crying_emoji")
            animateView.frame = CGRect.init(x: (w - 200)/2, y: (h - 150)/2, width: 200, height: 150)
            self.view.addSubview(animateView)
            animateView.play()
            break
        }
    }
    fileprivate func loadEmpty(_ imageName: String, _ imageSize: CGSize) {
        //添加图片
        var image = UIImage.init(named: imageName)
        image = image?.reSizeImage(CGSize.init(width: imageSize.width*emptyOptions.imageRate, height: imageSize.height*emptyOptions.imageRate))
        self.imageView = UIImageView.init(image: image)
        self.view.addSubview(self.imageView)
        self.imageView.snp.makeConstraints { make in
            make.center.equalTo(self.view)
        }
        //添加描述
        if emptyOptions.hasDescription {
            let label = UILabel.init()
            label.font = UIFont.systemFont(ofSize: 13)
            label.textColor = STColor.grey600Color()
            label.backgroundColor = UIColor.clear
            label.text = emptyOptions.description
            self.view.addSubview(label)
            label.snp.makeConstraints { make in
                make.centerX.equalTo(self.view)
                make.top.equalTo(self.imageView.snp.bottom).offset(10)
            }
        }
        //添加点击事件
        let tapGes = UITapGestureRecognizer(target: self, action: #selector(self.clicked))
        self.view.removeGestureRecognizer(tapGes)
        self.view.addGestureRecognizer(tapGes)
    }
    fileprivate func setupLoading(type: STEVLoadingType) {
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
            self.indicatorView = NVActivityIndicatorView.init(frame: CGRect.init(x: 0, y: 0, width: 30, height: 30), type: NVActivityIndicatorType.ballBeat, color: STColor.grey500Color(), padding: 0)
            self.view.addSubview(indicatorView)
            self.indicatorView.snp.makeConstraints{ make in
                make.center.equalTo(self.view)
            }
            self.indicatorView.startAnimating()
            break
        }
    }
}

extension STEmptyView {
    
    //MARK: - 动画
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
}

extension STEmptyView {
    
    //MARK: - 事件
    @objc fileprivate func clicked() {
        self.delegate?.emptyViewClicked?()
    }
}
