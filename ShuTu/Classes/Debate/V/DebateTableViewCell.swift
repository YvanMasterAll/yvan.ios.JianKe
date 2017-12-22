//
//  DebateTableViewCell.swift
//  ShuTu
//
//  Created by yiqiang on 2017/12/21.
//  Copyright © 2017年 yiqiang. All rights reserved.
//

import UIKit

class DebateTableViewCell: UITableViewCell {

    @IBOutlet weak var divider: UIView!
    @IBOutlet weak var follow: UILabel!
    @IBOutlet weak var score: UILabel!
    @IBOutlet weak var thumbnail: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var desc: UILabel!
    @IBOutlet weak var category: UILabel!
    @IBOutlet weak var descHeightConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        //初始化
        setupUI()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}

extension DebateTableViewCell {
    //初始化
    fileprivate func setupUI() {
        //为分割线上边框
        let ilayer = CALayer()
        ilayer.frame = CGRect(x: 0, y: 0, width: SW, height: 1)
        ilayer.backgroundColor = GMColor.grey100Color().cgColor
        self.divider.layer.addSublayer(ilayer)
        //头像圆形
        self.thumbnail.layer.cornerRadius = self.thumbnail.frame.size.width / 2
        self.thumbnail.layer.masksToBounds = true
    }
    //添加约束
    public func setupConstraint() {
        let height = self.desc.height
        let heightMax = self.desc.heightOfLines(by: 3)
        if height > heightMax {
            self.descHeightConstraint.constant = heightMax
        } else {
            self.descHeightConstraint.constant = height
        }
        self.desc.setNeedsUpdateConstraints()
        
        self.score.frame.size.width = self.score.width
    }
}
