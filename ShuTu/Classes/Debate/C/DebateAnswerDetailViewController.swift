//
//  DebateAnswerDetailViewController.swift
//  ShuTu
//
//  Created by yiqiang on 2017/12/26.
//  Copyright © 2017年 yiqiang. All rights reserved.
//

import UIKit
import PMSuperButton

class DebateAnswerDetailViewController: UIViewController {
    
    @IBOutlet weak var debateTitleBar: UIView!
    @IBOutlet weak var debateTitle: UILabel!
    @IBOutlet weak var navigationBar: UIView!
    @IBOutlet weak var navigationBarLeftImage: UIImageView!
    @IBOutlet weak var userBar: UIView!
    @IBOutlet weak var userBarName: UILabel!
    @IBOutlet weak var userBarThumbnail: UIImageView!
    @IBOutlet weak var userBarFollowButton: UIButton!
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var actionBar: UIView!
    
    //声明区
    public var section: Answer!

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //UserBar 添加下边框
        let bottomBorderLayer = CALayer()
        bottomBorderLayer.frame = CGRect(x: 0, y: userBar.frame.height - 1, width: SW, height: 1)
        bottomBorderLayer.backgroundColor = GMColor.grey300Color().cgColor
        self.userBar.layer.addSublayer(bottomBorderLayer)
        //DebateTitleBar 添加下边框
        let bottomBorderLayer2 = CALayer()
        bottomBorderLayer2.frame = CGRect(x: 0, y: debateTitleBar.frame.height - 1, width: SW, height: 1)
        bottomBorderLayer2.backgroundColor = GMColor.grey300Color().cgColor
        self.debateTitleBar.layer.addSublayer(bottomBorderLayer2)
        //ActionBar 添加上边框
        let topBorderLayer = CALayer()
        topBorderLayer.frame = CGRect(x: 0, y: 0, width: SW, height: 1)
        topBorderLayer.backgroundColor = GMColor.grey300Color().cgColor
        self.actionBar.layer.addSublayer(topBorderLayer)
    }
    
    //私有成员
    fileprivate lazy var actionButtonSY: UIButton = { //声援按钮
        let w = SW/5
        let h = self.actionBar.frame.height
        let imageSize: CGFloat = 30
        let imageBottom: CGFloat = 12
        let labelTop = (h + imageSize - imageBottom)/2
        let button = PMSuperButton(frame: CGRect(x: 0, y: 0, width: w, height: h))
        button.ripple = true
        button.setImage(UIImage.init(icon: .fontAwesome(.ils), size: CGSize(width: 30, height: 30), textColor: GMColor.grey600Color(), backgroundColor: UIColor.clear), for: .normal)
        button.imageEdgeInsets.bottom = imageBottom
        let label = UILabel(frame: CGRect(x: 0, y: labelTop, width: w, height: 0))
        label.text = "声援"
        label.font = UIFont.systemFont(ofSize: 11)
        label.frame.size.height = label.height
        label.textColor = GMColor.grey600Color()
        label.textAlignment = .center
        button.addSubview(label)
        return button
    }()
    fileprivate lazy var actionButtonST: UIButton = { //殊途按钮
        let w = SW/5
        let h = self.actionBar.frame.height
        let imageSize: CGFloat = 30
        let imageBottom: CGFloat = 12
        let labelTop = (h + imageSize - imageBottom)/2
        let button = PMSuperButton(frame: CGRect(x: w, y: 0, width: w, height: h))
        button.ripple = true
        button.setImage(UIImage.init(icon: .fontAwesome(.strikethrough), size: CGSize(width: 30, height: 30), textColor: GMColor.grey600Color(), backgroundColor: UIColor.clear), for: .normal)
        button.imageEdgeInsets.bottom = imageBottom
        let label = UILabel(frame: CGRect(x: 0, y: labelTop, width: w, height: 0))
        label.text = "殊途"
        label.font = UIFont.systemFont(ofSize: 11)
        label.frame.size.height = label.height
        label.textColor = GMColor.grey600Color()
        label.textAlignment = .center
        button.addSubview(label)
        return button
    }()
    fileprivate lazy var actionButtonTG: UIButton = { //同归按钮
        let w = SW/5
        let h = self.actionBar.frame.height
        let imageSize: CGFloat = 30
        let imageBottom: CGFloat = 12
        let labelTop = (h + imageSize - imageBottom)/2
        let button = PMSuperButton(frame: CGRect(x: w*2, y: 0, width: w, height: h))
        button.ripple = true
        button.setImage(UIImage.init(icon: .fontAwesome(.gg), size: CGSize(width: 30, height: 30), textColor: GMColor.grey600Color(), backgroundColor: UIColor.clear), for: .normal)
        button.imageEdgeInsets.bottom = imageBottom
        let label = UILabel(frame: CGRect(x: 0, y: labelTop, width: w, height: 0))
        label.text = "同归"
        label.font = UIFont.systemFont(ofSize: 11)
        label.frame.size.height = label.height
        label.textColor = GMColor.grey600Color()
        label.textAlignment = .center
        button.addSubview(label)
        return button
    }()
    fileprivate lazy var actionButtonKeep: UIButton = { //收藏按钮
        let w = SW/5
        let h = self.actionBar.frame.height
        let imageSize: CGFloat = 30
        let imageBottom: CGFloat = 12
        let labelTop = (h + imageSize - imageBottom)/2
        let button = PMSuperButton(frame: CGRect(x: w*3, y: 0, width: w, height: h))
        button.ripple = true
        button.setImage(UIImage.init(icon: .fontAwesome(.starO), size: CGSize(width: 30, height: 30), textColor: GMColor.grey600Color(), backgroundColor: UIColor.clear), for: .normal)
        button.imageEdgeInsets.bottom = imageBottom
        let label = UILabel(frame: CGRect(x: 0, y: labelTop, width: w, height: 0))
        label.text = "收藏"
        label.font = UIFont.systemFont(ofSize: 11)
        label.frame.size.height = label.height
        label.textColor = GMColor.grey600Color()
        label.textAlignment = .center
        button.addSubview(label)
        return button
    }()
    fileprivate lazy var actionButtonComment: UIButton = { //评论按钮
        let w = SW/5
        let h = self.actionBar.frame.height
        let imageSize: CGFloat = 30
        let imageBottom: CGFloat = 12
        let labelTop = (h + imageSize - imageBottom)/2
        let button = PMSuperButton(frame: CGRect(x: w*4, y: 0, width: w, height: h))
        button.ripple = true
        button.setImage(UIImage.init(icon: .fontAwesome(.commentO), size: CGSize(width: 30, height: 30), textColor: GMColor.grey600Color(), backgroundColor: UIColor.clear), for: .normal)
        button.imageEdgeInsets.bottom = imageBottom
        let label = UILabel(frame: CGRect(x: 0, y: labelTop, width: w, height: 0))
        label.text = "179"
        label.font = UIFont.systemFont(ofSize: 11)
        label.frame.size.height = label.height
        label.textColor = GMColor.grey600Color()
        label.textAlignment = .center
        button.addSubview(label)
        return button
    }()

}

