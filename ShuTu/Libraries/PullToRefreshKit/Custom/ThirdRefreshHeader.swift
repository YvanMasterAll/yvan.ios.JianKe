//
//  ThirdRefreshHeader.swift
//  ShuTu
//
//  Created by yiqiang on 2018/1/27.
//  Copyright © 2018年 yiqiang. All rights reserved.
//

import Foundation
import UIKit
import Lottie

class ThirdRefreshHeader: UIView, RefreshableHeader{
    
    fileprivate let animateView = LOTAnimationView.init(name: "simple_loader")
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        //Test
        setupUI()
        
    }
    
    //MARK: - 初始化
    fileprivate func setupUI() {
    
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        //AnimateView
        animateView.frame = CGRect.init(x: self.bounds.width/2 - 50, y: self.bounds.height/2 - 50, width: 100, height: 100)
        animateView.loopAnimation = true
        // animateView.logHierarchyKeypaths() //记录所有的 KeyPath
        animateView.setValue(STColor.grey500Color(), forKeypath: "Shape Layer 1.Ellipse 1.Fill 1.Color", atFrame: 0)
        animateView.setValue(STColor.grey500Color(), forKeypath: "Shape Layer 2.Ellipse 1.Fill 1.Color", atFrame: 0)
        animateView.setValue(STColor.grey500Color(), forKeypath: "Shape Layer 3.Ellipse 1.Fill 1.Color", atFrame: 0)
        self.addSubview(animateView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - RefreshableHeader -
    func heightForHeader() -> CGFloat {
        return 50
    }
    
    func heightForFireRefreshing() -> CGFloat {
        return 50.0
    }
    
    func heightForRefreshingState() -> CGFloat {
        return 50.0
    }
    
    func percentUpdateDuringScrolling(_ percent:CGFloat){
        //设置动画当前所在帧数
        let adjustPercent = max(min(1.0, percent),0.0)
        self.animateView.animationProgress = 1 - adjustPercent
    }
    
    func didBeginRefreshingState(){
        self.animateView.play()
    }
    
    func didBeginHideAnimation(_ result:RefreshResult){
        self.animateView.stop()
    }
    
    func didCompleteHideAnimation(_ result:RefreshResult){
        
    }
    
    func transitionWithOutAnimation(_ clousre:()->()){
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        clousre()
        CATransaction.commit()
    }
}

