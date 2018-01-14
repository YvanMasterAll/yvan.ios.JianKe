//
//  DebateDetailViewController.swift
//  ShuTu
//
//  Created by yiqiang on 2017/12/22.
//  Copyright © 2017年 yiqiang. All rights reserved.
//

import UIKit
import WebKit
import RxCocoa
import RxSwift
import RxGesture

class DebateDetailViewController: UIViewController {

    @IBOutlet weak var webViewContainerHeightC: NSLayoutConstraint!
    @IBOutlet weak var webViewContainer: UIView!
    @IBOutlet weak var webView: WKWebView! {
        didSet {
            //WebView
            self.webView.scrollView.showsVerticalScrollIndicator = false
            self.webView.navigationDelegate = self
        }
    }
    @IBOutlet weak var foldView: UIView! {
        didSet {
            self.foldView.backgroundColor = GMColor.whiteColor().withAlphaComponent(0.8)
            self.foldView.layer.cornerRadius = 2
            self.foldView.clipsToBounds = true
        }
    }
    @IBOutlet weak var foldIcon: UIImageView! {
        didSet {
            self.foldIcon.image = UIImage.init(icon: .fontAwesome(.arrowDown), size: self.foldIcon.frame.size, textColor: ColorPrimary, backgroundColor: UIColor.clear)
        }
    }
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            self.tableView.tableFooterView = UIView() //消除底部视图
            self.tableView.separatorStyle = .none //消除分割线
            self.tableView.showsVerticalScrollIndicator = false
            self.tableView.showsHorizontalScrollIndicator = false
        }
    }
    @IBOutlet weak var debateTitle: UILabel!
    @IBOutlet weak var followButton: UIButton! {
        didSet {
            self.followButton.setImage(UIImage.init(icon: .fontAwesome(.plus), size: CGSize.init(width: 14, height: 14), textColor: GMColor.whiteColor(), backgroundColor: UIColor.clear), for: .normal
            )
        }
    }
    @IBOutlet weak var score: UILabel!
    @IBOutlet weak var inviteButton: UIButton!
    @IBOutlet weak var answerButton: UIButton!
    @IBOutlet weak var answerScore: UILabel!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var actionView: UIView!
    
    //声明区
    open var section: Debate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //导航栏
        self.navigationItem.title = "辩题详情"
        self.navigationItem.backBarButtonItem = UIBarButtonItem.init(title: "", style: .plain, target: self, action: nil)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        //隐藏导航栏
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //WebView
        self.webViewLoad()
        self.emptyView.show(type: .loading(type: .indicator1), frame: CGRect.init(x: self.webView.frame.origin.x, y: self.webView.frame.origin.y, width: SW - 28, height: self.webViewContainer.frame.height))
    }
    
    deinit {
        print("deinit: \(type(of: self))")
    }
    
    //私有成员
    fileprivate var currentOffset = CGPoint.zero
    fileprivate lazy var emptyView: EmptyView = {
        let emptyView = EmptyView(target: self.webViewContainer)
        return emptyView
    }()
    fileprivate var webViewHeight: CGFloat = 0
    fileprivate var maxWebViewHeight: CGFloat = 50
    fileprivate var isFold: Bool = true
    fileprivate var maxFoldHeight: CGFloat = SH - 44 - 38 - 36
    fileprivate var disposeBag = DisposeBag()
    fileprivate var panOffset: CGFloat = 0

}