extension DebateAnswerDetailViewController {
    //初始化
    fileprivate func setupUI() {
        //DebateTitle
        self.debateTitle.text = section.title
        //UserBar
        self.userBarName.text = section.username
        self.userBarThumbnail.layer.cornerRadius = self.userBarThumbnail.frame.width/2
        self.userBarThumbnail.kf.setImage(with: URL(string: section.thumbnail!))
        //Buttons
        self.userBarFollowButton.setImage(UIImage.init(icon: .fontAwesome(.plus), size: CGSize(width: 20, height: 20), textColor: ColorPrimary, backgroundColor: UIColor.clear), for: .normal)
        self.userBarFollowButton.contentEdgeInsets.left = 8
        self.userBarFollowButton.contentEdgeInsets.right = 8
        //NavigationBarView
        GeneralFactory.generateRectShadow(layer: self.navigationBar.layer, rect: CGRect(x: 0, y: self.navigationBar.frame.size.height, width: SW, height: 0.5), color: GMColor.grey900Color().cgColor)
        self.navigationBarLeftImage.setIcon(icon: .fontAwesome(.angleLeft), textColor: GMColor.grey900Color(), backgroundColor: UIColor.clear, size: nil)
        self.navigationBarLeftImage.isUserInteractionEnabled = true
        let goBackTapGes = UITapGestureRecognizer(target: self, action: #selector(self.goBack))
        self.navigationBarLeftImage.addGestureRecognizer(goBackTapGes)
        //ActionBar
        self.actionBar.backgroundColor = GMColor.grey50Color()
        self.actionBar.addSubview(self.actionButtonSY)
        self.actionBar.addSubview(self.actionButtonST)
        self.actionBar.addSubview(self.actionButtonTG)
        self.actionBar.addSubview(self.actionButtonKeep)
        self.actionBar.addSubview(self.actionButtonComment)
    }
    //NavigationBarItem Action
    @objc fileprivate func goBack() {
        if (navigationController != nil) {
            navigationController?.popViewController(animated: true)
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
}
