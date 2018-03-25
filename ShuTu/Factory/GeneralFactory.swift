//
//  GeneralFactory.swift
//  ShuTu
//
//  Created by yiqiang on 2017/12/19.
//  Copyright © 2017年 yiqiang. All rights reserved.
//

import Foundation
import UIKit

/// 常用工厂

/**
 //添加阴影
 GeneralFactory.generateRectShadow(layer: self.actionView.layer, rect: CGRect.init(x: 0, y: -0.5, width: SW, height: 0.5), color: STColor.grey800Color().cgColor)
 */

class GeneralFactory {
    
    /// 创建相册选择器
    public static func generatePhotoPicker(_ selectedAssets: [TLPHAsset]) -> TLPhotosPickerViewController {
        let photoPicker = TLPhotosPickerViewController()
        //photoPicker.didExceedMaximumNumberOfSelection = { [weak self] (picker) in //图片数超过设定 }
        var configure = TLPhotosPickerConfigure()
        configure.maxSelectedAssets = 1
        configure.numberOfColumn = 3
        configure.allowedVideo = false
        photoPicker.configure = configure
        photoPicker.selectedAssets = selectedAssets
        
        return photoPicker
    }
    
    /// 添加阴影
    /// - parameter layer: 要添加阴影的图层
    /// - parameter rect: 阴影区域
    /// - parameter color: 阴影颜色
    public static func generateRectShadow(layer: CALayer, rect: CGRect, color: CGColor) {
        layer.shadowOffset = CGSize(width: 0, height: 0)
        layer.shadowColor = color
        layer.shadowOpacity = 0.5
        layer.shadowRadius = 1
        let path = UIBezierPath(roundedRect: rect, cornerRadius: 0)
        layer.shadowPath = path.cgPath
    }
    
    ///添加渐变阴影
    /// - parameter view: 要添加阴影的视图
    /// - parameter direction: 渐变方向
    /// - parameter rect: 阴影区域
    /// - parameter color: 阴影颜色
    public static func generateGradientShadow(view: UIView, direction: STGradientDirection, rect: CGRect, color: UIColor) {
        let gradient = STGradientLayer.init(direction: direction, colors: [color.withAlphaComponent(0.5), color.withAlphaComponent(0)], cornerRadius: 0)
        view.addGradient(gradient, frame: rect)
    }
    
    /// 通过颜色生成图片
    public static func createImageWithColor(_ color: UIColor) -> UIImage {
        let rect = CGRect.init(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(color.cgColor)
        context?.fill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image!
    }
    
    /// 获取面板视图控制器
    public static func getVCfromSb(_ sbName: String, _ vcIdentifier: String) -> UIViewController {
        let storyBoard = UIStoryboard.init(name: sbName, bundle: nil)
        return storyBoard.instantiateViewController(withIdentifier: vcIdentifier)
    }
    
}
