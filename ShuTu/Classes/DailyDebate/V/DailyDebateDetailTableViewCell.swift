//
//  DailyDebateDetailTableViewCell.swift
//  ShuTu
//
//  Created by yiqiang on 2018/1/11.
//  Copyright © 2018年 yiqiang. All rights reserved.
//

import UIKit
import WebKit
import RxCocoa
import RxSwift

class DailyDebateDetailTableViewCell: UITableViewCell {
    
    @IBOutlet weak var webView: BaseWKWebView! {
        didSet {
            //WebView
            self.webView.scrollView.showsVerticalScrollIndicator = false
            self.webView.scrollView.showsHorizontalScrollIndicator = false
            self.webView.navigationDelegate = self
            self.webView.scrollView.delegate = self
        }
    }
    
    //MARK: - 声明区域
    open var section: Debate! {
        didSet {
            self.setupUI()
        }
    }
    open var viewModel: DailyDebateDetailViewModel! {
        didSet {
            self.bindRx()
        }
    }
    open var disposeBag: DisposeBag!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    //MARK: - 私有成员
    fileprivate var scrollDragging: Bool = false
    fileprivate var parentTableStatus: TableState = .headBottom
    fileprivate var contentOffset: CGPoint!

}

extension DailyDebateDetailTableViewCell {

    //MARK: - 初始化
    fileprivate func setupUI() {
        //加载描述
        self.webViewLoad(data: section.description!)
    }
    fileprivate func bindRx() {
        //TableStatus
        TableStatus.asObserver()
            .subscribe(onNext: { [weak self] state in
                self?.parentTableStatus = state
            })
            .disposed(by: self.disposeBag)
        //首次加载
        viewModel.inputs.refreshData.onNext(())
    }
    
    /// 加载内容
    fileprivate func webViewLoad(data: String){
        webView.loadHTMLString(ServiceUtil.updateHtmlStyle(data, 20, 13), baseURL: nil)
    }
}

extension DailyDebateDetailTableViewCell: WKNavigationDelegate, UIScrollViewDelegate {
    
    //MARK: - WKNavigationDelegate
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) { //页面开始加载
        self.webView.showBaseEmptyView()
    }
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) { //内容开始返回
        
    }
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) { //页面加载完
        self.webView.hideEmptyView()
    }
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) { //页面加载失败
        self.webView.hideEmptyView()
    }
    
    //MARK: - ScrollView Delegate
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.scrollDragging = true
        self.contentOffset = scrollView.contentOffset
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if self.scrollDragging {
            let direction = self.contentOffset.y - scrollView.contentOffset.y
            switch self.parentTableStatus {
            case .headTop:
                if direction > 0 && scrollView.contentOffset.y <= 0 {
                    self.webView.scrollView.contentOffset.y = 0
                    SonTableStatus.onNext(.canParentScroll)
                } else {
                    SonTableStatus.onNext(.noParentScroll)
                }
                break
            case .headBottom:
                if direction < 0 && scrollView.contentOffset.y > 0 {
                    self.webView.scrollView.contentOffset.y = 0
                    SonTableStatus.onNext(.canParentScroll)
                } else {
                    SonTableStatus.onNext(.noParentScroll)
                }
                break
            case .headMid:
                self.webView.scrollView.contentOffset.y = 0
                SonTableStatus.onNext(.canParentScroll)
                break
            default:
                break
            }
        }
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.scrollDragging = false
    }
}
