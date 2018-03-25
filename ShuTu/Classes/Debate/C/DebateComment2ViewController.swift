//
//  DebateComment2ViewController.swift
//  ShuTu
//
//  Created by yiqiang on 2018/2/28.
//  Copyright © 2018年 yiqiang. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxDataSources

class DebateComment2ViewController: BaseViewController {

    @IBOutlet weak var SlackTextView: UIView!
    @IBOutlet weak var textView: STGrowingTextView!
    @IBOutlet weak var sendButton: STButton! {
        didSet {
            self.sendButton.addTarget(self, action: #selector(self.send), for: .touchUpInside)
        }
    }
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            self.tableView.tableFooterView = UIView() //消除底部视图
            self.tableView.separatorStyle = .none //消除分割线
            self.tableView.showsVerticalScrollIndicator = false
            self.tableView.showsVerticalScrollIndicator = false
        }
    }
    
    //MARK: - 声明区域
    public var section: AnswerComment!
    
    //MARK: - 私有成员
    fileprivate var viewModel: DebateComment2ViewModel!
    fileprivate var disposeBag = DisposeBag()
    fileprivate var dataSource: RxTableViewSectionedReloadDataSource<Comment2SectionModel>!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        showNavbar = true
        hideNavbar = false
        navBarTitle = "回复评论"
        setupUI()
        bindRx()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func reload() {
        self.tableView.switchRefreshHeader(to: .refreshing)
    }

}

extension DebateComment2ViewController {

    //MARK: - 初始化
    fileprivate func setupUI() {
        //SlackText
        self.textView.layer.cornerRadius = 4
        self.textView.delegate = self
        //PullToRefreshKit
        let secondHeader = SecondRefreshHeader()
        self.tableView.configRefreshHeader(with: secondHeader, action: { [weak self] () -> Void in
            self?.viewModel.inputs.refreshNewData.onNext(true)
        })
        self.tableView.configRefreshFooter(with: FirstRefreshFooter(), action: { [weak self] () -> Void in
            self?.viewModel.inputs.refreshNewData.onNext(false)
        })
    }
    fileprivate func bindRx() {
        //View Model
        self.viewModel = DebateComment2ViewModel.init(disposeBag: self.disposeBag, section: self.section)
        //Rx
        tableView.rx.setDelegate(self)
            .disposed(by: disposeBag)
        dataSource = RxTableViewSectionedReloadDataSource<Comment2SectionModel>(
            configureCell: { ds, tv, ip, item in
                let cell = tv.dequeueReusableCell(withIdentifier: "cell2", for: ip) as! DebateComment2TableViewCell
                cell.selectionStyle = .none
                cell.thumbnail.kf.setImage(with: URL(string: item.portrait!))
                cell.name.text = item.nickname
                cell.comment.text = item.commment
                cell.date.text = item.createtime
                return cell
            }
        )
        self.tableView.rx
            .modelSelected(AnswerComment.self)
            .subscribe(onNext: { data in
                //跳转
            })
            .disposed(by: disposeBag)
        viewModel.outputs.sections!.asDriver()
            .drive(tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        viewModel.outputs.sendResult.asObservable()
            .subscribe(onNext: { result in
                switch result {
                case .ok:
                    HUD.flash(.label("发送成功"))
                case .failed:
                    HUD.flash(.label("发送失败"))
                default:
                    break
                }
            })
            .disposed(by: disposeBag)
        self.viewModel.outputs.refreshStateObserver.asObservable()
            .subscribe(onNext: { [unowned self] state in
                switch state {
                case .noNet:
                    self.tableView.switchRefreshHeader(to: .normal(.none, 0))
                    if self.hasRequested {
                        HUD.flash(.label("网络走失了"))
                    } else {
                        self.showBaseEmptyView()
                    }
                    break
                case .noData:
                    self.tableView.switchRefreshHeader(to: .normal(.none, 0))
                    self.tableView.switchRefreshFooter(to: FooterRefresherState.removed)
                    self.showBaseEmptyView("还没有数据", self.SlackTextView.height)
                    break
                case .beginHeaderRefresh:
                    break
                case .endHeaderRefresh:
                    self.hasRequested = true
                    self.tableView.switchRefreshHeader(to: .normal(.success, 0))
                    break
                case .beginFooterRefresh:
                    break
                case .endFooterRefresh:
                    self.tableView.switchRefreshFooter(to: .normal)
                    break
                case .endRefreshWithoutData:
                    self.tableView.switchRefreshFooter(to: .noMoreData)
                    break
                default:
                    break
                }
            })
            .disposed(by: disposeBag)
        //刷新
        self.tableView.switchRefreshHeader(to: .refreshing)
    }
    
    //MARK: - 按钮事件
    @objc fileprivate func send() {
        guard let content = self.textView.text else {
            return
        }
        self.viewModel.inputs.sendTap.onNext(content)
    }
}

extension DebateComment2ViewController: STGrowingTextViewDelegate, UITableViewDelegate {
    
    //MARK: - TableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
