//
//  MeSpaceDynamicCollectionViewCell.swift
//  ShuTu
//
//  Created by yiqiang on 2018/1/10.
//  Copyright © 2018年 yiqiang. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxDataSources

public enum DynamicType: String {
    case dynamic
    case viewpoint
    case topic
}

class MeSpaceDynamicCollectionViewCell: FSPagerViewCell {

    @IBOutlet weak var tableView: UITableView! {
        didSet {
            switch self.dynamicT {
            case .dynamic:
                self.tableView.register(UINib(nibName: "MeSpaceDynamicTableViewCell", bundle: nil), forCellReuseIdentifier: "dynamic")
            case .viewpoint:
                self.tableView.register(UINib(nibName: "MeSpaceDynamicTableViewCell", bundle: nil), forCellReuseIdentifier: "answer")
            case .topic:
                self.tableView.register(UINib(nibName: "MeSpaceDynamicTableViewCell", bundle: nil), forCellReuseIdentifier: "topic")
            }
            self.tableView.showsVerticalScrollIndicator = false
            self.tableView.tableFooterView = UIView() //消除底部视图
            self.tableView.separatorStyle = .none //消除分割线
        }
    }
    
    //声明区
    open var navigationController: UINavigationController!
    open var disposeBag: DisposeBag!
    open var dynamicViewModel: MeSpaceDynamicViewModel! {
        didSet {
            self.bindRx()
        }
    }
    open var answerViewModel: MeSpaceAnswerViewModel! {
        didSet {
            self.bindRx()
        }
    }
    open var topicViewModel: MeSpaceTopicViewModel! {
        didSet {
            self.bindRx()
        }
    }
    open var dynamicT: DynamicType = .dynamic
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupUI()
    }
    
    //私有成员
    fileprivate var dynamicDataSource: RxTableViewSectionedReloadDataSource<MeSpaceDynamicSectionModel>!
    fileprivate var answerDataSource: RxTableViewSectionedReloadDataSource<MeSpaceAnswerSectionModel>!
    fileprivate var topicDataSource: RxTableViewSectionedReloadDataSource<MeSpaceTopicSectionModel>!
    fileprivate var emptyView: EmptyView!
    fileprivate var scrollOffset: CGFloat = 0

}

