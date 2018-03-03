//
//  EmojiCollectionViewCell.swift
//  ShuTu
//
//  Created by yiqiang on 2018/2/10.
//  Copyright © 2018年 yiqiang. All rights reserved.
//

import UIKit
import Stellar

typealias EmojiCollectionViewCellBlock = (_ imageUrl: String) -> ()

class EmojiCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var emoji: UIImageView!
    
    //声明区域
    open var imageUrl: String!
    open var block: EmojiCollectionViewCellBlock?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.clipsToBounds = false
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        //放大镜
        self.addSubview(self.emojiPopView)
        self.emojiPopView.snp.makeConstraints{ make in
            make.centerX.equalTo(self)
            make.bottom.equalTo(self).offset(-20)
        }
    }
    
    //私有成员
    fileprivate lazy var emojiPopView: UIImageView = {
        let imageView = UIImageView.init(image: UIImage.init(named: "image_emojipop")?.reSizeImage(CGSize.init(width: 64, height: 91)))
        imageView.isHidden = true
        return imageView
    }()
    fileprivate var issetup: Bool = false

}

extension EmojiCollectionViewCell {
    ///初始化放大镜
    open func setupPopView(_ image: UIImage) {
        guard !self.issetup else { return }
        self.issetup = true
        
        self.emoji.image = image
        let imageView = UIImageView.init(image: image.reSizeImage(CGSize.init(width: 30, height: 30)))
        imageView.tag = 10001
        self.emojiPopView.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.centerX.equalTo(self.emojiPopView)
            make.top.equalTo(self.emojiPopView).offset(10)
        }
        //表情点击事件
        self.isUserInteractionEnabled = true
        let tapGes = UITapGestureRecognizer.init(target: self, action: #selector(self.isClicked))
        self.addGestureRecognizer(tapGes)
    }
    ///表情点击事件
    @objc fileprivate func isClicked() {
        self.block?(imageUrl)
    }
    ///点击效果
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        //显示放大镜
        showPopView(true)
        
        for touch: AnyObject in touches {
            let t: UITouch = touch as! UITouch
            let location = t.location(in: self)
            
            //RIPPLE FILL
            rippleFill(20, location, UIColor.white)
        }
    }
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        //隐藏放大镜
        showPopView(false)
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        //隐藏放大镜
        showPopView(false)
    }
    ///显示放大镜
    fileprivate func showPopView(_ show: Bool) {
        if show {
            self.emojiPopView.isHidden = false
            let imageView = emojiPopView.viewWithTag(10001) as! UIImageView
            imageView.moveY(-4).duration(0.2).then().moveY(4).duration(0.2).animate()
        } else {
            let imageView = emojiPopView.viewWithTag(10001) as! UIImageView
            imageView.cancelAllRemaining()
            imageView.frame.origin.y = 10
            self.emojiPopView.isHidden = true
        }
    }
}
