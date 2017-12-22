//
//  DebateDetailViewController.swift
//  ShuTu
//
//  Created by yiqiang on 2017/12/22.
//  Copyright © 2017年 yiqiang. All rights reserved.
//

import UIKit

class DebateDetailViewController: UIViewController {

    @IBOutlet weak var navigationBar: UIView!
    @IBOutlet weak var navigationBarLeftImage: UIImageView!
    @IBOutlet weak var navigationBarTitle: UILabel!
    @IBOutlet weak var debateTitle: UILabel!
    @IBOutlet weak var debateDesc: UILabel!
    @IBOutlet weak var followButton: UIButton!
    @IBOutlet weak var score: UILabel!
    @IBOutlet weak var inviteButton: UIButton!
    @IBOutlet weak var answerButton: UIButton!
    @IBOutlet weak var answerScore: UILabel!
    @IBOutlet weak var descLabelHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var descFolder: UILabel!
    @IBOutlet weak var actionView: UIView!
    
    //声明区
    open var section: Debate!
    
    //私有成员
    fileprivate var fold: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //隐藏导航栏
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }

}

extension DebateDetailViewController {
    
    //初始化
    fileprivate func setupUI() {
        //NavigationBarView
        GeneralFactory.generateRectShadow(layer: self.navigationBar.layer, rect: CGRect(x: 0, y: self.navigationBar.frame.size.height, width: SW, height: 0.5), color: GMColor.grey900Color().cgColor)
        self.navigationBarLeftImage.setIcon(icon: .fontAwesome(.angleLeft), textColor: GMColor.grey900Color(), backgroundColor: UIColor.clear, size: nil)
        //Buttons
        self.inviteButton.setImage(UIImage(icon: .fontAwesome(.userPlus), size: CGSize(width: 14, height: 14), textColor: GMColor.grey600Color(), backgroundColor: UIColor.clear), for: .normal)
        self.answerButton.setImage(UIImage(icon: .fontAwesome(.edit), size: CGSize(width: 14, height: 14), textColor: GMColor.grey600Color(), backgroundColor: UIColor.clear), for: .normal)
        self.descFolder.setIcon(prefixText: "展开问题详情", prefixTextColor: GMColor.grey500Color(), icon: .fontAwesome(.angleDown), iconColor: GMColor.grey500Color(), postfixText: "", postfixTextColor: UIColor.clear, size: 11, iconSize: 11)
        self.followButton.contentEdgeInsets.left = 8
        self.followButton.contentEdgeInsets.right = 8
        //ActionView 添加边框
        let topBorderLayer = CALayer()
        topBorderLayer.frame = CGRect(x: 0, y: 0, width: SW, height: 1)
        topBorderLayer.backgroundColor = GMColor.grey50Color().cgColor
        self.actionView.layer.addSublayer(topBorderLayer)
        //初始化布局
        setupLayout()
    }
    fileprivate func setupLayout() {
        //Desc Label
        let desc = self.section.desc!
        debateDesc.text = desc
        let descHeightMax = self.debateDesc.heightOfLines(by: 2)
        let descHeight = self.debateDesc.height
        if descHeight > descHeightMax {
            self.descLabelHeightConstraint.constant = descHeightMax
            self.descFolder.isHidden = false
        } else {
            self.descFolder.isHidden = true
            self.descLabelHeightConstraint.constant = descHeight
        }
        debateTitle.text = self.section.title!
    }
    fileprivate func foldDescLabel() {
        if self.descFolder.isHidden { return }
        
        if fold {//收起
            
            self.fold = false
        } else {//折叠
            
            self.fold = true
        }
    }
}
