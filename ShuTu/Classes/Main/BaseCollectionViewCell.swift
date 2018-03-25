//
//  BaseCollectionViewCell.swift
//  ShuTu
//
//  Created by yiqiang on 2018/3/16.
//  Copyright © 2018年 yiqiang. All rights reserved.
//

import UIKit

open class BaseCollectionViewCell: UICollectionViewCell {
    
    //MARK: - 声明区域
    open var hasRequested: Bool = false //成功请求过数据
    
    override open func awakeFromNib() {
        super.awakeFromNib()
        
        self.baseSetupUI()
    }
    
    //MARK: - 显示空页面
    func showBaseEmptyView() {
        self.isReload = true
        self.baseEmptyView.show(type: .empty(type: .box, options: nil), frame: self.bounds)
    }
    func showBaseEmptyView(_ description: String?, _ type: STEVEmptyType = .vase) {
        self.isReload = false
        var options = STEVEmptyOptions()
        options.hasDescription = true
        if let d = description {
            options.description = d
        }
        self.baseEmptyView.show(type: .empty(type: type, options: options), frame: self.bounds)
    }
    
    /// 重新加载
    func reload() { }
    
    //MARK: - 私有成员
    fileprivate var baseEmptyView: STEmptyView!
    fileprivate var isReload: Bool = true
}

extension BaseCollectionViewCell {
    
    //MARK: - 初始化
    fileprivate func baseSetupUI() {
        //EmptyView
        self.baseEmptyView = STEmptyView.init(target: self)
        self.baseEmptyView.delegate = self
    }
}

extension BaseCollectionViewCell: STEmptyViewDelegate {
    
    //MARK: - EmptyViewDelegate
    func emptyViewClicked() {
        if self.isReload {
            self.baseEmptyView.hide()
            self.reload()
        }
    }
}
