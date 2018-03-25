//
//  STInnerShadowView.swift
//  ShuTu
//
//  Created by luan on 7/11/17.
//  Copyright © 2017 luantran. All rights reserved.
//

import UIKit

open class STInnerShadowView: UIView {

    open var shadowLayer = STInnerShadowLayer()

    override open var bounds: CGRect {
        didSet {
            shadowLayer.frame = bounds
        }
    }
    
    override open var frame: CGRect {
        didSet {
            shadowLayer.frame = bounds
        }
    }
    
    public override var cornerRadius: CGFloat {
        didSet {
            layer.cornerRadius = cornerRadius
            shadowLayer.cornerRadius = cornerRadius
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initShadowLayer()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initShadowLayer()
    }
    
    fileprivate func initShadowLayer() {
        layer.addSublayer(shadowLayer)
    }
    
}
