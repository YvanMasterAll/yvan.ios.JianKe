//
//  FindGayCollectionViewCell.swift
//  ShuTu
//
//  Created by yiqiang on 2018/1/8.
//  Copyright © 2018年 yiqiang. All rights reserved.
//

import UIKit
import PMSuperButton

class FindGayCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var thumbnail: UIImageView! {
        didSet {
            self.thumbnail.layer.cornerRadius = self.thumbnail.frame.height/2
            self.thumbnail.layer.masksToBounds = true
        }
    }
    
    @IBOutlet weak var followButton: PMSuperButton! {
        didSet {
            self.followButton.setImage(UIImage.init(named: "icon_button_plus_white")!.reSizeImage(CGSize.init(width: 14, height: 14)), for: .normal)
            self.followButton.contentEdgeInsets.left = 8
            self.followButton.contentEdgeInsets.right = 8
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

    }
    
}
