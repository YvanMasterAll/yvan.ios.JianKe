//
//  BaseTableView.swift
//  ShuTu
//
//  Created by yiqiang on 2018/3/12.
//  Copyright © 2018年 yiqiang. All rights reserved.
//

import UIKit

class BaseTableView: UITableView {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.separatorStyle = .none //消除分割线
        self.showsVerticalScrollIndicator = false
        self.showsHorizontalScrollIndicator = false
        self.tableFooterView = UIView() //消除底部视图
        self.panGestureRecognizer.delegate = self
    }
    
}

extension BaseTableView: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool
    {
        return true
    }
}

