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
import Kingfisher

class HomeViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UIView!
    @IBOutlet weak var pagerView: FSPagerView! {
        didSet {
            self.pagerView.register(FSPagerViewCell.self, forCellWithReuseIdentifier: "pagerCell")
            self.pagerView.itemSize = .zero
        }
    }
    @IBOutlet weak var pageControl: FSPageControl! {
        didSet {
            self.pageControl.backgroundColor = .clear
            self.pageControl.numberOfPages = 0
            self.pageControl.contentHorizontalAlignment = .right
            self.pageControl.contentInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        }
    }
    
    //声明区
    fileprivate let disposeBag = DisposeBag()
    fileprivate var viewModel: HomeViewModel!
    fileprivate var dataSource: RxTableViewSectionedReloadDataSource<HomeSectionModel>!
    fileprivate var emptyZone: EmptyZone!

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
        self.emptyZone = EmptyZone(target: self.view, frame: self.tableView.frame)
        //TableView
        self.tableView.tableFooterView = UIView() //消除底部视图
        self.tableView.separatorStyle = .none //消除分割线
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
        viewModel =  HomeViewModel(disposeBag: self.disposeBag, tableView: self.tableView, emptyZone: emptyZone, pagerView: pagerView)
        //TableView
        tableView.rx.setDelegate(self)
            .disposed(by: disposeBag)
        dataSource = RxTableViewSectionedReloadDataSource<HomeSectionModel>(
            configureCell: { ds, tv, ip, item in
                let cell = tv.dequeueReusableCell(withIdentifier: "cell", for: ip) as! HomeTableViewCell
                cell.title.text = item.title
                cell.desc.text = item.title! + item.title! + item.title!
                //计算 desc label 高度
                cell.setupConstraint()
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
        self.pageControl.numberOfPages = self.viewModel.carsouselData.count
        return self.viewModel.carsouselData.count
    }
    public func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        let cell = pagerView.dequeueReusableCell(withReuseIdentifier: "pagerCell", at: index)
        let imageUrl = URL(string: self.viewModel.carsouselData[index].image!)
        //Kingfisher
        cell.imageView?.kf.setImage(with: imageUrl, placeholder: UIImage(named: "image_placeholder"), options: nil, progressBlock: nil, completionHandler: nil)
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
    //TableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        // 取消cell选中状态
        tableView.deselectRow(at: indexPath, animated: true)
    }
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
}

