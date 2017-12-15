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

class HomeViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    //声明区
    fileprivate let disposeBag = DisposeBag()
    fileprivate let viewModel = HomeViewModel()
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
    }
    //绑定 Rx
    fileprivate func bindRx() {
        //TableView
        tableView.rx.setDelegate(self)
            .disposed(by: disposeBag)
        dataSource = RxTableViewSectionedReloadDataSource<HomeSectionModel>(
            configureCell: { ds, tv, ip, item in
                let cell = tv.dequeueReusableCell(withIdentifier: "Cell", for: ip)
                cell.textLabel?.text = "Item"
                
                return cell
            }
        )
        viewModel.outputs.sections.asDriver()
            .drive(tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        viewModel.outputs.refreshResult
            .drive(onNext: { result in
                //更新完毕
            })
            .disposed(by: disposeBag)
        viewModel.inputs.isRefresh.onNext(true)
    }
}

extension HomeViewController: UITableViewDelegate {
    
}
