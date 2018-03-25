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

class DebateDetailViewController: BaseViewController {

    @IBOutlet weak var foldDescLabel: UILabel!
    @IBOutlet weak var titleHeightC: NSLayoutConstraint!
    @IBOutlet weak var webViewContainerHeightC: NSLayoutConstraint!
    @IBOutlet weak var webViewContainer: UIView!
    @IBOutlet weak var webView: BaseWKWebView! {
        didSet {
            //WebView
            self.webView.scrollView.showsVerticalScrollIndicator = false
            self.webView.navigationDelegate = self
        }
    }
    @IBOutlet weak var foldView: UIView! {
        didSet {
            self.foldView.backgroundColor = STColor.whiteColor().withAlphaComponent(0.8)
            self.foldView.layer.cornerRadius = 2
            self.foldView.clipsToBounds = true
        }
    }
    @IBOutlet weak var foldIcon: UIImageView! {
        didSet {
            self.foldIcon.image = UIImage.init(icon: .fontAwesome(.arrowDown), size: self.foldIcon.frame.size, textColor: ColorPrimary, backgroundColor: UIColor.clear)
        }
    }
    @IBOutlet weak var tableView: BaseTableView!
    @IBOutlet weak var debateTitle: UILabel!
    @IBOutlet weak var followButton: UIButton! {
        didSet {
            self.followButton.setImage(UIImage.init(icon: .fontAwesome(.plus), size: CGSize.init(width: 14, height: 14), textColor: STColor.whiteColor(), backgroundColor: UIColor.clear), for: .normal
            )
            self.followButton.addTarget(self, action: #selector(self.follow), for: .touchUpInside)
        }
    }
    @IBOutlet weak var score: UILabel!
    @IBOutlet weak var inviteButton: UIButton!
    @IBOutlet weak var answerButton: UIButton!
    @IBOutlet weak var answerScore: UILabel!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var actionView: UIView!
    
    //MARK: - 声明区域
    open var section: Debate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        showNavbar = true
        hideNavbar = true
        navBarTitle = "辩题详情"
        hideTabbar = true
        setupUI()
        bindRx()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: - 私有成员
    fileprivate var viewModel: DebateDetailViewModel2!
    fileprivate var disposeBag = DisposeBag()
    fileprivate var currentOffset = CGPoint.zero
    fileprivate var webViewHeight: CGFloat = 0
    fileprivate var maxWebViewHeight: CGFloat = 50
    fileprivate var isFold: Bool = true
    fileprivate var maxFoldHeight: CGFloat = SH - 44 - 38 - 36
    fileprivate var followed: Bool = false
    fileprivate var scrollDragging: Bool = false
    fileprivate var tableStatus: TableState = .headBottom
    fileprivate var canScroll: Bool = true

}

extension DebateDetailViewController {

