//
//  DebateCommentViewController.swift
//  ShuTu
//
//  Created by yiqiang on 2017/12/28.
//  Copyright © 2017年 yiqiang. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxDataSources

class DebateCommentViewController: BaseViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var SlackTextView: UIView!
    @IBOutlet weak var textView: STGrowingTextView!
    @IBOutlet weak var sendButton: STButton! {
        didSet {
            self.sendButton.addTarget(self, action: #selector(self.send), for: .touchUpInside)
        }
    }
    
    //MARK: - 声明区域
    public var section: Answer!
    
    //MARK: - 私有成员
    fileprivate var viewModel: DebateCommentViewModel!
    fileprivate var disposeBag = DisposeBag()
    fileprivate var dataSource: RxTableViewSectionedReloadDataSource<CommentSectionModel>!

    override func viewDidLoad() {
        super.viewDidLoad()

        showNavbar = true
        hideNavbar = true
        navBarTitle = "评论"
        self.setupUI()
        self.bindRx()
    }
    
    override func reload() {
        self.tableView.switchRefreshHeader(to: .refreshing)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}

extension DebateCommentViewController {

    //MARK: - 初始化
    fileprivate func setupUI() {
        //SlackTextView
        self.textView.layer.cornerRadius = 4
        self.textView.delegate = self
        //TableView
        self.tableView.tableFooterView = UIView() //消除底部视图
        self.tableView.separatorStyle = .none //消除分割线
        self.tableView.showsVerticalScrollIndicator = false
        self.tableView.showsVerticalScrollIndicator = false
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
        self.viewModel = DebateCommentViewModel.init(disposeBag: self.disposeBag, section: self.section)
        //Rx
        tableView.rx.setDelegate(self)
            .disposed(by: disposeBag)
        dataSource = RxTableViewSectionedReloadDataSource<CommentSectionModel>(
            configureCell: { [weak self] ds, tv, ip, item in
                let cell = tv.dequeueReusableCell(withIdentifier: "cell", for: ip) as! DebateCommentTableViewCell
                if item.supported > 0 {
                    cell.supported = true
                }
                cell.selectionStyle = .none
                cell.thumbnail.kf.setImage(with: URL(string: item.portrait!))
                cell.name.text = item.nickname
                cell.comment.text = item.commment
                cell.date.text = item.createtime
                cell.zan.text = "\(item.supports ?? 0)"
                cell.dialogButton.isHidden = true
                if item.replyed > 0 {
                    cell.dialogButton.isHidden = false
                }
                cell.disposeBag = self?.disposeBag
                cell.id = item.id!
                if cell.viewModel == nil {
                    cell.viewModel = self?.viewModel
                }
                //计算 label 高度
                cell.setupConstraint()
                return cell
            }
        )
        self.tableView.rx
            .modelSelected(AnswerComment.self)
            .subscribe(onNext: { [unowned self] data in
                //跳转
                let debateAnswerCommentVC = GeneralFactory.getVCfromSb("Debate", "DebateComment2") as! DebateComment2ViewController
                debateAnswerCommentVC.section = data
                self.navigationController?.pushViewController(debateAnswerCommentVC, animated: true)
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
    @objc fileprivate func goBack() {
        if (navigationController != nil) {
            navigationController?.popViewController(animated: true)
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
}

extension DebateCommentViewController: STGrowingTextViewDelegate, UITableViewDelegate {
    
    //MARK: - STGrowingTextViewDelegate
    func textViewDidChangeHeight(_ textView: STGrowingTextView, height: CGFloat) {
        //TextView 高度改变
    }
    
    //MARK: - TableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
