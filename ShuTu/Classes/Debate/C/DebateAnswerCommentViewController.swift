//
//  DebateAnswerCommentViewController.swift
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

class DebateAnswerCommentViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var SlackTextView: UIView!
    @IBOutlet weak var textView: GrowingTextView!
    @IBOutlet weak var sendButton: PMSuperButton!
    
    //声明区
    public var section: Answer!
    
    //私有成员
    fileprivate var viewModel: DebateAnswerCommentViewModel!
    fileprivate lazy var emptyView: EmptyView = {
        let emptyView = EmptyView.init(target: self.view)
        emptyView.delegate = self
        return emptyView
    }()
    fileprivate var disposeBag = DisposeBag()
    fileprivate var dataSource: RxTableViewSectionedReloadDataSource<AnswerCommentSectionModel>!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupUI()
        self.bindRx()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
        self.navigationItem.title = "评论"
        self.navigationItem.backBarButtonItem = UIBarButtonItem.init(title: "", style: .plain, target: self, action: nil)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
//        //添加 SlackTextView 的阴影
//        GeneralFactory.generateRectShadow(layer: self.SlackTextView.layer, rect: CGRect(x: 0, y: -1, width: SW, height: 1), color: GMColor.grey800Color().cgColor)
//        self.view.bringSubview(toFront: self.SlackTextView)
    }
    
}

extension DebateAnswerCommentViewController {
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
        self.viewModel = DebateAnswerCommentViewModel.init(disposeBag: self.disposeBag, section: self.section, tableView: self.tableView)
        //Rx
        tableView.rx.setDelegate(self)
            .disposed(by: disposeBag)
        dataSource = RxTableViewSectionedReloadDataSource<AnswerCommentSectionModel>(
            configureCell: { ds, tv, ip, item in
                let cell = tv.dequeueReusableCell(withIdentifier: "cell", for: ip) as! DebateAnswerCommentTableViewCell
                cell.selectionStyle = .none
                cell.thumbnail.kf.setImage(with: URL(string: item.thumbnail!))
                cell.name.text = item.username
                cell.comment.text = item.commment
                cell.date.text = item.date
                cell.zan.text = "\(item.zan ?? 0)"
                cell.dialogButton.isHidden = !item.hasTalk!
                //计算 label 高度
                cell.setupConstraint()
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
        viewModel.outputs.emptyStateObserver.asObservable()
            .subscribe(onNext: { [unowned self] state in
                switch state {
                case .empty:
                    self.showEmptyView(type: .empty)
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

extension DebateAnswerCommentViewController: GrowingTextViewDelegate, UITableViewDelegate, EmptyViewDelegate {
    //GrowingTextViewDelegate
    func textViewDidChangeHeight(_ textView: GrowingTextView, height: CGFloat) {
        //TextView 高度改变
    }
    //TableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    //EmptyViewDelegate
    func emptyViewClicked() {
        self.hideEmptyView()
    }
}