    //MARK: - 初始化
    fileprivate func setupUI() {
        //WebView
        self.webViewLoad()
        //Init
        debateTitle.text = self.section.title!
        score.text = "\(self.section.follows ?? 0)人关注"
        answerScore.text = "\(self.section.supports ?? 0)个声援 \(self.section.opposes ?? 0)个殊途"
        //Buttons
        self.inviteButton.setImage(UIImage(icon: .fontAwesome(.userPlus), size: CGSize(width: 14, height: 14), textColor: STColor.grey600Color(), backgroundColor: UIColor.clear), for: .normal)
        self.inviteButton.addTarget(self, action: #selector(self.gotoInvitePage), for: UIControlEvents.touchUpInside)
        self.answerButton.setImage(UIImage(icon: .fontAwesome(.edit), size: CGSize(width: 14, height: 14), textColor: STColor.grey600Color(), backgroundColor: UIColor.clear), for: .normal)
        let answerTapGes = UITapGestureRecognizer.init(target: self, action: #selector(self.gotoAddAnswerCheck))
        self.answerButton.addGestureRecognizer(answerTapGes)
        //ActionView 添加边框
        let topBorderLayer = CALayer()
        topBorderLayer.frame = CGRect(x: 0, y: 0, width: SW, height: 1)
        topBorderLayer.backgroundColor = STColor.grey50Color().cgColor
        self.actionView.layer.addSublayer(topBorderLayer)
        //标题高度
        self.setupTitleLayout()
    }
    fileprivate func bindRx() {
        //SonTableStatue
        SonTableStatus.asObserver()
            .subscribe(onNext: { [weak self] state in
                switch state {
                case .canParentScroll:
                    self?.canScroll = true
                case .noParentScroll:
                    self?.canScroll = false
                default:
                    break
                }
            })
            .disposed(by: self.disposeBag)
        //View Model
        viewModel = DebateDetailViewModel2.init(disposeBag: disposeBag, section: self.section)
        viewModel.outputs.followResult
            .asObservable()
            .subscribe(onNext: { [weak self] result in
                guard let _ = self else { return }
                if self!.followed { //取消关注结果
                    switch result {
                    case .failed:
                        HUD.flash(.label("取消关注失败"))
                        break
                    case .ok:
                        self!.applyFollowButton(false)
                        ServiceUtil.userinfoPartRefresh(nil, false)
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
                        self!.applyFollowButton(true)
                        ServiceUtil.userinfoPartRefresh(nil, true)
                        break
                    case .exist:
                        self!.applyFollowButton(true)
                        break
                    default:
                        break
                    }
                }
                
            })
            .disposed(by: disposeBag)
        viewModel.outputs.followCheck
            .asObservable()
            .subscribe(onNext: { [weak self] result in
                switch result {
                case .exist:
                    self?.applyFollowButton(true)
                    break
                case .empty:
                    self?.applyFollowButton(false)
                    break
                default:
                    self?.applyFollowButton(false)
                    break
                }
            })
            .disposed(by: disposeBag)
        viewModel.outputs.answerCheck
            .asObservable()
            .subscribe(onNext: { [weak self] result in
                switch result {
                case .exist:
                    HUD.flash(.label("你已经提交过观点"))
                    break
                case .empty:
                    self?.gotoAddAnswer()
                    break
                default:
                    HUD.hide()
                    break
                }
            })
            .disposed(by: disposeBag)
        //检查关注
        self.viewModel.inputs.followCheck.onNext(())
    }
    fileprivate func setupTitleLayout() {
        let width = self.debateTitle.widthOfString
        var height: CGFloat = 0
        if width > (SW - 28) {
            height = self.debateTitle.heightOfLines(by: 2) + 1
        } else {
            height = self.debateTitle.heightOfLines(by: 1)
        }
        self.tableView.tableHeaderView!.frame.size.height += height - self.titleHeightC.constant
        self.titleHeightC.constant = height
        self.tableView.tableHeaderView = self.tableView.tableHeaderView!
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
    
    //MARK: - 按钮事件
    @objc fileprivate func follow() {
        if self.followed { //取消关注
            viewModel.inputs.followTap.onNext(false)
        } else { //关注
            viewModel.inputs.followTap.onNext(true)
        }
    }
    @objc fileprivate func goBack() {
        if (navigationController != nil) {
            navigationController?.popViewController(animated: true)
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
    @objc fileprivate func gotoAddAnswerCheck() {
        self.viewModel.inputs.answerCheck.onNext(())
    }
    fileprivate func gotoAddAnswer() {
        let debateAnswerAddNewVC = GeneralFactory.getVCfromSb("Debate", "DebateAnswerAddNew") as! DebateAnswerAddNewViewController
        debateAnswerAddNewVC.section = self.section
        
        self.navigationController?.pushViewController(debateAnswerAddNewVC, animated: true)
    }
    @objc fileprivate func gotoInvitePage() {
        let debateInviteVC =  GeneralFactory.getVCfromSb("Debate", "DebateInvite") as! DebateInviteViewController
        
        self.navigationController?.pushViewController(debateInviteVC, animated: true)
    }
    
    //MARK: - 按钮状态变更
    fileprivate func applyFollowButton(_ followed: Bool) {
        self.followed = followed
        self.followButton.isHidden = false
        if followed {
            self.followButton.setTitle("已关注问题", for: .normal)
            self.followButton.backgroundColor = ColorPrimary.darken(by: 0.2)
            self.followButton.setImage(nil, for: .normal)
        } else {
            self.followButton.setTitle("关注问题", for: .normal)
            self.followButton.backgroundColor = ColorPrimary
            self.followButton.setImage(UIImage.init(icon: .fontAwesome(.plus), size: CGSize.init(width: 14, height: 14), textColor: UIColor.white, backgroundColor: UIColor.clear), for: .normal)
        }
    }
    
    //MARK: - 折叠事件
    @objc fileprivate func foldEvent() {
        var offset: CGFloat = 0
        if self.isFold { //伸展
            if self.webViewHeight > maxFoldHeight {
                self.webView.scrollView.isScrollEnabled = true
                offset = maxFoldHeight - maxWebViewHeight
                self.webViewContainerHeightC.constant = self.maxFoldHeight
            } else {
                offset = webViewHeight - maxWebViewHeight
                self.webViewContainerHeightC.constant = self.webViewHeight
            }
            self.tableView.tableHeaderView!.frame.size.height += offset
            //图标更换
            self.foldIcon.image = UIImage.init(icon: .fontAwesome(.arrowUp), size: self.foldIcon.frame.size, textColor: ColorPrimary, backgroundColor: UIColor.clear)
            self.foldDescLabel.text = "收起详情"
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
            self.foldDescLabel.text = "展开详情"
        }
        //状态变更
        self.isFold = !self.isFold
        self.tableView.tableHeaderView = self.tableView.tableHeaderView!
    }
    
    //MARK: - 加载内容
    fileprivate func webViewLoad(){
        webView.loadHTMLString(self.section.description!, baseURL: nil)
    }
}

extension DebateDetailViewController: UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate {
    
    //MARK: - TableView Delegate && DataSrouce
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return SH
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //取消cell选中状态
        tableView.deselectRow(at: indexPath, animated: true)
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! DebateDetailTableViewCell
        cell.navigationController = self.navigationController!
        cell.section = self.section
        cell.selectionStyle = .none
        
        return cell
    }
    
    //MARK: - ScrollView Delegate
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.scrollDragging = true
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if self.scrollDragging {
            if self.canScroll {
                let height = self.tableView.tableHeaderView!.frame.height
                let scrollOffset = scrollView.contentOffset.y
                if Int(scrollOffset) >= Int(height) {
                    self.tableView.contentOffset.y = height
                    TableStatus.onNext(.headTop)
                    tableStatus = .headTop
                } else if scrollOffset <= 0 {
                    //self.tableView.contentOffset.y = 0
                    tableStatus = .headBottom
                    TableStatus.onNext(.headBottom)
                } else {
                    TableStatus.onNext(.headMid)
                }
            } else {
                let height = self.tableView.tableHeaderView!.frame.height
                switch tableStatus {
                case .headBottom:
                    self.canScroll = true
                    self.tableView.contentOffset.y = 0
                case .headTop:
                    self.tableView.contentOffset.y = height
                default:
                    break
                }
            }
        }
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.scrollDragging = false
    }
}

extension DebateDetailViewController: WKNavigationDelegate {
    
    //MARK: - WKNavigationDelegate
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) { //页面开始加载
        self.webView.showBaseEmptyView()
    }
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) { //内容开始返回
        
    }
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) { //页面加载完
        self.webView.hideEmptyView()
        //获取网页高度
        webView.evaluateJavaScript("document.body.scrollHeight", completionHandler: { [weak self] (result, error) in
            if error == nil {
                self?.webViewHeight = result as! CGFloat
                //布局初始化
                self?.setupWebViewLayout()
            }
        })
    }
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) { //页面加载失败
        self.webView.hideEmptyView()
    }
    
}
