//
//  FriendSixinViewController.swift
//  ShuTu
//
//  Created by yiqiang on 2018/1/7.
//  Copyright © 2018年 yiqiang. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxDataSources

class FriendSixinViewController: BaseViewController {
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            self.tableView.tableFooterView = UIView() //消除底部视图
            self.tableView.separatorStyle = .none //消除分割线
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        showNavbar = true
        navBarTitle = "私信"
        setupUI()
        bindRx()
    }
    
    //MARK: - 私有成员
    fileprivate var dataSource: RxTableViewSectionedReloadDataSource<SectionModel<String, Model>>!
    fileprivate var disposeBag = DisposeBag()

}

extension FriendSixinViewController {

    //MARK: - 初始化
    fileprivate func setupUI() {
        
    }
    fileprivate func bindRx() {
        //TableView
        tableView.rx.setDelegate(self)
            .disposed(by: disposeBag)
        dataSource = RxTableViewSectionedReloadDataSource<SectionModel<String, Model>>(
            configureCell: { ds, tv, ip, item in
                let cell = tv.dequeueReusableCell(withIdentifier: "cell", for: ip) as! FriendSixinTableViewCell
                
                return cell
        })
        self.tableView.rx
            .modelSelected(Model.self)
            .subscribe(onNext: { data in
                //跳转
            })
            .disposed(by: disposeBag)
        self.getSections().asObservable()
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
    }
    
    //MARK: - Test ViewModel
    fileprivate struct Model {
        var title: String
    }
    fileprivate func getSections() -> Observable<[SectionModel<String, Model>]> {
        return Observable.create {
            (observer) -> Disposable in
            let models = [Model.init(title: "hi"), Model.init(title: "hi"), Model.init(title: "hi"), Model.init(title: "hi"), Model.init(title: "hi"), Model.init(title: "hi"), Model.init(title: "hi"), Model.init(title: "hi"), Model.init(title: "hi"), Model.init(title: "hi"), Model.init(title: "hi"), Model.init(title: "hi"), Model.init(title: "hi"), Model.init(title: "hi"), Model.init(title: "hi")]
            let section = [SectionModel(model:"model",items: models)]
            observer.onNext(section)
            observer.onCompleted()
            return Disposables.create()
        }
    }
}

extension FriendSixinViewController: UITableViewDelegate {
    
    //MAKR: - TableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //取消cell选中状态
        tableView.deselectRow(at: indexPath, animated: true)
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
}
