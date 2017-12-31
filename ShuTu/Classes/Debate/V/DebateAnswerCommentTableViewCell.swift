//
//  DebateAnswerCommentTableViewCell.swift
//  ShuTu
//
//  Created by yiqiang on 2017/12/31.
//  Copyright © 2017年 yiqiang. All rights reserved.
//

import UIKit

class DebateAnswerCommentTableViewCell: UITableViewCell {

    @IBOutlet weak var dialogButton: UILabel!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var zan: UILabel!
    @IBOutlet weak var zanIcon: UIImageView!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var comment: UILabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var thumbnail: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupUI()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func layoutSubviews() {
        //Thumbnail
        self.thumbnail.layer.cornerRadius = self.thumbnail.frame.width/2
        self.thumbnail.layer.masksToBounds = true
        //Zan
        self.zanIcon.setIcon(icon: .fontAwesome(.thumbsUp), textColor: GMColor.grey600Color(), backgroundColor: UIColor.clear, size: nil)
        //为 BottomView 添加下边框
        let x: CGFloat = 0, y: CGFloat = self.bottomView.frame.height - 0.5, width: CGFloat = self.bottomView.frame.width, height: CGFloat = 0.5
        let bottomLayer = CALayer()
        bottomLayer.frame = CGRect(x: x, y: y, width: width, height: height)
        bottomLayer.backgroundColor = GMColor.grey300Color().cgColor
        self.bottomView.layer.addSublayer(bottomLayer)
    }

}

extension DebateAnswerCommentTableViewCell {
    //初始化
    fileprivate func setupUI() {
        
    }
    //添加约束
    public func setupConstraint() {
        //评论区不设置 label 的高度限制
    }
}
