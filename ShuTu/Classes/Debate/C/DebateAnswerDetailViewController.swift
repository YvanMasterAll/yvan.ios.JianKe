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

class DebateAnswerDetailViewController: UIViewController {
    
    @IBOutlet weak var debateTitleBar: UIView!
    @IBOutlet weak var debateTitle: UILabel!
    @IBOutlet weak var userBar: UIView!
    @IBOutlet weak var userBarName: UILabel!
    @IBOutlet weak var userBarThumbnail: UIImageView!
    @IBOutlet weak var userBarFollowButton: UIButton!
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var actionBar: UIView!
    
    //声明区
    public var section: Answer!

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        bindRx()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        print("deinit: \(type(of: self))")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        //隐藏导航栏
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //显示导航栏
        self.navigationItem.title = "回答详情"
        self.navigationItem.backBarButtonItem = UIBarButtonItem.init(title: "", style: .plain, target: self, action: nil)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
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
        button.setImage(UIImage.init(icon: .fontAwesome(.thumbsOUp), size: CGSize(width: 30, height: 30), textColor: GMColor.grey600Color(), backgroundColor: UIColor.clear), for: .normal)
        button.imageEdgeInsets.bottom = imageBottom
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
        self.userBarName.text = section.username
        self.userBarThumbnail.layer.cornerRadius = self.userBarThumbnail.frame.width/2
        self.userBarThumbnail.layer.masksToBounds = true
        self.userBarThumbnail.kf.setImage(with: URL(string: section.thumbnail!))
        //Buttons
        self.userBarFollowButton.setImage(UIImage.init(icon: .fontAwesome(.plus), size: CGSize(width: 20, height: 20), textColor: ColorPrimary, backgroundColor: UIColor.clear), for: .normal)
        self.userBarFollowButton.contentEdgeInsets.left = 8
        self.userBarFollowButton.contentEdgeInsets.right = 8
        //ActionBar
        self.actionBar.backgroundColor = GMColor.grey50Color()
        self.actionBar.addSubview(self.actionButtonSY)
        let tapGes = UITapGestureRecognizer.init(target: self, action: #selector(self.zanClicked))
        self.actionButtonSY.addGestureRecognizer(tapGes)
        self.actionBar.addSubview(self.actionButtonST)
        self.actionBar.addSubview(self.actionButtonTG)
        self.actionBar.addSubview(self.actionButtonKeep)
        self.actionBar.addSubview(self.actionButtonComment)
    }
    fileprivate func bindRx() {
        //View Model
        self.viewModel = DebateAnswerDetailViewModel(disposeBag: disposeBag, section: self.section)
        //Rx
        weak var weakself = self
        viewModel.outputs.section!
            .subscribe(onNext: { data in
                guard data.body != nil else {
                    return
                }
                //AnswerDetail
                weakself?.webViewLoad(data: data)
            })
            .disposed(by: disposeBag)
        viewModel.outputs.emptyStateObserver.asObservable()
            .subscribe(onNext: { state in
                switch state {
                case .loading(let type):
                    weakself?.emptyView.show(type: .loading(type: type), frame: CGRect(x: weakself!.webView.frame.origin.x, y: weakself!.webView.frame.origin.y, width: SW, height: SH - weakself!.webView.frame.origin.y - weakself!.actionBar.frame.size.height))
                    break
                case .empty:
                    weakself?.emptyView.hide()
                default:
                    break
                }
            })
            .disposed(by: disposeBag)
        //首次加载
        viewModel.inputs.refreshData.onNext(())
    }
    //WebView Load Data
    fileprivate func webViewLoad(data: AnswerDetail){
        webView.loadHTMLString(self.concatHTML(css: data.css!, body: data.body!), baseURL: nil)
    }
    //NavigationBarItem Action
    @objc fileprivate func goBack() {
        if (navigationController != nil) {
            navigationController?.popViewController(animated: true)
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
    //Deal With Html String
    private func concatHTML(css: [String], body: String) -> String {
        var html = "<html>"
        html += "<head>"
        css.forEach { html += "<link rel=\"stylesheet\" href=\"\($0)\">" }
        //H5 模式
        html += "<meta name='viewport' content='width=device-width, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, user-scalable=no'>"
        html += "<style>body{font-size: 30px}img{max-width:320px !important;}</style>"
        html += "</head>"
        html += "<body>"
        html += body
        html += "</body>"
        html += "</html>"
        return html
    }
    //ActionBar Event
    @objc fileprivate func commentButtonClicked() {
        let storyBoard = UIStoryboard.init(name: "Debate", bundle: nil)
        let debateAnswerCommentVC = storyBoard.instantiateViewController(withIdentifier: "AnswerComment") as! DebateAnswerCommentViewController
        debateAnswerCommentVC.section = self.section
        self.navigationController?.pushViewController(debateAnswerCommentVC, animated: true)
    }
    @objc fileprivate func zanClicked() {
        //点赞
        
    }
}

extension DebateAnswerDetailViewController: WKNavigationDelegate, EmptyViewDelegate {
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
        self.emptyView.show(type: .empty, frame: CGRect(x: self.webView.frame.origin.x, y: self.webView.frame.origin.y, width: SW, height: SH - self.webView.frame.origin.y - self.actionBar.frame.size.height))
    }
    //EmptyViewDelegate
    func emptyViewClicked() {
        //重新加载
        viewModel.inputs.refreshData.onNext(())
    }
}
