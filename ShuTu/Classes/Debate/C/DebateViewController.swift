//
//  DebateViewController.swift
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

class DebateViewController: UIViewController {

    @IBOutlet weak var thumbnail: UIImageView! {
        didSet {
            self.thumbnail.layer.cornerRadius = self.thumbnail.frame.height/2
            self.thumbnail.layer.masksToBounds = true
            self.thumbnail.isUserInteractionEnabled = true
            let tapGes = UITapGestureRecognizer.init(target: self, action: #selector(self.openLeft))
            self.thumbnail.addGestureRecognizer(tapGes)
        }
    }
    @IBOutlet weak var addDebate: UIView!
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
    fileprivate var viewModel: DebateViewModel!
    fileprivate var dataSource: RxTableViewSectionedReloadDataSource<DebateSectionModel>!
    fileprivate var emptyView: EmptyView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        
        setupUI()
        bindRx()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //隐藏导航栏
        self.navigationItem.backBarButtonItem = UIBarButtonItem.init(title: "", style: .plain, target: self, action: nil)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        //阴影
        GeneralFactory.generateRectShadow(layer: self.searchBar.layer, rect: CGRect.init(x: 0, y: self.searchBar.frame.height, width: SW, height: 0.5), color: GMColor.grey800Color().cgColor)
        self.view.bringSubview(toFront: self.searchBar)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    deinit {
        print("deinit: \(type(of: self))")
    }

}

extension DebateViewController {
    //初始化
    fileprivate func setupUI() {
        //EmptyView
        self.emptyView = EmptyView(target: self.view)
        //TableView
        self.tableView.tableFooterView = UIView() //消除底部视图
        self.tableView.separatorStyle = .none //消除分割线
        self.tableView.showsVerticalScrollIndicator = false
        self.tableView.showsHorizontalScrollIndicator = false
        //PullToRefreshKit
        let firstHeader = FirstRefreshHeader()
        self.tableView.configRefreshHeader(with: firstHeader, action: {
            self.viewModel.inputs.refreshNewData.onNext(true)
        })
        self.tableView.configRefreshFooter(with: FirstRefreshFooter(), action: {
            self.viewModel.inputs.refreshNewData.onNext(false)
        })
        //Go To AddDebate
        let tapGes = UITapGestureRecognizer.init(target: self, action: #selector(self.gotoAddDebate))
        self.addDebate.addGestureRecognizer(tapGes)
        self.addDebate.isUserInteractionEnabled = true
    }
    //绑定 Rx
    fileprivate func bindRx() {
        //ViewModel
        viewModel =  DebateViewModel(disposeBag: self.disposeBag, tableView: self.tableView, emptyView: emptyView, pagerView: pagerView)
        //TableView
        tableView.rx.setDelegate(self)
            .disposed(by: disposeBag)
        dataSource = RxTableViewSectionedReloadDataSource<DebateSectionModel>(
            configureCell: { ds, tv, ip, item in
                let cell = tv.dequeueReusableCell(withIdentifier: "cell", for: ip) as! DebateTableViewCell
                cell.title.text = item.title
                cell.desc.text = item.desc
                cell.thumbnail.kf.setImage(with: URL(string: item.thumbnail!))
                //计算 desc label 高度
                cell.setupConstraint()
                return cell
            }
        )
        self.tableView.rx
            .modelSelected(Debate.self)
            .subscribe(onNext: { data in
                //跳转至详情
                let debateStoryBoard = UIStoryboard(name: "Debate", bundle: nil)
                let debateDetailVC = debateStoryBoard.instantiateViewController(withIdentifier: "DebateDetail") as! DebateDetailViewController
                debateDetailVC.section = data
                
                //隐藏 Tabbar
                self.hidesBottomBarWhenPushed = true
                self.slideMenuController()?.removeLeftGestures()
                self.navigationController?.pushViewController(debateDetailVC, animated: true)
                self.slideMenuController()?.addLeftGestures()
                self.hidesBottomBarWhenPushed = false
            })
            .disposed(by: disposeBag)
        viewModel.outputs.sections.asDriver()
            .drive(tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        //刷新
        self.tableView.switchRefreshHeader(to: .refreshing)
    }
    //跳转到添加辩题页
    @objc fileprivate func gotoAddDebate() {
        let debateStoryBoard = UIStoryboard(name: "Debate", bundle: nil)
        let debateAddNewVC = debateStoryBoard.instantiateViewController(withIdentifier: "DebateAddNew") as! DebateAddNewViewController
        
        //隐藏 Tabbar
        self.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(debateAddNewVC, animated: true)
        self.hidesBottomBarWhenPushed = false
    }
}

extension DebateViewController: UITableViewDelegate, FSPagerViewDelegate, FSPagerViewDataSource {
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
        //取消cell选中状态
        tableView.deselectRow(at: indexPath, animated: true)
    }
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
}

