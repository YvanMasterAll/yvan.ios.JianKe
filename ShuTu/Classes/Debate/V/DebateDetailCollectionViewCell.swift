//
//  DebateDetailCollectionViewCell.swift
//  ShuTu
//
//  Created by yiqiang on 2017/12/23.
//  Copyright © 2017年 yiqiang. All rights reserved.
//

import UIKit
import RxDataSources
import RxCocoa
import RxSwift

class DebateDetailCollectionViewCell: FSPagerViewCell {

    @IBOutlet weak var tableView: UITableView! {
        didSet {
            self.tableView.register(UINib(nibName: "DebateDetailAnswerTableViewCell", bundle: nil), forCellReuseIdentifier: "answerCell")
            self.tableView.showsVerticalScrollIndicator = false
        }
    }
    
    //声明区
    public var side: AnswerSide!
    public var viewModel: DebateDetailViewModel! {
        didSet {
            self.bindRx()
        }
    }
    public var section: Debate!
    //私有成员
    fileprivate var disposeBag = DisposeBag()
    fileprivate var dataSource: RxTableViewSectionedReloadDataSource<DebateDetailSectionModel>!
    fileprivate var emptyView: EmptyView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupUI()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}

extension DebateDetailCollectionViewCell {
    //初始化
    fileprivate func setupUI() {
        //EmptyView
        self.emptyView = EmptyView(target: self)
        self.emptyView.delegate = self
        //TableView
        self.tableView.tableFooterView = UIView() //消除底部视图
        self.tableView.separatorStyle = .none //消除分割线
        //PullToRefreshKit
        let firstHeader = FirstRefreshHeader()
        self.tableView.configRefreshHeader(with: firstHeader, action: {
            switch self.side {
            case .SY:
                self.viewModel.inputsY.refreshNewData.onNext(true)
            case .ST:
                self.viewModel.inputsS.refreshNewData.onNext(true)
            default:
                break
            }
        })
        self.tableView.configRefreshFooter(with: FirstRefreshFooter(), action: {
            switch self.side {
            case .SY:
                self.viewModel.inputsY.refreshNewData.onNext(false)
            case .ST:
                self.viewModel.inputsS.refreshNewData.onNext(false)
            default:
                break
            }
        })
    }
    //绑定 Rx
    fileprivate func bindRx() {
        //Delegate
        tableView.rx.setDelegate(self)
            .disposed(by: disposeBag)
        dataSource = RxTableViewSectionedReloadDataSource<DebateDetailSectionModel>(
            configureCell: { ds, tv, ip, item in
                let cell = tv.dequeueReusableCell(withIdentifier: "answerCell", for: ip) as! DebateDetailAnswerTableViewCell
                //                    cell.title.text = item.title
                //                    cell.desc.text = item.desc
                //                    cell.thumbnail.kf.setImage(with: URL(string: item.thumbnail!))
                //                    cell.score.text = "\(item.yc ?? 0) 声援 · \(item.sc ?? 0) 殊途 · "
                //                    //计算 desc label 高度
                //                    cell.setupConstraint()
                return cell
            }
        )
        //Side
        switch self.side {
        case .SY:
            self.viewModel.initAnswerY(answer: (disposeBag: self.disposeBag, tableView: self.tableView, emptyView: emptyView))
            self.viewModel.outputsY.sections!.asDriver()
                .drive(tableView.rx.items(dataSource: dataSource))
                .disposed(by: disposeBag)
            self.viewModel.outputsY.emptyStateObserver.asObservable()
                .subscribe(onNext: { state in
                    switch state {
                    case .empty:
                        self.showEmptyView(type: .empty)
                        break
                    default:
                        break
                    }
                })
                .disposed(by: disposeBag)
            break
        case .ST:
            self.viewModel.initAnswerS(answer: (disposeBag: self.disposeBag, tableView: self.tableView, emptyView: emptyView))
            self.viewModel.outputsS.sections!.asDriver()
                .drive(tableView.rx.items(dataSource: dataSource))
                .disposed(by: disposeBag)
            self.viewModel.outputsS.emptyStateObserver.asObservable()
                .subscribe(onNext: { state in
                    switch state {
                    case .empty:
                        self.showEmptyView(type: .empty)
                        break
                    default:
                        break
                    }
                })
                .disposed(by: disposeBag)
            break
        default:
            break
        }
        //刷新
        self.tableView.switchRefreshHeader(to: .refreshing)
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

extension DebateDetailCollectionViewCell: UITableViewDelegate, EmptyViewDelegate {
    //TableViewDelegate && TableViewDataSource
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        //取消cell选中状态
        tableView.deselectRow(at: indexPath, animated: true)
    }
    //EmptyView Delegate
    func emptyViewClicked() {
        self.hideEmptyView()
    }
    
}