extension DebateDetailViewController {
    //初始化
    fileprivate func setupUI() {
        //Init
        debateTitle.text = self.section.title!
        //Tabbar
        self.hidesBottomBarWhenPushed = true
        //Buttons
        self.inviteButton.setImage(UIImage(icon: .fontAwesome(.userPlus), size: CGSize(width: 14, height: 14), textColor: GMColor.grey600Color(), backgroundColor: UIColor.clear), for: .normal)
        self.inviteButton.addTarget(self, action: #selector(self.gotoInvitePage), for: UIControlEvents.touchUpInside)
        self.answerButton.setImage(UIImage(icon: .fontAwesome(.edit), size: CGSize(width: 14, height: 14), textColor: GMColor.grey600Color(), backgroundColor: UIColor.clear), for: .normal)
        let answerTapGes = UITapGestureRecognizer.init(target: self, action: #selector(self.gotoAddAnswer))
        self.answerButton.addGestureRecognizer(answerTapGes)
        //ActionView 添加边框
        let topBorderLayer = CALayer()
        topBorderLayer.frame = CGRect(x: 0, y: 0, width: SW, height: 1)
        topBorderLayer.backgroundColor = GMColor.grey50Color().cgColor
        self.actionView.layer.addSublayer(topBorderLayer)
        //View Gesture
        self.view.rx
            .panGesture()
            .when(.began)
            .subscribe(onNext: { [weak self] gesture in
                self?.panOffset = gesture.location(in: self?.view).y
            })
            .disposed(by: self.disposeBag)
        self.view.rx
            .panGesture()
            .when(.changed)
            .subscribe(onNext: { [weak self] gesture in
                guard let _ = self else { return }
                
                let currentPanOffset = gesture.location(in: self!.view).y
                let scrollOffset = currentPanOffset - self!.panOffset
                self!.scrollHeader(scrollOffset)
                self!.panOffset = currentPanOffset
            })
            .disposed(by: self.disposeBag)
    }
    fileprivate func setupWebViewLayout() {
        self.webView.scrollView.isScrollEnabled = false
        if webViewHeight > maxWebViewHeight {
            self.foldView.isHidden = false
            //添加折叠事件
            let tapGes = UITapGestureRecognizer.init(target: self, action: #selector(self.foldEvent))
            self.foldView.isUserInteractionEnabled = true
            self.foldView.addGestureRecognizer(tapGes)
        } else {
            self.webViewContainerHeightC.constant = webViewHeight
        }
    }
    //滚动头部
    fileprivate func scrollHeader(_ scrollOffset: CGFloat) {
        let height = self.tableView.tableHeaderView!.frame.height
        let contentOffset = self.tableView.contentOffset.y
        let distance = contentOffset - scrollOffset
        if (scrollOffset < 0 && distance < height) || (scrollOffset >= 0 && distance >= 0) { //向下滚动 & 向上滚动
            self.tableView.setContentOffset(CGPoint.init(x: self.tableView.contentOffset.x, y: distance), animated: false)
        }
    }
    //折叠事件
    @objc fileprivate func foldEvent() {
        var offset: CGFloat = 0
        if self.isFold { //伸展
            if self.webViewHeight > maxFoldHeight {
                self.webView.scrollView.isScrollEnabled = false
                offset = maxFoldHeight - maxWebViewHeight
                self.webViewContainerHeightC.constant = self.maxFoldHeight
            } else {
                offset = webViewHeight - maxWebViewHeight
                self.webViewContainerHeightC.constant = self.webViewHeight
            }
            self.tableView.tableHeaderView!.frame.size.height += offset
            //图标更换
            self.foldIcon.image = UIImage.init(icon: .fontAwesome(.arrowUp), size: self.foldIcon.frame.size, textColor: ColorPrimary, backgroundColor: UIColor.clear)
        } else { //折叠
            self.webView.scrollView.isScrollEnabled = false
            if self.webViewHeight < maxWebViewHeight {
                offset = self.webViewContainerHeightC.constant - webViewHeight
                self.webViewContainerHeightC.constant = self.webViewHeight
            } else {
                offset = self.webViewContainerHeightC.constant - maxWebViewHeight
                self.webViewContainerHeightC.constant = self.maxWebViewHeight
            }
            self.tableView.tableHeaderView!.frame.size.height -= offset
            //图标更换
            self.foldIcon.image = UIImage.init(icon: .fontAwesome(.arrowDown), size: self.foldIcon.frame.size, textColor: ColorPrimary, backgroundColor: UIColor.clear)
        }
        //状态变更
        self.isFold = !self.isFold
        self.tableView.tableHeaderView = self.tableView.tableHeaderView!
    }
    //NavigationBarItem Action
    @objc fileprivate func goBack() {
        if (navigationController != nil) {
            navigationController?.popViewController(animated: true)
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
    //跳转到添加回答页
    @objc fileprivate func gotoAddAnswer() {
        let debateStoryBoard = UIStoryboard(name: "Debate", bundle: nil)
        let debateAnswerAddNewVC = debateStoryBoard.instantiateViewController(withIdentifier: "DebateAnswerAddNew") as! DebateAnswerAddNewViewController
        
        self.navigationController?.pushViewController(debateAnswerAddNewVC, animated: true)
    }
    //WebView Load Data
    fileprivate func webViewLoad(){
        webView.loadHTMLString(self.concatHTML(css: [], body: self.section.desc!), baseURL: nil)
    }
    //Deal With Html String
    private func concatHTML(css: [String], body: String) -> String {
        var html = "<html>"
        html += "<head>"
        css.forEach { html += "<link rel=\"stylesheet\" href=\"\($0)\">" }
        //H5 模式
        html += "<meta name='viewport' content='width=device-width, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, user-scalable=no'>"
        html += "<style>body{font-size: 11px}img{max-width:320px !important;}</style>"
        html += "</head>"
        html += "<body style='margin: 0'>"
        html += body
        html += "</body>"
        html += "</html>"
        return html
    }
    //跳转到邀请页
    @objc fileprivate func gotoInvitePage() {
        let debateStoryBoard = UIStoryboard(name: "Debate", bundle: nil)
        let debateInviteVC = debateStoryBoard.instantiateViewController(withIdentifier: "DebateInvite") as! DebateInviteViewController
        
        //隐藏 Tabbar
        self.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(debateInviteVC, animated: true)
        self.hidesBottomBarWhenPushed = false
    }
}

extension DebateDetailViewController: UITableViewDelegate, UITableViewDataSource {
    //TableView Delegate && DataSrouce
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return SH
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! DebateDetailTableViewCell
        cell.navigationController = self.navigationController!
        cell.section = self.section
        
        return cell
    }
}

extension DebateDetailViewController: WKNavigationDelegate, EmptyViewDelegate {
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
        //获取网页高度
        webView.evaluateJavaScript("document.body.scrollHeight", completionHandler: { [weak self] (result, error) in
            if error == nil {
                self?.webViewHeight = result as! CGFloat
                //布局初始化
                self?.setupWebViewLayout()
            }
        })
    }
    //页面加载失败
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        self.emptyView.hide()
    }
    
}
