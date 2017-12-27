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
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var topViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var descLabelHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var descFolder: UILabel!
    @IBOutlet weak var actionView: UIView!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var pagerView: FSPagerView! {
        didSet {
            self.pagerView.register(UINib(nibName: "DebateDetailCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "pagerCell")
            self.pagerView.itemSize = .zero
        }
    }
    
    //声明区
    open var section: Debate!
    
    //私有成员
    fileprivate var fold: Bool = true
    fileprivate var viewModel: DebateDetailViewModel! {
        return DebateDetailViewModel(section: self.section)
    }
    fileprivate var currentOffset = CGPoint.zero
    
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
        //Tabbar
        self.hidesBottomBarWhenPushed = true
        //SegmentControl
        self.segmentControl.addTarget(self, action: #selector(self.segmentControlChanged), for: UIControlEvents.valueChanged)
        //NavigationBarView
        GeneralFactory.generateRectShadow(layer: self.navigationBar.layer, rect: CGRect(x: 0, y: self.navigationBar.frame.size.height, width: SW, height: 0.5), color: GMColor.grey900Color().cgColor)
        self.navigationBarLeftImage.setIcon(icon: .fontAwesome(.angleLeft), textColor: GMColor.grey900Color(), backgroundColor: UIColor.clear, size: nil)
        self.navigationBarLeftImage.isUserInteractionEnabled = true
        let goBackTapGes = UITapGestureRecognizer(target: self, action: #selector(self.goBack))
        self.navigationBarLeftImage.addGestureRecognizer(goBackTapGes)
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
    //NavigationBarItem Action
    @objc fileprivate func goBack() {
        if (navigationController != nil) {
            navigationController?.popViewController(animated: true)
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
    //SegmengControl Changed
    @objc fileprivate func segmentControlChanged(sender: UISegmentedControl) {
        self.pagerView.scrollToItem(at: sender.selectedSegmentIndex, animated: true)
    }
}

extension DebateDetailViewController: FSPagerViewDelegate, FSPagerViewDataSource, DebateDetailCollectionViewCellDelegate {
    //FSPagerViewDataSource & FSPagerViewDelegate
    func scrollViewDidScroll(_ scrollView: UIScrollView, _ offset: CGPoint) {
        //通过代理 TableView 滚动实现 TopView 的滚动
        let currentOffsetY = offset.y
        let topViewOffsetY = self.topViewTopConstraint.constant
        let topViewOffsetMin: CGFloat = 10
        let topViewOffsetMax = -self.topView.frame.height
        if currentOffsetY > 0 {
            if topViewOffsetY > topViewOffsetMax {
                var offsetY: CGFloat = topViewOffsetY - currentOffsetY
                offsetY = offsetY < topViewOffsetMax ? topViewOffsetMax:offsetY
                self.topViewTopConstraint.constant = offsetY
                self.topView.setNeedsUpdateConstraints()
            }
        } else {
            if topViewOffsetY < topViewOffsetMin {
                var offsetY: CGFloat = topViewOffsetY - currentOffsetY
                offsetY = offsetY > 10 ? 10:offsetY
                self.topViewTopConstraint.constant = offsetY
                self.topView.setNeedsUpdateConstraints()
            }
        }
    }
    public func numberOfItems(in pagerView: FSPagerView) -> Int {
        return 2
    }
    func pagerViewDidScroll(_ pagerView: FSPagerView) {
        //SegmentControl
        guard self.segmentControl.selectedSegmentIndex != pagerView.currentIndex else {
            return
        }
        self.segmentControl.selectedSegmentIndex = pagerView.currentIndex
    }
    public func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        let cell = pagerView.dequeueReusableCell(withReuseIdentifier: "pagerCell", at: index) as! DebateDetailCollectionViewCell
        cell.delegate = self
        cell.navigationController = self.navigationController
        //Side
        if index == 0 {
            cell.side = .SY
        } else {
            cell.side = .ST
        }
        //传入 VM
        if cell.viewModel == nil {
            cell.viewModel = self.viewModel
        }
        //传入 Model
        cell.section = self.section
        
        return cell
    }
    func pagerView(_ pagerView: FSPagerView, didSelectItemAt index: Int) {
        pagerView.deselectItem(at: index, animated: true)
        pagerView.scrollToItem(at: index, animated: true)
    }
}
