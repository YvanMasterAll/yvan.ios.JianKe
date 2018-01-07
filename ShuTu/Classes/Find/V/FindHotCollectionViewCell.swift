//
//  FindHotCollectionViewCell.swift
//  ShuTu
//
//  Created by yiqiang on 2018/1/7.
//  Copyright © 2018年 yiqiang. All rights reserved.
//

import UIKit

class FindHotCollectionViewCell: FSPagerViewCell {

    @IBOutlet weak var score: UILabel!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var view: UIView! {
        didSet {
            self.view.layer.cornerRadius = 8
            self.view.layer.masksToBounds = true
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        commonInit()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        //内阴影
//        view.layer.shadowRadius = 8
//        view.layer.shadowOpacity = 0.8
//        view.layer.shadowColor = UIColor.black.cgColor
//        view.layer.shadowOffset = CGSize.zero
//        view.generateInnerShadow()
    }

}

extension FindHotCollectionViewCell {
    //初始化
    fileprivate func commonInit() {
        self.backgroundColor = UIColor.white
    }
}
