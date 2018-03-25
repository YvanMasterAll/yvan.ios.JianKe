//
//  UIGradientExtension.swift
//  UIGradient
//
//  Created by Dinh Quang Hieu on 12/7/17.
//  Copyright © 2017 Dinh Quang Hieu. All rights reserved.
//

import UIKit

/// 生成渐变
/// 1.为视图生成渐变
/// 2.以渐变颜色生成图片

/**
 //视图渐变
 let gradient = STGradientLayer.init(direction: .leftToRight, colors: [STColor.grey300Color().withAlphaComponent(0.5), STColor.grey300Color().withAlphaComponent(0)], cornerRadius: 0)
 tabBarController.tabBar.addGradient(gradient, frame: CGRect.init(x: 0, y: -2, width: SW, height: 2))
 //渐变图片
 let image = UIImage.fromGradient(gradient, frame: CGRect.init(x: 0, y: 0, width: SW, height: 40))
 */

public extension UIView {
    
    /// 添加方向上的渐变
    public func addGradientWithDirection(_ direction: STGradientDirection, colors: [UIColor], cornerRadius: CGFloat = 0) {
        let gradientLayer = STGradientLayer(direction: direction, colors: colors, cornerRadius: cornerRadius)
        self.addGradient(gradientLayer)
    }
    
    /// 添加渐变
    public func addGradient(_ gradientLayer: STGradientLayer, cornerRadius: CGFloat = 0) {
        let cloneGradient = gradientLayer.clone()
        cloneGradient.frame = self.bounds
        cloneGradient.cornerRadius = cornerRadius
        self.layer.addSublayer(cloneGradient)
    }
    public func addGradient(_ gradientLayer: STGradientLayer, cornerRadius: CGFloat = 0, frame: CGRect) {
        let cloneGradient = gradientLayer.clone()
        cloneGradient.frame = frame
        cloneGradient.cornerRadius = cornerRadius
        self.layer.addSublayer(cloneGradient)
    }
}

public extension UIImage {
    
    public static func fromGradient(_ gradient: STGradientLayer, frame: CGRect, cornerRadius: CGFloat = 0) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(frame.size, false, UIScreen.main.scale)
        guard let ctx = UIGraphicsGetCurrentContext() else { return nil }
        let cloneGradient = gradient.clone()
        cloneGradient.frame = frame
        cloneGradient.cornerRadius = cornerRadius
        cloneGradient.render(in: ctx)
        guard let image = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
        UIGraphicsEndImageContext()
        return image
    }
    
    public static func fromGradientWithDirection(_ direction: STGradientDirection, frame: CGRect, colors: [UIColor], cornerRadius: CGFloat = 0) -> UIImage? {
        let gradient = STGradientLayer(direction: direction, colors: colors, cornerRadius: cornerRadius)
        return UIImage.fromGradient(gradient, frame: frame)
    }
}

public extension UIColor {
    
    public static func hex(_ hex: String, alpha: CGFloat = 1.0) -> UIColor {
        guard let hex = Int(hex, radix: 16) else { return UIColor.clear }
        return UIColor(red: ((CGFloat)((hex & 0xFF0000) >> 16)) / 255.0,
                       green: ((CGFloat)((hex & 0x00FF00) >> 8)) / 255.0,
                       blue: ((CGFloat)((hex & 0x0000FF) >> 0)) / 255.0,
                       alpha: alpha)
    }
    
    public static func fromGradient(_ gradient: STGradientLayer, frame: CGRect, cornerRadius: CGFloat = 0) -> UIColor? {
        guard let image = UIImage.fromGradient(gradient, frame: frame, cornerRadius: cornerRadius) else { return nil }
        return UIColor(patternImage: image)
    }
    
    public static func fromGradientWithDirection(_ direction: STGradientDirection, frame: CGRect, colors: [UIColor], cornerRadius: CGFloat = 0) -> UIColor? {
        let gradient = STGradientLayer(direction: direction, colors: colors, cornerRadius: cornerRadius)
        return UIColor.fromGradient(gradient, frame: frame)
    }
}

