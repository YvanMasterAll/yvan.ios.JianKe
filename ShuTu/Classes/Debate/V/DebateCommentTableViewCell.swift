//
//  DebateCommentTableViewCell.swift
//  ShuTu
//
//  Created by yiqiang on 2017/12/31.
//  Copyright © 2017年 yiqiang. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class DebateCommentTableViewCell: UITableViewCell {

    @IBOutlet weak var dialogButton: UILabel!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var zan: UILabel!
    @IBOutlet weak var zanIcon: UIImageView!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var comment: UILabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var thumbnail: UIImageView!
    
    //MARK: - 声明区域
    open var id: Int!
    open var supported: Bool = false
    open var disposeBag: DisposeBag!
    open var viewModel: DebateCommentViewModel! {
        didSet {
            self.bindRx()
        }
    }
    
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
        self.zanIcon.setIcon(icon: .fontAwesome(.thumbsUp), textColor: STColor.grey600Color(), backgroundColor: UIColor.clear, size: nil)
        self.zanIcon.isUserInteractionEnabled = true
        self.zanIcon.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(self.support)))
        self.applySupportButton(self.supported, false)
        //为 BottomView 添加下边框
        let x: CGFloat = 0, y: CGFloat = self.bottomView.frame.height - 0.5, width: CGFloat = self.bottomView.frame.width, height: CGFloat = 0.5
        let bottomLayer = CALayer()
        bottomLayer.frame = CGRect(x: x, y: y, width: width, height: height)
        bottomLayer.backgroundColor = STColor.grey300Color().cgColor
        self.bottomView.layer.addSublayer(bottomLayer)
    }
    
    //MARK: - 私有成员
    fileprivate var supporting: Bool = false
    
}

extension DebateCommentTableViewCell {

    //MARK: - 初始化
    fileprivate func setupUI() {
        
    }
    fileprivate func bindRx() {
        self.viewModel.outputs.supportResult.asObservable()
            .subscribe(onNext: { [weak self] result in
                guard let _ = self else { return }
                guard self!.supporting else { return }
                self!.supporting = false
                switch result {
                case .ok:
                    self!.applySupportButton(!self!.supported, true)
                case .failed:
                    if self!.supported {
                        HUD.flash(.label("取消支持失败"))
                    } else {
                        HUD.flash(.label("支持失败"))
                    }
                default:
                    break
                }
            })
            .disposed(by: self.disposeBag)
    }
    public func setupConstraint() {
        //评论区不设置 label 的高度限制
    }
    
    //MAKR: - 按钮事件
    @objc fileprivate func support() {
        self.supporting = true
        self.viewModel.inputs.supportTap.onNext((!self.supported, self.id))
    }
    
    //MAKR: - 按钮状态变更
    fileprivate func applySupportButton(_ supported: Bool, _ flag: Bool) {
        self.supported = supported
        if supported {
            self.zanIcon.setIcon(icon: .fontAwesome(.thumbsUp), textColor: STColor.red600Color(), backgroundColor: UIColor.clear, size: nil)
            if flag, var supports = (Int)(self.zan.text!) {
                supports += 1
                self.zan.text = "\(supports)"
            }
        } else {
            self.zanIcon.setIcon(icon: .fontAwesome(.thumbsUp), textColor: STColor.grey600Color(), backgroundColor: UIColor.clear, size: nil)
            if flag, var supports = (Int)(self.zan.text!), supports > 0 {
                supports -= 1
                self.zan.text = "\(supports)"
            }
        }
    }
}
