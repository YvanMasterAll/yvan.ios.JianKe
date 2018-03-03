//
//  FindGayCollectionViewCell.swift
//  ShuTu
//
//  Created by yiqiang on 2018/1/8.
//  Copyright © 2018年 yiqiang. All rights reserved.
//

import UIKit
import PMSuperButton
import RxCocoa
import RxSwift

class FindGayCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var sign: UILabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var thumbnail: UIImageView! {
        didSet {
            self.thumbnail.layer.cornerRadius = self.thumbnail.frame.height/2
            self.thumbnail.layer.masksToBounds = true
        }
    }
    @IBOutlet weak var followButton: PMSuperButton! {
        didSet {
            self.followButton.setImage(UIImage.init(named: "icon_plus_white")!.reSizeImage(CGSize.init(width: 14, height: 14)), for: .normal)
            self.followButton.contentEdgeInsets.left = 8
            self.followButton.contentEdgeInsets.right = 8
            self.followButton.addTarget(self, action: #selector(self.follow), for: .touchUpInside)
        }
    }
    
    //声明区域
    open var id: Int!
    open var viewModel: FindViewModel! {
        didSet {
            self.bindRx()
        }
    }
    open var disposeBag: DisposeBag!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

    }
    
    //私有
    fileprivate var followed: Bool = false
    fileprivate var following: Bool = false
    
}

extension FindGayCollectionViewCell {
    ///初始化
    fileprivate func bindRx() {
        self.viewModel.outputs.followResult.asObservable()
            .subscribe(onNext: { [weak self] result in
                guard let _ = self else { return }
                guard self!.following else { return }
                self!.following = false
                switch result {
                case .ok:
                    self!.followed = !self!.followed
                    self!.applyFollowButton()
                    break
                case .failed:
                    if self!.followed {
                        HUD.flash(.label("取消关注失败"))
                    } else {
                        HUD.flash(.label("关注失败"))
                    }
                    break
                default:
                    break
                }
            })
            .disposed(by: self.disposeBag)
    }
    //按钮事件
    @objc fileprivate func follow() {
        self.viewModel.inputs.followTap.onNext((id, !self.followed))
        self.following = true
    }
    //按钮变更
    fileprivate func applyFollowButton() {
        if self.followed {
            self.followButton.setTitle("已关注", for: .normal)
            self.followButton.backgroundColor = ColorPrimary.darken(by: 0.2)
            self.followButton.setImage(nil, for: .normal)
        } else {
            self.followButton.setTitle("关注", for: .normal)
            self.followButton.backgroundColor = ColorPrimary
            self.followButton.setImage(UIImage.init(named: "icon_plus_white")!.reSizeImage(CGSize.init(width: 14, height: 14)), for: .normal)
        }
    }
}
