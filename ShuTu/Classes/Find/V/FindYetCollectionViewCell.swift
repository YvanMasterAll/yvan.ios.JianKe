//
//  FindYetCollectionViewCell.swift
//  ShuTu
//
//  Created by yiqiang on 2018/1/8.
//  Copyright © 2018年 yiqiang. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class FindYetCollectionViewCell: FSPagerViewCell {

    @IBOutlet weak var opposeButton: UIButton! {
        didSet {
            self.opposeButton.addTarget(self, action: #selector(self.oppose), for: .touchUpInside)
        }
    }
    @IBOutlet weak var supportButton: UIButton! {
        didSet {
            self.supportButton.addTarget(self, action: #selector(self.support), for: .touchUpInside)
        }
    }
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var view:  UIView! {
        didSet {
            self.view.layer.cornerRadius = 8
            self.view.layer.masksToBounds = true
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
        
        commonInit()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        //内阴影
        view.layer.shadowRadius = 8
        view.layer.shadowOpacity = 0.8
        view.layer.shadowColor = GMColor.grey500Color().cgColor
        view.layer.shadowOffset = CGSize.zero
        view.generateInnerShadow()
    }
    
    //私有
    fileprivate var supported: Int = 0
    fileprivate var voting: Bool = false
    
}

extension FindYetCollectionViewCell {
    //初始化
    fileprivate func commonInit() {
        self.backgroundColor = UIColor.white
        self.needShadow = false
    }
    fileprivate func bindRx() {
        self.viewModel.outputs.voteResult.asObservable()
            .subscribe(onNext: { [weak self] result in
                guard let _ = self else { return }
                guard self!.voting else { return }
                self!.voting = false
                switch result {
                case .ok:
                    self!.setVoteButtons()
                    break
                case .failed:
                    HUD.flash(.label("投票失败"))
                    break
                default:
                    break
                }
            })
            .disposed(by: self.disposeBag)
    }
    //按钮事件
    @objc fileprivate func support() {
        guard self.supported == 0 else { HUD.flash(.label("已投票")); return }
        self.viewModel.inputs.voteTap.onNext((id, AttitudeStand.support))
        self.supported = 1
        self.voting = true
    }
    @objc fileprivate func oppose() {
        guard self.supported == 0 else { HUD.flash(.label("已投票")); return }
        self.viewModel.inputs.voteTap.onNext((id, AttitudeStand.oppose))
        self.supported = 2
        self.voting = true
    }
    //按钮变更
    fileprivate func setVoteButtons() {
        if self.supported == 1 {
            self.supportButton.setTitleColor(GMColor.red600Color(), for: .normal)
            self.opposeButton.setTitleColor(ColorPrimary, for: .normal)
        } else if self.supported == 2 {
            self.supportButton.setTitleColor(ColorPrimary, for: .normal)
            self.opposeButton.setTitleColor(GMColor.red600Color(), for: .normal)
        }
    }
}
