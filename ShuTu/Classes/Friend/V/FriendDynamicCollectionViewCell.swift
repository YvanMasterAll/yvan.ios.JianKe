//
//  FriendDynamicCollectionViewCell.swift
//  ShuTu
//
//  Created by yiqiang on 2018/1/4.
//  Copyright © 2018年 yiqiang. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class FriendDynamicCollectionViewCell: FSPagerViewCell {
    
    @IBOutlet weak var sixinView: UIView! {
        didSet {
            self.sixinView.isUserInteractionEnabled = true
            let tapGes = UITapGestureRecognizer.init(target: self, action: #selector(self.gotoSixin))
            self.sixinView.addGestureRecognizer(tapGes)
        }
    }
    @IBOutlet weak var filterView: UIView!
    @IBOutlet weak var sixinImageView: UIView! {
        didSet {
            self.sixinImageView.layer.cornerRadius = 8
            self.sixinImageView.layer.masksToBounds = true
        }
    }
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            self.tableView.register(UINib(nibName: "FriendDynamicTableViewCell", bundle: nil), forCellReuseIdentifier: "dynamicCell")
            self.tableView.showsVerticalScrollIndicator = false
            self.tableView.tableFooterView = UIView() //消除底部视图
            self.tableView.separatorStyle = .none //消除分割线
        }
    }
    
    //MARK: - 声明区域
    open var navigationController: UINavigationController!
    open var disposeBag: DisposeBag!
    open var viewModel: FriendDynamicViewModel! {
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
        GeneralFactory.generateRectShadow(layer: self.filterView.layer, rect: CGRect(x: 0, y: self.filterView.frame.height, width: SW, height: 0.5), color: STColor.grey800Color().cgColor)
        self.bringSubview(toFront: self.filterView)
    }
    
    //MARK: - 私有成员
    fileprivate var dataSource: RxTableViewSectionedReloadDataSource<FriendDynamicSectionModel>!

}

extension FriendDynamicCollectionViewCell {

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
        //TableView
        tableView.rx.setDelegate(self)
            .disposed(by: disposeBag)
        dataSource = RxTableViewSectionedReloadDataSource<FriendDynamicSectionModel>(
            configureCell: { ds, tv, ip, item in
                let cell = tv.dequeueReusableCell(withIdentifier: "dynamicCell", for: ip) as! FriendDynamicTableViewCell
                if let type = item.category {
                    switch type {
                    case TrendType.answer_topic.rawValue:
                        cell.label1.text = "关注好友动态"
                        cell.label2.text = item.title
                        cell.label3.text = "发表了新的观点"
                    case TrendType.new_topic.rawValue:
                        cell.label1.text = "关注好友动态"
                        cell.label2.text = item.title
                        cell.label3.text = "发表了新的话题"
                    case TrendType.new_answer.rawValue:
                        cell.label1.text = "话题动态"
                        cell.label2.text = item.title
                        cell.label3.text = "有了新的观点"
                    default:
                        break
                    }
                }
                
                return cell
        })
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
    //转到私信
    @objc fileprivate func gotoSixin() {
        //跳转至详情
        let friendSixinVC = GeneralFactory.getVCfromSb("Friend", "FriendSixin") as! FriendSixinViewController
        
        //隐藏 Tabbar
        self.navigationController.hidesBottomBarWhenPushed = true
        self.navigationController.pushViewController(friendSixinVC, animated: true)
        self.navigationController.hidesBottomBarWhenPushed = false
    }
}

extension FriendDynamicCollectionViewCell: UITableViewDelegate {
    
    //MARK: - TableViewDelegate && TableViewDataSource
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //取消cell选中状态
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
