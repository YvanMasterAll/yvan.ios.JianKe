//
//  MeJoinViewController.swift
//  ShuTu
//
//  Created by yiqiang on 2018/3/1.
//  Copyright © 2018年 yiqiang. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxDataSources

public enum MeJoinType: String {
    case collect
    case support
    case topic
    case viewpoint
    case followtopic
    case followperson
    case fan
}

class MeJoinViewController: BaseViewController {
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            self.tableView.register(UINib(nibName: "MeJoinCollectTableViewCell", bundle: nil), forCellReuseIdentifier: "collect")
            self.tableView.register(UINib(nibName: "MeJoinTopicTableViewCell", bundle: nil), forCellReuseIdentifier: "topic")
            self.tableView.register(UINib(nibName: "FriendTableViewCell", bundle: nil), forCellReuseIdentifier: "user")
            self.tableView.showsVerticalScrollIndicator = false
            self.tableView.tableFooterView = UIView() //消除底部视图
            self.tableView.separatorStyle = .none //消除分割线
        }
    }
    
    //MARK: - 声明区域
    open var type: MeJoinType!
    open var navTitle: String!

    override func viewDidLoad() {
        super.viewDidLoad()

        showNavbar = true
        hideNavbar = true
        navBarTitle = navTitle
        setupUI()
        bindRx()
    }
    
    override func reload() {
        self.tableView.switchRefreshHeader(to: .refreshing)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - 私有成员
    fileprivate var viewModel: MeJoinViewModel!
    fileprivate var disposeBag = DisposeBag()
    fileprivate var collectDataSource: RxTableViewSectionedReloadDataSource<MeJoinCollectSectionModel>!
    fileprivate var topicDataSource: RxTableViewSectionedReloadDataSource<MeJoinTopicSectionModel>!
    fileprivate var userDataSource: RxTableViewSectionedReloadDataSource<MeJoinUserSectionModel>!

}

extension MeJoinViewController {

    //MARK: - 初始化
    fileprivate func setupUI() {
        //PullToRefreshKit
        let secondHeader = SecondRefreshHeader()
        self.tableView.configRefreshHeader(with: secondHeader, action: { [weak self] () -> Void in
            self?.viewModel.inputs.refreshNewData.onNext((self!.type, true))
        })
        self.tableView.configRefreshFooter(with: FirstRefreshFooter(), action: { [weak self] () -> Void in
            self?.viewModel.inputs.refreshNewData.onNext((self!.type, false))
        })
        //View Model
        self.viewModel = MeJoinViewModel.init(disposeBag: self.disposeBag)
    }
    fileprivate func bindRx() {
        //Rx
        tableView.rx.setDelegate(self)
            .disposed(by: disposeBag)
        switch type {
        case .collect, .viewpoint, .support:
            collectDataSource = RxTableViewSectionedReloadDataSource<MeJoinCollectSectionModel>(
                configureCell: { ds, tv, ip, item in
                    let cell = tv.dequeueReusableCell(withIdentifier: "collect", for: ip) as! MeJoinCollectTableViewCell
                    cell.thumbnail.kf.setImage(with: URL(string: item.portrait!))
                    cell.name.text = item.nickname
                    cell.answer.text = item.pureanswer
                    cell.score.text = "\(item.supports ?? 0 ) 赞同 · \(item.comments ?? 0) 评论"
                    //计算 answer label 高度
                    cell.setupConstraint()
                    
                    return cell
            })
            viewModel.outputs.collectSections!.asDriver()
                .drive(tableView.rx.items(dataSource: collectDataSource))
                .disposed(by: disposeBag)
            self.tableView.rx
                .modelSelected(Answer.self)
                .subscribe(onNext: { data in
                    //跳转
                })
                .disposed(by: disposeBag)
        case .followtopic, .topic:
            topicDataSource = RxTableViewSectionedReloadDataSource<MeJoinTopicSectionModel>(
                configureCell: { ds, tv, ip, item in
                    let cell = tv.dequeueReusableCell(withIdentifier: "topic", for: ip) as! MeJoinTopicTableViewCell
                    cell.title.text = item.title
                    cell.score.text = "\(item.supports ?? 0)声援 \(item.opposes ?? 0)殊途"
                    
                    return cell
            })
            viewModel.outputs.topicSections!.asDriver()
                .drive(tableView.rx.items(dataSource: topicDataSource))
                .disposed(by: disposeBag)
            self.tableView.rx
                .modelSelected(Debate.self)
                .subscribe(onNext: { data in
                    //跳转
                })
                .disposed(by: disposeBag)
        case .followperson, .fan:
            userDataSource = RxTableViewSectionedReloadDataSource<MeJoinUserSectionModel>(
                configureCell: { ds, tv, ip, item in
                    let cell = tv.dequeueReusableCell(withIdentifier: "user", for: ip) as! FriendTableViewCell
                    cell.thumbnail.kf.setImage(with: URL(string: item.portrait!))
                    cell.name.text = item.nickname
                    cell.sign.text = (item.signature != nil) ? item.signature:""
                    
                    return cell
            })
            viewModel.outputs.userSections!.asDriver()
                .drive(tableView.rx.items(dataSource: userDataSource))
                .disposed(by: disposeBag)
            self.tableView.rx
                .modelSelected(User.self)
                .subscribe(onNext: { data in
                    //跳转
                })
                .disposed(by: disposeBag)
        default:
            break
        }
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
                    self.showBaseEmptyView("还没有数据")
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
}

extension MeJoinViewController: UITableViewDelegate {
    
    //MARK: - TableViewDelegate && TableViewDataSource
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //取消cell选中状态
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
