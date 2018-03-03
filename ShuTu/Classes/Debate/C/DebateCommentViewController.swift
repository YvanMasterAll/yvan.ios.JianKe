//
//  DebateCommentViewController.swift
//  ShuTu
//
//  Created by yiqiang on 2017/12/28.
//  Copyright © 2017年 yiqiang. All rights reserved.
//

import UIKit
import PMSuperButton
import RxCocoa
import RxSwift
import RxDataSources

class DebateCommentViewController: BaseViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var SlackTextView: UIView!
    @IBOutlet weak var textView: GrowingTextView!
    @IBOutlet weak var sendButton: PMSuperButton! {
        didSet {
            self.sendButton.addTarget(self, action: #selector(self.send), for: .touchUpInside)
        }
    }
    
    //声明区
    public var section: Answer!
    
    //私有成员
    fileprivate var viewModel: DebateCommentViewModel!
    fileprivate lazy var emptyView: EmptyView = {
        let emptyView = EmptyView.init(target: self.view)
        emptyView.delegate = self
        return emptyView
    }()
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}

extension DebateCommentViewController {
    //初始化
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
        self.viewModel = DebateCommentViewModel.init(disposeBag: self.disposeBag, section: self.section, tableView: self.tableView)
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
        viewModel.outputs.emptyStateObserver.asObservable()
            .subscribe(onNext: { [unowned self] state in
                switch state {
                case .empty:
                    self.showEmptyView(type: .empty(size: nil))
                default:
                    break
                }
            })
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
        //刷新
        self.tableView.switchRefreshHeader(to: .refreshing)
    }
    //NavigationBarItem Action
    @objc fileprivate func goBack() {
        if (navigationController != nil) {
            navigationController?.popViewController(animated: true)
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
    //按钮事件
    @objc fileprivate func send() {
        guard let content = self.textView.text else {
           return
        }
        self.viewModel.inputs.sendTap.onNext(content)
    }
    //显示 & 隐藏 Empty Zone
    fileprivate func showEmptyView(type: EmptyViewType) {
        self.tableView.switchRefreshHeader(to: .normal(.none, 0))
        tableView.isHidden = true
        self.emptyView.show(type: type, frame: self.tableView.frame)
    }
    fileprivate func hideEmptyView() {
        self.emptyView.hide()
        tableView.isHidden = false
        self.tableView.switchRefreshHeader(to: .refreshing)
    }
}

extension DebateCommentViewController: GrowingTextViewDelegate, UITableViewDelegate {
    //GrowingTextViewDelegate
    func textViewDidChangeHeight(_ textView: GrowingTextView, height: CGFloat) {
        //TextView 高度改变
    }
    //TableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    //EmptyViewDelegate
    override func emptyViewClicked() {
        self.hideEmptyView()
    }
}
