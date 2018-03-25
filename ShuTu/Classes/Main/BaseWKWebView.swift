//
//  BaseWKWebView.swift
//  ShuTu
//
//  Created by yiqiang on 2018/3/16.
//  Copyright © 2018年 yiqiang. All rights reserved.
//

import UIKit
import WebKit

class BaseWKWebView: WKWebView {

    //MARK: - 声明区域
    open var hasRequested: Bool = false //成功请求过数据
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.baseSetupUI()
    }
    
    //MARK: - 显示空页面
    func showBaseEmptyView() {
        let x = self.bounds.origin.x, y = self.bounds.origin.y, width = self.bounds.width
        let height: CGFloat = self.bounds.height > 180 ? 180:self.bounds.height
        let frame = CGRect.init(x: x, y: y, width: width, height: height)
        self.baseEmptyView.show(type: .loading(type: .indicator1), frame: frame)
    }
    func hideEmptyView() {
        self.baseEmptyView.hide()
    }
    
    //MARK: - 私有成员
    fileprivate var baseEmptyView: STEmptyView!

}

extension BaseWKWebView {
    
    //MARK: - 初始化
    fileprivate func baseSetupUI() {
        //EmptyView
        self.baseEmptyView = STEmptyView.init(target: self)
        self.baseEmptyView.delegate = self
    }
}

extension BaseWKWebView: STEmptyViewDelegate {
    
    //MARK: - EmptyViewDelegate
    func emptyViewClicked() {
        //self.baseEmptyView.hide()
    }
}
