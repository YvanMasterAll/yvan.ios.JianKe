//
//  DebateAnswerTableViewCell.swift
//  ShuTu
//
//  Created by yiqiang on 2017/12/23.
//  Copyright © 2017年 yiqiang. All rights reserved.
//

import UIKit

class DebateAnswerTableViewCell: UITableViewCell {
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var thumbnail: UIImageView!
    @IBOutlet weak var score: UILabel!
    @IBOutlet weak var answer: UILabel!
    
    //MARK: - 私有成员
    fileprivate var isInit = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupUI()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

extension DebateAnswerTableViewCell {

    //MARK: - 初始化
    fileprivate func setupUI() {
        //头像圆形
        self.thumbnail.layer.cornerRadius = self.thumbnail.frame.size.width / 2
        self.thumbnail.layer.masksToBounds = true
    }
    public func setupConstraint() {
        guard !self.isInit else {
            return
        }
        self.isInit = true //防止重复添加约束
        
        let height = self.answer.heightOfLine
        let heightMax = self.answer.heightOfLines(by: 3)
        if height > heightMax {
            self.answer.snp.makeConstraints{ make in
                make.height.equalTo(heightMax)
            }
        } else {
            self.answer.snp.makeConstraints{ make in
                make.height.equalTo(height)
            }
        }
        self.answer.setNeedsUpdateConstraints()
    }
}
