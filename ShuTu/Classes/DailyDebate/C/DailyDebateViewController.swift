//
//  DailyDebateViewController.swift
//  ShuTu
//
//  Created by yiqiang on 2018/1/6.
//  Copyright © 2018年 yiqiang. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxDataSources

class DailyDebateViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView! {
        didSet {
            self.tableView.tableFooterView = UIView() //消除底部视图
            self.tableView.separatorStyle = .none //消除分割线
        }
    }
    @IBOutlet weak var navigationBar: UIView!
    @IBOutlet weak var searchBar: UIView!
    @IBOutlet weak var thumbnail: UIImageView! {
        didSet {
            self.thumbnail.layer.cornerRadius = self.thumbnail.frame.height/2
            self.thumbnail.layer.masksToBounds = true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        bindRx()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //隐藏导航栏
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        //添加阴影
        GeneralFactory.generateRectShadow(layer: self.navigationBar.layer, rect: CGRect(x: 0, y: self.navigationBar.frame.height + 1, width: SW, height: 1), color: GMColor.grey300Color().cgColor)
        self.view.bringSubview(toFront: self.navigationBar)
    }
    
    deinit {
        print("deinit: \(type(of: self))")
    }
    
    //私有成员
    fileprivate var dataSource: RxTableViewSectionedReloadDataSource<SectionModel<String, Model>>!
    fileprivate var disposeBag = DisposeBag()
}

extension DailyDebateViewController {
    //初始化
    fileprivate func setupUI() {
        
    }
    fileprivate func bindRx() {
        //TableView
        tableView.rx.setDelegate(self)
            .disposed(by: disposeBag)
        dataSource = RxTableViewSectionedReloadDataSource<SectionModel<String, Model>>(
            configureCell: { ds, tv, ip, item in
                let cell = tv.dequeueReusableCell(withIdentifier: "cell", for: ip) as! DailyDebateTableViewCell
                cell.title?.text = item.title
                
                return cell
            })
        self.tableView.rx
            .modelSelected(Model.self)
            .subscribe(onNext: { data in
//                //跳转至详情
//                let debateStoryBoard = UIStoryboard(name: "Debate", bundle: nil)
//                let debateDetailVC = debateStoryBoard.instantiateViewController(withIdentifier: "DebateDetail") as! DebateDetailViewController
//                debateDetailVC.section = data
//
//                //隐藏 Tabbar
//                self.hidesBottomBarWhenPushed = true
//                self.navigationController?.pushViewController(debateDetailVC, animated: true)
//                self.hidesBottomBarWhenPushed = false
            })
            .disposed(by: disposeBag)
        self.getSections().asObservable()
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
    }
    //TestViewModel
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

extension DailyDebateViewController: UITableViewDelegate {
    //TableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        //取消cell选中状态
        tableView.deselectRow(at: indexPath, animated: true)
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //图片视觉差
        for cell in self.tableView.visibleCells {
            if let homeCell = cell as? DailyDebateTableViewCell {
                homeCell.cellOnTableView(tableView: self.tableView, didScrollOnView: view)
            }
            
        }
    }
}
