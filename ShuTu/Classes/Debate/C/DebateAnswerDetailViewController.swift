//
//  DebateAnswerDetailViewController.swift
//  ShuTu
//
//  Created by yiqiang on 2017/12/26.
//  Copyright © 2017年 yiqiang. All rights reserved.
//

import UIKit
import PMSuperButton
import RxSwift
import RxCocoa
import WebKit
import Stellar

class DebateAnswerDetailViewController: BaseViewController {
    
    @IBOutlet weak var debateTitleBar: UIView!
    @IBOutlet weak var debateTitle: UILabel!
    @IBOutlet weak var userBar: UIView!
    @IBOutlet weak var userBarName: UILabel!
    @IBOutlet weak var userBarThumbnail: UIImageView!
    @IBOutlet weak var userBarFollowButton: UIButton! {
        didSet {
            self.userBarFollowButton.addTarget(self, action: #selector(self.follow), for: .touchUpInside)
        }
    }
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var actionBar: UIView!
    
    //声明区
    public var section: Answer!

    override func viewDidLoad() {
        super.viewDidLoad()

        showNavbar = true
        navBarTitle = "回答详情"
        hideNavbar = true
        setupUI()
        bindRx()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
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
    fileprivate var supported: Bool = false
    fileprivate var opposed: Bool = false
    fileprivate var bravoed: Bool = false
    fileprivate var collected: Bool = false
    fileprivate var followed: Bool = false
    fileprivate weak var viewModel: DebateAnswerDetailViewModel!
    fileprivate var disposeBag = DisposeBag()
    fileprivate lazy var emptyView: EmptyView = {
        let emptyView = EmptyView(target: self.view)
        emptyView.delegate = self
        return emptyView
    }()
    //Action Bar
    fileprivate lazy var actionButtonSY: UIButton = { //赞同按钮
        let w = SW/5
        let h = self.actionBar.frame.height
        let imageSize: CGFloat = 30
        let imageBottom: CGFloat = 12
        let labelTop = (h + imageSize - imageBottom)/2
        let button = PMSuperButton(frame: CGRect(x: 0, y: 0, width: w, height: h))
        button.ripple = true
        let imageView = UIImageView.init(image: UIImage.init(icon: .fontAwesome(.thumbsOUp), size: CGSize(width: 30, height: 30), textColor: GMColor.grey600Color(), backgroundColor: UIColor.clear))
        imageView.frame.origin = CGPoint.init(x: (w-30)/2, y: 4)
        imageView.tag = 10001
        button.addSubview(imageView)
        let label = UILabel(frame: CGRect(x: 0, y: labelTop, width: w, height: 0))
        label.text = "赞"
        label.font = UIFont.systemFont(ofSize: 11)
        label.frame.size.height = label.heightOfLine
        label.textColor = GMColor.grey600Color()
        label.textAlignment = .center
        button.addSubview(label)
        return button
    }()
    fileprivate lazy var actionButtonST: UIButton = { //踩按钮
        let w = SW/5
        let h = self.actionBar.frame.height
        let imageSize: CGFloat = 30
        let imageBottom: CGFloat = 12
        let labelTop = (h + imageSize - imageBottom)/2
        let button = PMSuperButton(frame: CGRect(x: w, y: 0, width: w, height: h))
        button.ripple = true
        button.setImage(UIImage.init(icon: .fontAwesome(.thumbsODown), size: CGSize(width: 30, height: 30), textColor: GMColor.grey600Color(), backgroundColor: UIColor.clear), for: .normal)
        button.imageEdgeInsets.bottom = imageBottom
        let label = UILabel(frame: CGRect(x: 0, y: labelTop, width: w, height: 0))
        label.text = "踩"
        label.font = UIFont.systemFont(ofSize: 11)
        label.frame.size.height = label.heightOfLine
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
        label.frame.size.height = label.heightOfLine
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
        label.frame.size.height = label.heightOfLine
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
        label.frame.size.height = label.heightOfLine
        label.textColor = GMColor.grey600Color()
        label.textAlignment = .center
        button.addSubview(label)
        //Ges
        let tapGes = UITapGestureRecognizer(target: self, action: #selector(self.commentButtonClicked))
        button.addGestureRecognizer(tapGes)
        return button
    }()

}

extension DebateAnswerDetailViewController {
    //初始化
    fileprivate func setupUI() {
        //WebView
        self.webView.scrollView.showsVerticalScrollIndicator = false
        self.webView.navigationDelegate = self
        //DebateTitle
        self.debateTitle.text = section.title
        //UserBar
        self.userBarName.text = section.nickname
        self.userBarThumbnail.layer.cornerRadius = self.userBarThumbnail.frame.width/2
        self.userBarThumbnail.layer.masksToBounds = true
        self.userBarThumbnail.kf.setImage(with: URL(string: section.portrait!))
        //Buttons
        self.userBarFollowButton.setImage(UIImage.init(icon: .fontAwesome(.plus), size: CGSize(width: 20, height: 20), textColor: ColorPrimary, backgroundColor: UIColor.clear), for: .normal)
        self.userBarFollowButton.contentEdgeInsets.left = 8
        self.userBarFollowButton.contentEdgeInsets.right = 8
        //ActionBar
        self.actionBar.backgroundColor = GMColor.grey50Color()
        self.actionBar.addSubview(self.actionButtonSY)
        self.actionButtonSY.addTarget(self, action: #selector(self.zanClicked), for: .touchUpInside)
        self.actionButtonST.addTarget(self, action: #selector(self.caiClicked), for: .touchUpInside)
        self.actionButtonTG.addTarget(self, action: #selector(self.tgClicked), for: .touchUpInside)
        self.actionButtonKeep.addTarget(self, action: #selector(self.keepClicked), for: .touchUpInside)
        self.actionBar.addSubview(self.actionButtonST)
        self.actionBar.addSubview(self.actionButtonTG)
        self.actionBar.addSubview(self.actionButtonKeep)
        self.actionBar.addSubview(self.actionButtonComment)
    }
    fileprivate func bindRx() {
        //View Model
        self.viewModel = DebateAnswerDetailViewModel(disposeBag: disposeBag, section: self.section)
        //Rx
        viewModel.outputs.followResult
            .asObservable()
            .subscribe(onNext: { [unowned self] result in
                if self.followed { //取消关注结果
                    switch result {
                    case .failed:
                        HUD.flash(.label("取消关注失败"))
                        break
                    case .ok:
                        self.applyFollowButton(false)
                        break
                    default:
                        break
                    }
                } else { //关注结果
                    switch result {
                    case .failed:
                        HUD.flash(.label("关注失败"))
                        break
                    case .ok:
                        self.applyFollowButton(true)
                        break
                    case .exist:
                        self.applyFollowButton(true)
                        break
                    default:
                        break
                    }
                }
                
            })
            .disposed(by: disposeBag)
        viewModel.outputs.followCheck
            .asObservable()
            .subscribe(onNext: { [unowned self] result in
                switch result {
                case .exist:
                    self.applyFollowButton(true)
                    break
                case .empty:
                    self.applyFollowButton(false)
                    break
                default:
                    self.applyFollowButton(false)
                    break
                }
            })
            .disposed(by: disposeBag)
        viewModel.outputs.attitudeResult
            .asObservable()
            .subscribe(onNext: { [unowned self] attitude in
                self.applyAttitudeButtons(attitude)
            })
            .disposed(by: disposeBag)
        //检查关注
        self.viewModel.inputs.followCheck.onNext(())
        //检查态度
        self.viewModel.inputs.attitudeCheck.onNext(())
        //加载详情
        viewModel.outputs.emptyStateObserver.value = .loading(type: .indicator1)
        self.webView.loadHTMLString(self.section.answer!, baseURL: nil)
        self.emptyView.show(type: .loading(type: .indicator1), frame: CGRect(x: self.webView.frame.origin.x, y: self.webView.frame.origin.y, width: SW, height: SH - self.webView.frame.origin.y - self.actionBar.frame.size.height))
    }
    //关注按钮点击事件
    @objc fileprivate func follow() {
        if self.followed {// 取消关注
            viewModel.inputs.followTap.onNext(false)
        } else {// 关注
            viewModel.inputs.followTap.onNext(true)
        }
    }
    //关注按钮状态更新
    fileprivate func applyFollowButton(_ followed: Bool) {
        self.followed = followed
        self.userBarFollowButton.isHidden = false
        if followed {
            self.userBarFollowButton.setTitle("已关注", for: .normal)
            self.userBarFollowButton.setImage(nil, for: .normal)
        } else {
            self.userBarFollowButton.setTitle("关注", for: .normal)
            self.userBarFollowButton.setImage(UIImage.init(icon: .fontAwesome(.plus), size: CGSize(width: 20, height: 20), textColor: ColorPrimary, backgroundColor: UIColor.clear), for: .normal)
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
    //ActionBar Event
    @objc fileprivate func commentButtonClicked() {
        let debateAnswerCommentVC = GeneralFactory.getVCfromSb("Debate", "DebateComment") as! DebateCommentViewController
        debateAnswerCommentVC.section = self.section
        self.navigationController?.pushViewController(debateAnswerCommentVC, animated: true)
    }
    @objc fileprivate func zanClicked() {
        //点赞
        self.applyAttitude(attitude: AttitudeStand.support, toggle: !self.supported)
        let imageView = self.actionButtonSY.viewWithTag(10001) as! UIImageView
        self.actionButtonSY.isEnabled = false
        imageView.scaleXY(1.2, 1.2).then().rotate(0.4).then().rotate(-0.8).then().rotate(0.4).then().scaleXY(1/1.2, 1/1.2).completion { [weak self] in
            self?.actionButtonSY.isEnabled = true
        }.animate()
    }
    @objc fileprivate func caiClicked() {
        self.applyAttitude(attitude: AttitudeStand.oppose, toggle: !self.opposed)
    }
    @objc fileprivate func tgClicked() {
        self.applyAttitude(attitude: AttitudeStand.bravo, toggle: !self.bravoed)
    }
    @objc fileprivate func keepClicked() {
        self.applyAttitude(attitude: AttitudeStand.collect, toggle: !self.collected)
    }
    //发起态度
    fileprivate func applyAttitude(attitude: AttitudeStand, toggle: Bool) {
        self.viewModel.inputs.attitudeTap.onNext((attitude, toggle))
    }
    fileprivate func applyAttitudeButtons(_ attitude: AnswerAttitude) {
        if let support = attitude.support {
            if support == 1 {
                let imageView = actionButtonSY.viewWithTag(10001) as! UIImageView
                imageView.image = UIImage.init(icon: .fontAwesome(.thumbsOUp), size: CGSize(width: 30, height: 30), textColor: GMColor.red600Color(), backgroundColor: UIColor.clear)
            } else {
                let imageView = actionButtonSY.viewWithTag(10001) as! UIImageView
                imageView.image = UIImage.init(icon: .fontAwesome(.thumbsOUp), size: CGSize(width: 30, height: 30), textColor: GMColor.grey600Color(), backgroundColor: UIColor.clear)
            }
            self.supported = support == 1 ? true:false
        }
        if let oppose = attitude.oppose {
            if oppose == 1 {
                actionButtonST.setImage(UIImage.init(icon: .fontAwesome(.thumbsODown), size: CGSize(width: 30, height: 30), textColor: GMColor.red600Color(), backgroundColor: UIColor.clear), for: .normal)
            } else {
                actionButtonST.setImage(UIImage.init(icon: .fontAwesome(.thumbsODown), size: CGSize(width: 30, height: 30), textColor: GMColor.grey600Color(), backgroundColor: UIColor.clear), for: .normal)
            }
            self.opposed = oppose == 1 ? true:false
        }
        if let bravo = attitude.bravo {
            if bravo == 1 {
                actionButtonTG.setImage(UIImage.init(icon: .fontAwesome(.gg), size: CGSize(width: 30, height: 30), textColor: GMColor.red600Color(), backgroundColor: UIColor.clear), for: .normal)
            } else {
                actionButtonTG.setImage(UIImage.init(icon: .fontAwesome(.gg), size: CGSize(width: 30, height: 30), textColor: GMColor.grey600Color(), backgroundColor: UIColor.clear), for: .normal)
            }
            self.bravoed = bravo == 1 ? true:false
        }
        if let collect = attitude.collect {
            if collect == 1 {
                actionButtonKeep.setImage(UIImage.init(icon: .fontAwesome(.starO), size: CGSize(width: 30, height: 30), textColor: GMColor.red600Color(), backgroundColor: UIColor.clear), for: .normal)
            } else {
                actionButtonKeep.setImage(UIImage.init(icon: .fontAwesome(.starO), size: CGSize(width: 30, height: 30), textColor: GMColor.grey600Color(), backgroundColor: UIColor.clear), for: .normal)
            }
            self.collected = collect == 1 ? true:false
        }
    }
}

extension DebateAnswerDetailViewController: WKNavigationDelegate {
    // WKNavigationDelegate
    // --------------------
    //页面开始加载
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        
    }
    //内容开始返回
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        
    }
    //页面加载完
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.emptyView.hide()
    }
    //页面加载失败
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        self.emptyView.show(type: .empty(size: nil), frame: CGRect(x: self.webView.frame.origin.x, y: self.webView.frame.origin.y, width: SW, height: SH - self.webView.frame.origin.y - self.actionBar.frame.size.height))
    }
}
