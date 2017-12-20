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
    @IBOutlet weak var searchBar: UIView!
    @IBOutlet weak var pagerView: FSPagerView! {
        didSet {
            self.pagerView.register(FSPagerViewCell.self, forCellWithReuseIdentifier: "cell")
            self.pagerView.itemSize = .zero
        }
    }
    @IBOutlet weak var pageControl: FSPageControl! {
        didSet {
            self.pageControl.backgroundColor = .clear
            self.pageControl.numberOfPages = self.imageNames.count
            self.pageControl.contentHorizontalAlignment = .right
            self.pageControl.contentInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        }
    }
    
    //声明区
    fileprivate let disposeBag = DisposeBag()
    fileprivate var viewModel: HomeViewModel!
    fileprivate var dataSource: RxTableViewSectionedReloadDataSource<HomeSectionModel>!
    fileprivate var emptyZone: EmptyZone!
    
    //私有成员
    fileprivate let imageNames = ["1","2","3","4","5","6","7"]

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
        //EmptyZone
        self.emptyZone = EmptyZone(frame: self.view.frame)
        self.view.addSubview(emptyZone)
        //消除底部视图
        self.tableView.tableFooterView = UIView()
        //PullToRefreshKit
        let firstHeader = FirstRefreshHeader()
        self.tableView.configRefreshHeader(with: firstHeader, action: {
            self.viewModel.inputs.refreshNewData.onNext(true)
        })
        self.tableView.configRefreshFooter(with: FirstRefreshFooter(), action: {
            self.viewModel.inputs.refreshNewData.onNext(false)
        })
    }
    //绑定 Rx
    fileprivate func bindRx() {
        //ViewModel
        viewModel =  HomeViewModel(disposeBag: self.disposeBag, tableView: self.tableView, emptyZone: emptyZone)
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
        self.tableView.switchRefreshHeader(to: .refreshing)
    }
}

extension HomeViewController: UITableViewDelegate, FSPagerViewDelegate, FSPagerViewDataSource {
    //FSPagerViewDataSource & FSPagerViewDelegate
    public func numberOfItems(in pagerView: FSPagerView) -> Int {
        return self.imageNames.count
    }
    public func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        let cell = pagerView.dequeueReusableCell(withReuseIdentifier: "cell", at: index)
        cell.imageView?.image = UIImage(named: self.imageNames[index])
        cell.imageView?.contentMode = .scaleAspectFill
        cell.imageView?.clipsToBounds = true
        return cell
    }
    func pagerView(_ pagerView: FSPagerView, didSelectItemAt index: Int) {
        pagerView.deselectItem(at: index, animated: true)
        pagerView.scrollToItem(at: index, animated: true)
        self.pageControl.currentPage = index
    }
    func pagerViewDidScroll(_ pagerView: FSPagerView) {
        guard self.pageControl.currentPage != pagerView.currentIndex else {
            return
        }
        self.pageControl.currentPage = pagerView.currentIndex // Or Use KVO with property "currentIndex"
    }
}

