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
    
    @IBOutlet weak var webView: WKWebView! {
        didSet {
            //WebView
            self.webView.scrollView.showsVerticalScrollIndicator = false
            self.webView.navigationDelegate = self
        }
    }
    
    //声明区域
    open var section: Debate! {
        didSet {
            self.setupUI()
        }
    }
    open var viewModel: DailyDebateDetailViewModel! {
        didSet {
            //self.bindRx()
        }
    }
    open var disposeBag: DisposeBag!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    //私有成员
    fileprivate lazy var emptyView: EmptyView = {
        let emptyView = EmptyView(target: self)
        emptyView.delegate = self
        return emptyView
    }()

}

extension DailyDebateDetailTableViewCell {
    //初始化
    fileprivate func setupUI() {
        //加载描述
        self.webViewLoad(data: section.description!)
    }
    fileprivate func bindRx() {
        //Rx
        viewModel.outputs.emptyStateObserver.asObservable()
            .subscribe(onNext: { [weak self] state in
                switch state {
                case .loading(let type):
                    guard let _ = self else { return }
                    self!.emptyView.show(type: .loading(type: type), frame: CGRect(x: self!.webView.frame.origin.x, y: self!.webView.frame.origin.y, width: SW, height: SH - 280 - 34))
                    break
                case .empty:
                    self?.emptyView.hide()
                default:
                    break
                }
            })
            .disposed(by: disposeBag)
        //首次加载
        viewModel.inputs.refreshData.onNext(())
    }
    //WebView Load Data
    fileprivate func webViewLoad(data: String){
        webView.loadHTMLString(data, baseURL: nil)
        self.emptyView.show(type: .loading(type: .indicator1), frame: CGRect(x: self.webView.frame.origin.x, y: self.webView.frame.origin.y, width: SW, height: SH - 280 - 34))
    }
}

extension DailyDebateDetailTableViewCell: WKNavigationDelegate, EmptyViewDelegate {
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
        self.emptyView.hide()
    }
    //EmptyViewDelegate
    func emptyViewClicked() {
        //重新加载
        viewModel.inputs.refreshData.onNext(())
    }
}
