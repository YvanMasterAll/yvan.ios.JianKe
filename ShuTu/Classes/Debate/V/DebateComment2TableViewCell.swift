//
//  DebateComment2TableViewCell.swift
//  ShuTu
//
//  Created by yiqiang on 2018/2/28.
//  Copyright © 2018年 yiqiang. All rights reserved.
//

import UIKit

class DebateComment2TableViewCell: UITableViewCell {

    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var comment: UILabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var thumbnail: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func layoutSubviews() {
        //Thumbnail
        self.thumbnail.layer.cornerRadius = self.thumbnail.frame.width/2
        self.thumbnail.layer.masksToBounds = true
        //为 BottomView 添加下边框
        let x: CGFloat = 0, y: CGFloat = self.bottomView.frame.height - 0.5, width: CGFloat = self.bottomView.frame.width, height: CGFloat = 0.5
        let bottomLayer = CALayer()
        bottomLayer.frame = CGRect(x: x, y: y, width: width, height: height)
        bottomLayer.backgroundColor = STColor.grey300Color().cgColor
        self.bottomView.layer.addSublayer(bottomLayer)
    }

}
