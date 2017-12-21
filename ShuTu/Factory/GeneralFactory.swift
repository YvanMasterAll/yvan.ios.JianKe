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
        layer.shadowRadius = 2
        let path = UIBezierPath(roundedRect: rect, cornerRadius: 0)
        layer.shadowPath = path.cgPath
    }
}
