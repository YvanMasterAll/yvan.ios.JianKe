//
//  DebateDetailAnswerTableViewCell.swift
//  ShuTu
//
//  Created by yiqiang on 2017/12/23.
//  Copyright © 2017年 yiqiang. All rights reserved.
//

import UIKit

class DebateDetailAnswerTableViewCell: UITableViewCell {
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var thumbnail: UIImageView!
    @IBOutlet weak var score: UILabel!
    @IBOutlet weak var answer: UILabel!
    @IBOutlet weak var answerHeightConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupUI()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

extension DebateDetailAnswerTableViewCell {
    //初始化
    fileprivate func setupUI() {
        //头像圆形
        self.thumbnail.layer.cornerRadius = self.thumbnail.frame.size.width / 2
        self.thumbnail.layer.masksToBounds = true
    }
    //添加约束
    public func setupConstraint() {
        let height = self.answer.height
        let heightMax = self.answer.heightOfLines(by: 3)
        if height > heightMax {
            self.answerHeightConstraint.constant = heightMax
        } else {
            self.answerHeightConstraint.constant = height
        }
        self.answer.setNeedsUpdateConstraints()
    }
}
