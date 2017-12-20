//
//  SearchView.swift
//  ShuTu
//
//  Created by yiqiang on 2017/12/20.
//  Copyright © 2017年 yiqiang. All rights reserved.
//

import UIKit

class SearchView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.layer.cornerRadius = 8
        self.layer.masksToBounds = true
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
    
        //context
        let context = UIGraphicsGetCurrentContext()
        context?.setLineWidth(0.5)
        context?.setStrokeColor(UIColor(rgb: 0x757575).cgColor)
        //quiz image
        let quizImage = self.viewWithTag(10002) as! UIImageView
        //绘制垂直分割线
        let length: CGFloat = 18
        context?.move(to: CGPoint(x: quizImage.frame.minX - 8, y: (rect.size.height - length)/2))
        context?.addLine(to: CGPoint(x:  quizImage.frame.minX - 8, y: (rect.size.height + length)/2))
        context?.strokePath()
    }

}