extension MeSpaceDynamicCollectionViewCell {
    //初始化
    fileprivate func setupUI() {
        //EmptyView
        self.emptyView = EmptyView(target: self)
        self.emptyView.delegate = self
        //PullToRefreshKit
        let secondHeader = SecondRefreshHeader()
        self.tableView.configRefreshHeader(with: secondHeader, action: { [unowned self] () -> Void in
            switch self.dynamicT {
            case .dynamic:
                self.dynamicViewModel.inputs.refreshNewData.onNext(true)
            case .viewpoint:
                self.answerViewModel.inputs.refreshNewData.onNext(true)
            case .topic:
                self.topicViewModel.inputs.refreshNewData.onNext(true)
            }
            
        })
        self.tableView.configRefreshFooter(with: FirstRefreshFooter(), action: { [unowned self] () -> Void in
            switch self.dynamicT {
            case .dynamic:
                self.dynamicViewModel.inputs.refreshNewData.onNext(false)
            case .viewpoint:
                self.answerViewModel.inputs.refreshNewData.onNext(false)
            case .topic:
                self.topicViewModel.inputs.refreshNewData.onNext(false)
            }
        })
    }
    fileprivate func bindRx() {
        //Rx
        tableView.rx.setDelegate(self)
            .disposed(by: disposeBag)
        switch self.dynamicT {
        case .dynamic:
            dynamicDataSource = RxTableViewSectionedReloadDataSource<MeSpaceDynamicSectionModel>(
                configureCell: { ds, tv, ip, item in
                    let cell = tv.dequeueReusableCell(withIdentifier: "dynamic", for: ip) as! MeSpaceDynamicTableViewCell
                    cell.thumbnail.kf.setImage(with: URL(string: item.portrait!))
                    if let type = item.category {
                        switch type {
                        case TrendType.new_topic.rawValue:
                            cell.label1.text = "你发起了新的话题"
                        case TrendType.new_answer.rawValue:
                            cell.label1.text = "你发表了新的观点"
                        default:
                            break
                        }
                    }
                    cell.title.text = item.title
                    
                    return cell
            })
            dynamicViewModel.outputs.sections!.asDriver()
                .drive(tableView.rx.items(dataSource: dynamicDataSource))
                .disposed(by: disposeBag)
            self.tableView.rx
                .modelSelected(Debate.self)
                .subscribe(onNext: { data in
                    //跳转
                })
                .disposed(by: disposeBag)
            self.dynamicViewModel.outputs.refreshStateObserver.asObservable()
                .subscribe(onNext: { [weak self] state in
                    switch state {
                    case .noData:
                        self?.tableView.switchRefreshHeader(to: .normal(.none, 0))
                        self?.showEmptyView(type: .empty(size: nil))
                        break
                    case .beginHeaderRefresh:
                        break
                    case .endHeaderRefresh:
                        self?.tableView.switchRefreshHeader(to: .normal(.success, 0))
                        break
                    case .beginFooterRefresh:
                        break
                    case .endFooterRefresh:
                        self?.tableView.switchRefreshFooter(to: .normal)
                        break
                    case .endRefreshWithoutData:
                        self?.tableView.switchRefreshFooter(to: .noMoreData)
                        break
                    default:
                        break
                    }
                })
                .disposed(by: disposeBag)
        case .viewpoint:
            answerDataSource = RxTableViewSectionedReloadDataSource<MeSpaceAnswerSectionModel>(
                configureCell: { ds, tv, ip, item in
                    let cell = tv.dequeueReusableCell(withIdentifier: "answer", for: ip) as! MeSpaceDynamicTableViewCell
                    
                    return cell
            })
            answerViewModel.outputs.sections!.asDriver()
                .drive(tableView.rx.items(dataSource: answerDataSource))
                .disposed(by: disposeBag)
            self.tableView.rx
                .modelSelected(Debate.self)
                .subscribe(onNext: { data in
                    //跳转
                })
                .disposed(by: disposeBag)
            self.answerViewModel.outputs.refreshStateObserver.asObservable()
                .subscribe(onNext: { [weak self] state in
                    switch state {
                    case .noData:
                        self?.tableView.switchRefreshHeader(to: .normal(.none, 0))
                        self?.showEmptyView(type: .empty(size: nil))
                        break
                    case .beginHeaderRefresh:
                        break
                    case .endHeaderRefresh:
                        self?.tableView.switchRefreshHeader(to: .normal(.success, 0))
                        break
                    case .beginFooterRefresh:
                        break
                    case .endFooterRefresh:
                        self?.tableView.switchRefreshFooter(to: .normal)
                        break
                    case .endRefreshWithoutData:
                        self?.tableView.switchRefreshFooter(to: .noMoreData)
                        break
                    default:
                        break
                    }
                })
                .disposed(by: disposeBag)
        case .topic:
            topicDataSource = RxTableViewSectionedReloadDataSource<MeSpaceTopicSectionModel>(
                configureCell: { ds, tv, ip, item in
                    let cell = tv.dequeueReusableCell(withIdentifier: "topic", for: ip) as! MeSpaceDynamicTableViewCell
                    
                    return cell
            })
            topicViewModel.outputs.sections!.asDriver()
                .drive(tableView.rx.items(dataSource: topicDataSource))
                .disposed(by: disposeBag)
            self.tableView.rx
                .modelSelected(Debate.self)
                .subscribe(onNext: { data in
                    //跳转
                })
                .disposed(by: disposeBag)
            self.topicViewModel.outputs.refreshStateObserver.asObservable()
                .subscribe(onNext: { [weak self] state in
                    switch state {
                    case .noData:
                        self?.tableView.switchRefreshHeader(to: .normal(.none, 0))
                        self?.showEmptyView(type: .empty(size: nil))
                        break
                    case .beginHeaderRefresh:
                        break
                    case .endHeaderRefresh:
                        self?.tableView.switchRefreshHeader(to: .normal(.success, 0))
                        break
                    case .beginFooterRefresh:
                        break
                    case .endFooterRefresh:
                        self?.tableView.switchRefreshFooter(to: .normal)
                        break
                    case .endRefreshWithoutData:
                        self?.tableView.switchRefreshFooter(to: .noMoreData)
                        break
                    default:
                        break
                    }
                })
                .disposed(by: disposeBag)
        }
        //刷新
        self.tableView.switchRefreshHeader(to: .refreshing)
    }
    //显示 & 隐藏 Empty Zone
    fileprivate func showEmptyView(type: EmptyViewType) {
        tableView.isHidden = true
        self.emptyView.show(type: type, frame: self.tableView.frame)
    }
    fileprivate func hideEmptyView() {
        self.emptyView.hide()
        tableView.isHidden = false
        self.tableView.switchRefreshHeader(to: .refreshing)
    }
}

extension MeSpaceDynamicCollectionViewCell: UITableViewDelegate, EmptyViewDelegate {
    //TableViewDelegate && TableViewDataSource
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //取消cell选中状态
        tableView.deselectRow(at: indexPath, animated: true)
    }
    //EmptyView Delegate
    func emptyViewClicked() {
        self.hideEmptyView()
    }
}
