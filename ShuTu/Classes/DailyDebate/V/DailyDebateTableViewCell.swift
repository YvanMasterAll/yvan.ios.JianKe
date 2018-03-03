//
//  DailyDebateTableViewCell.swift
//  ShuTu
//
//  Created by yiqiang on 2018/1/6.
//  Copyright © 2018年 yiqiang. All rights reserved.
//

import UIKit

class DailyDebateTableViewCell: UITableViewCell {

    @IBOutlet weak var coverView: UIView! {
        didSet {
            self.coverView.backgroundColor = UIColor.init(white: 1.0, alpha: 0.3)
        }
    }
    @IBOutlet weak var coverImage: UIImageView!
    
    @IBOutlet weak var backView: UIView! {
        didSet {
            self.backView.layer.cornerRadius = 8
        }
    }
    @IBOutlet weak var view: UIView! {
        didSet {
            self.view.backgroundColor = UIColor.clear
            self.view.layer.shadowOffset = CGSize(width: 2, height: 2)
            self.view.layer.shadowColor = GMColor.grey800Color().cgColor
            self.view.layer.shadowOpacity = 0.5
            self.view.layer.shadowRadius = 1
        }
    }
    @IBOutlet weak var title: UILabel!
    
    //声明区域
    open var isImageSet: Bool = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    ///设置图片白底
    open func setImage() {
        guard !self.isImageSet else { return }
        self.isImageSet = true
        self.coverImage.changeImageColor(UIColor.init(white: 1, alpha: 0.3))
    }

}

extension DailyDebateTableViewCell {
    
}
