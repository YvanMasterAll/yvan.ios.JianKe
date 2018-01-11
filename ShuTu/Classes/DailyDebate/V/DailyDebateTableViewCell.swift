//
//  DailyDebateTableViewCell.swift
//  ShuTu
//
//  Created by yiqiang on 2018/1/6.
//  Copyright © 2018年 yiqiang. All rights reserved.
//

import UIKit

class DailyDebateTableViewCell: UITableViewCell {

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
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}

extension DailyDebateTableViewCell {
    
}
