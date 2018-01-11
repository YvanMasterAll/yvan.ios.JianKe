//
//  GeneralFactory.swift
//  ShuTu
//
//  Created by yiqiang on 2017/12/19.
//  Copyright © 2017年 yiqiang. All rights reserved.
//

import Foundation
import UIKit

class GeneralFactory {
    
    //添加阴影
    public static func generateRectShadow(layer: CALayer, rect: CGRect, color: CGColor) {
        layer.shadowOffset = CGSize(width: 0, height: 0)
        layer.shadowColor = color
        layer.shadowOpacity = 0.5
        layer.shadowRadius = 1
        let path = UIBezierPath(roundedRect: rect, cornerRadius: 0)
        layer.shadowPath = path.cgPath
    }
    public static func generateGradientShadow(view: UIView, direction: GradientDirection, rect: CGRect, color: UIColor) {
        let gradient = GradientLayer.init(direction: direction, colors: [color.withAlphaComponent(0.5), color.withAlphaComponent(0)], cornerRadius: 0)
        view.addGradient(gradient, frame: rect)
    }
    
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
}
