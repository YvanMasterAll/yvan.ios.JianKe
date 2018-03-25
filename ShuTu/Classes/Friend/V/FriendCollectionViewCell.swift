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

class FriendCollectionViewCell: FSPagerViewCell {
    
    @IBOutlet weak var addFriend: STButton!
    @IBOutlet weak var searchBar: UIView!
    @IBOutlet weak var searchView: UIView! {
        didSet {
            self.searchView.layer.cornerRadius = 8
            self.searchView.layer.masksToBounds = true
        }
    }
    @IBOutlet weak var searchTextField: UITextField! {
        didSet {
            let attrStr = NSAttributedString.init(string: self.searchTextField.placeholder!, attributes: [NSAttributedStringKey.foregroundColor: STColor.grey300Color()])
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
    
    //MARK: - 声明区域
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
    
    override func reload() {
        self.tableView.switchRefreshHeader(to: .refreshing)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        //阴影
        GeneralFactory.generateRectShadow(layer: self.searchBar.layer, rect: CGRect.init(x: 0, y: self.searchBar.frame.height, width: SW, height: 0.5), color: STColor.grey800Color().cgColor)
        self.bringSubview(toFront: self.searchBar)
    }
    
    //MARK: - 私有成员
    fileprivate var dataSource: RxTableViewSectionedReloadDataSource<FriendSectionModel>!
    
}

extension FriendCollectionViewCell {

    //MARK: - 初始化
    fileprivate func setupUI() {
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
        tableView.rx.setDelegate(self)
            .disposed(by: disposeBag)
        dataSource = RxTableViewSectionedReloadDataSource<FriendSectionModel>(
            configureCell: { ds, tv, ip, item in
                let cell = tv.dequeueReusableCell(withIdentifier: "friendCell", for: ip) as! FriendTableViewCell
                cell.thumbnail.kf.setImage(with: URL.init(string: item.portrait!)!)
                cell.name.text = item.nickname
                cell.sign.text = item.signature
                
                return cell
        })
        self.tableView.rx
            .modelSelected(User.self)
            .subscribe(onNext: { data in
                //跳转
            })
            .disposed(by: disposeBag)
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
        viewModel.outputs.sections!.asDriver()
            .drive(tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        //刷新
        self.tableView.switchRefreshHeader(to: .refreshing)
    }
}

extension FriendCollectionViewCell: UITableViewDelegate {
    
    //MARK: - TableViewDelegate && TableViewDataSource
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //取消cell选中状态
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
