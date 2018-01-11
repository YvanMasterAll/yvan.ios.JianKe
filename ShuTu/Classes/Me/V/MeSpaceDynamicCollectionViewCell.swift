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

class MeSpaceDynamicCollectionViewCell: FSPagerViewCell {

    @IBOutlet weak var tableView: UITableView! {
        didSet {
            self.tableView.register(UINib(nibName: "MeSpaceDynamicTableViewCell", bundle: nil), forCellReuseIdentifier: "dynamic")
            self.tableView.showsVerticalScrollIndicator = false
            self.tableView.tableFooterView = UIView() //消除底部视图
            self.tableView.separatorStyle = .none //消除分割线
        }
    }
    
    //声明区
    open var navigationController: UINavigationController!
    open var disposeBag: DisposeBag!
    open var viewModel: MeSpaceDynamicViewModel! {
        didSet {
            self.bindRx()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupUI()
    }
    
    //私有成员
    fileprivate var dataSource: RxTableViewSectionedReloadDataSource<MeSpaceDynamicSectionModel>!
    fileprivate var emptyView: EmptyView!

}

extension MeSpaceDynamicCollectionViewCell {
    //初始化
    fileprivate func setupUI() {
        //EmptyView
        self.emptyView = EmptyView(target: self)
        self.emptyView.delegate = self
        //PullToRefreshKit
        let secondHeader = SecondRefreshHeader()
        self.tableView.configRefreshHeader(with: secondHeader, action: { [weak self] () -> Void in
            self?.postRefreshState(true)
            self?.viewModel.inputs.refreshNewData.onNext(true)
        })
        self.tableView.configRefreshFooter(with: FirstRefreshFooter(), action: { [weak self] () -> Void in
            self?.viewModel.inputs.refreshNewData.onNext(false)
        })
    }
    fileprivate func bindRx() {
        //Rx
        //TableView
        tableView.rx.setDelegate(self)
            .disposed(by: disposeBag)
        dataSource = RxTableViewSectionedReloadDataSource<MeSpaceDynamicSectionModel>(
            configureCell: { ds, tv, ip, item in
                let cell = tv.dequeueReusableCell(withIdentifier: "dynamic", for: ip) as! MeSpaceDynamicTableViewCell
                
                return cell
        })
        self.tableView.rx
            .modelSelected(Debate.self)
            .subscribe(onNext: { data in
                //跳转
            })
            .disposed(by: disposeBag)
        self.viewModel.outputs.refreshStateObserver.asObservable()
            .subscribe(onNext: { state in
                switch state {
                case .noData:
                    self.postRefreshState(false)
                    self.tableView.switchRefreshHeader(to: .normal(.none, 0))
                    self.showEmptyView(type: .empty)
                    break
                case .beginHeaderRefresh:
                    break
                case .endHeaderRefresh:
                    self.postRefreshState(false)
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
        viewModel.outputs.sections!.asDriver()
            .drive(tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        //刷新
        self.tableView.switchRefreshHeader(to: .refreshing)
        self.postRefreshState(true)
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
    //发送刷新状态
    fileprivate func postRefreshState(_ refresh: Bool) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationName2), object: nil, userInfo: ["refresh": refresh])
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
