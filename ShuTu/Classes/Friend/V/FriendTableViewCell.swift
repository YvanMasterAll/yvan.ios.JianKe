//
//  FriendTableViewCell.swift
//  ShuTu
//
//  Created by yiqiang on 2018/1/4.
//  Copyright © 2018年 yiqiang. All rights reserved.
//

import UIKit

class FriendTableViewCell: UITableViewCell {

    @IBOutlet weak var sign: UILabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var thumbnail: UIImageView! {
        didSet {
            //圆形头像
            self.thumbnail.layer.cornerRadius = self.thumbnail.frame.height/2
            self.thumbnail.layer.masksToBounds = true
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
