//
//  FriendCollectionViewCell.swift
//  ShuTu
//
//  Created by yiqiang on 2018/1/4.
//  Copyright © 2018年 yiqiang. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import SnapKit
import PMSuperButton

class FriendCollectionViewCell: FSPagerViewCell {
    
    @IBOutlet weak var addFriend: PMSuperButton!
    @IBOutlet weak var searchBar: UIView!
    @IBOutlet weak var searchView: UIView! {
        didSet {
            self.searchView.layer.cornerRadius = 8
            self.searchView.layer.masksToBounds = true
        }
    }
    @IBOutlet weak var searchTextField: UITextField! {
        didSet {
            let attrStr = NSAttributedString.init(string: self.searchTextField.placeholder!, attributes: [NSAttributedStringKey.foregroundColor: GMColor.grey300Color()])
            self.searchTextField.attributedPlaceholder = attrStr
        }
    }
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            self.tableView.register(UINib(nibName: "FriendTableViewCell", bundle: nil), forCellReuseIdentifier: "friendCell")
            self.tableView.showsVerticalScrollIndicator = false
            self.tableView.tableFooterView = UIView() //消除底部视图
            self.tableView.separatorStyle = .none //消除分割线
        }
    }
    
    //声明区
    open var navigationController: UINavigationController!
    open var disposeBag: DisposeBag!
    open var viewModel: FriendViewModel! {
        didSet {
            self.bindRx()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupUI()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        //阴影
        GeneralFactory.generateRectShadow(layer: self.searchBar.layer, rect: CGRect.init(x: 0, y: self.searchBar.frame.height, width: SW, height: 0.5), color: GMColor.grey300Color().cgColor)
        self.bringSubview(toFront: self.searchBar)
    }
    
    //私有成员
    fileprivate var dataSource: RxTableViewSectionedReloadDataSource<FriendSectionModel>!
    fileprivate var emptyView: EmptyView!
    
}

extension FriendCollectionViewCell {
    //初始化
    fileprivate func setupUI() {
        //EmptyView
        self.emptyView = EmptyView(target: self)
        self.emptyView.delegate = self
        //PullToRefreshKit
        let secondHeader = SecondRefreshHeader()
        self.tableView.configRefreshHeader(with: secondHeader, action: { [weak self] () -> Void in
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
        dataSource = RxTableViewSectionedReloadDataSource<FriendSectionModel>(
            configureCell: { ds, tv, ip, item in
                let cell = tv.dequeueReusableCell(withIdentifier: "friendCell", for: ip) as! FriendTableViewCell
                
                return cell
        })
        self.tableView.rx
            .modelSelected(Friend.self)
            .subscribe(onNext: { data in
//                //跳转至详情
//                let friendStoryBoard = UIStoryboard(name: "Friend", bundle: nil)
//                let friendSixinVC = friendStoryBoard.instantiateViewController(withIdentifier: "FriendSixin") as! FriendSixinViewController
//                
//                //隐藏 Tabbar
//                self.navigationController.hidesBottomBarWhenPushed = true
//                self.navigationController.pushViewController(friendSixinVC, animated: true)
//                self.navigationController.hidesBottomBarWhenPushed = false
            })
            .disposed(by: disposeBag)
        self.viewModel.outputs.refreshStateObserver.asObservable()
            .subscribe(onNext: { state in
                switch state {
                case .noData:
                    self.showEmptyView(type: .empty)
                    break
                case .beginHeaderRefresh:
                    break
                case .endHeaderRefresh:
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
    }
    //显示 & 隐藏 Empty Zone
    fileprivate func showEmptyView(type: EmptyViewType) {
        self.tableView.switchRefreshHeader(to: .normal(.none, 0))
        tableView.isHidden = true
        self.emptyView.show(type: type, frame: self.tableView.frame)
    }
    fileprivate func hideEmptyView() {
        self.emptyView.hide()
        tableView.isHidden = false
        self.tableView.switchRefreshHeader(to: .refreshing)
    }
}

extension FriendCollectionViewCell: UITableViewDelegate, EmptyViewDelegate {
    //TableViewDelegate && TableViewDataSource
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        //取消cell选中状态
        tableView.deselectRow(at: indexPath, animated: true)
    }
    //EmptyView Delegate
    func emptyViewClicked() {
        self.hideEmptyView()
    }
}
