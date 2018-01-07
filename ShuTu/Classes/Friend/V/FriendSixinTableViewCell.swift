//
//  FriendSixinTableViewCell.swift
//  ShuTu
//
//  Created by yiqiang on 2018/1/7.
//  Copyright © 2018年 yiqiang. All rights reserved.
//

import UIKit

class FriendSixinTableViewCell: UITableViewCell {
    
    @IBOutlet weak var thumbnail: UIImageView! {
        didSet {
            self.thumbnail.layer.cornerRadius = self.thumbnail.frame.height/2
            self.thumbnail.layer.masksToBounds = true
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
