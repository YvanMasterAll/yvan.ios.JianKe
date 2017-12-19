//
//  HomeViewController.swift
//  JianKe
//
//  Created by yiqiang on 2017/12/15.
//  Copyright © 2017年 yiqiang. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxDataSources
import MJRefresh

class HomeViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    //声明区
    fileprivate let disposeBag = DisposeBag()
    fileprivate var viewModel: HomeViewModel!
    fileprivate var dataSource: RxTableViewSectionedReloadDataSource<HomeSectionModel>!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        
        setupUI()
        bindRx()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}

extension HomeViewController {
    //初始化
    fileprivate func setupUI() {
        //消除底部视图
        self.tableView.tableFooterView = UIView()
        //MJRefresh
        self.tableView.mj_header = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(self.headerRefresh))
        self.tableView.mj_header.isAutomaticallyChangeAlpha = true
        self.tableView.mj_footer = MJRefreshAutoFooter(refreshingTarget: self, refreshingAction: #selector(self.footerRefresh))
    }
    //绑定 Rx
    fileprivate func bindRx() {
        //ViewModel
        viewModel =  HomeViewModel(disposeBag: self.disposeBag, tableView: self.tableView)
        //TableView
        tableView.rx.setDelegate(self)
            .disposed(by: disposeBag)
        dataSource = RxTableViewSectionedReloadDataSource<HomeSectionModel>(
            configureCell: { ds, tv, ip, item in
                let cell = tv.dequeueReusableCell(withIdentifier: "Cell", for: ip)
                cell.textLabel?.text = item.title
                return cell
            }
        )
        viewModel.outputs.sections.asDriver()
            .drive(tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        //刷新
        viewModel.inputs.refreshNewData.onNext(true)
    }
    //#selector - mj_header & mj_footer
    @objc fileprivate func headerRefresh() {
        viewModel.inputs.refreshNewData.onNext(true)
    }
    @objc fileprivate func footerRefresh() {
        viewModel.inputs.refreshNewData.onNext(false)
    }
}

extension HomeViewController: UITableViewDelegate {
    
}
