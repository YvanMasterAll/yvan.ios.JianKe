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

class DailyDebateViewController: BaseViewController {
    
    @IBOutlet weak var date: UILabel! {
        didSet {
            self.date.text = Date.toString(date: Date.init(), dateFormat: "MM月dd日 eeee")
        }
    }
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            self.tableView.tableFooterView = UIView() //消除底部视图
            self.tableView.separatorStyle = .none //消除分割线
            self.tableView.showsHorizontalScrollIndicator = false
            self.tableView.showsVerticalScrollIndicator = false
        }
    }
    @IBOutlet weak var thumbnail: UIImageView! {
        didSet {
            self.thumbnail.layer.cornerRadius = self.thumbnail.frame.height/2
            self.thumbnail.layer.masksToBounds = true
            self.thumbnail.isUserInteractionEnabled = true
            let tapGes = UITapGestureRecognizer.init(target: self, action: #selector(self.openLeft))
            self.thumbnail.addGestureRecognizer(tapGes)
            if let t = Environment.portrait {
                self.thumbnail.kf.setImage(with: URL.init(string: t))
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        showNavbar = false
        setupUI()
        bindRx()
    }
    
    override func userinfoUpdated() {
        if let t = Environment.userinfo?.portrait {
            self.thumbnail.kf.setImage(with: URL.init(string: t))
        }
    }
    
    override func reload() {
         self.tableView.switchRefreshHeader(to: .refreshing)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    //MARK: - 私有成员
    fileprivate var dataSource: RxTableViewSectionedReloadDataSource<DailyDebateSectionModel>!
    fileprivate var disposeBag = DisposeBag()
    fileprivate var viewModel: DailyDebateViewModel!
}

extension DailyDebateViewController {

    //MARK: - 初始化
    fileprivate func setupUI() {
        //PullToRefreshKit
        let thirdHeader = ThirdRefreshHeader()
        self.tableView.configRefreshHeader(with: thirdHeader, action: { [weak self] () -> Void in
            self?.viewModel.inputs.refreshNewData.onNext(true)
        })
        self.tableView.configRefreshFooter(with: FirstRefreshFooter(), action: { [weak self] () -> Void in
            self?.viewModel.inputs.refreshNewData.onNext(false)
        })
    }
    fileprivate func bindRx() {
        //ViewModel
        viewModel =  DailyDebateViewModel(disposeBag: self.disposeBag)
        //TableView
        tableView.rx.setDelegate(self)
            .disposed(by: disposeBag)
        dataSource = RxTableViewSectionedReloadDataSource<DailyDebateSectionModel>(
            configureCell: { ds, tv, ip, item in
                let cell = tv.dequeueReusableCell(withIdentifier: "cell", for: ip) as! DailyDebateTableViewCell
                cell.selectionStyle = .none //取消高亮
                cell.title.text = item.title
                if let imageUrl = item.cover_image { //图片地址
                    if let imageSource = URL.init(string: imageUrl) {
                        cell.coverImage.kf.setImage(with: imageSource, placeholder: nil, options: nil, progressBlock: nil, completionHandler: { (image, _, _, _) in
                            if image != nil {
                                //cell.setImage()
                            }
                        })
                    }
                }
                
                return cell
            })
        self.tableView.rx
            .modelSelected(Debate.self)
            .subscribe(onNext: { [weak self] data in
                //跳转
                let detailVC = GeneralFactory.getVCfromSb("DailyDebate", "DailyDebateDetail") as! DailyDebateDetailViewController
                detailVC.section = data
                
                //隐藏 Tabbar
                self?.hidesBottomBarWhenPushed = true
                self?.navigationController?.pushViewController(detailVC, animated: true)
                //显示 Tabbar
                self?.hidesBottomBarWhenPushed = false
            })
            .disposed(by: disposeBag)
        self.viewModel.outputs.sections?.asDriver()
            .drive(tableView.rx.items(dataSource: dataSource))
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
        //刷新
        self.tableView.switchRefreshHeader(to: .refreshing)
    }
}

extension DailyDebateViewController: UITableViewDelegate {
    
    //MARK: - TableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //取消cell选中状态
        tableView.deselectRow(at: indexPath, animated: true)
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return true
    }
}
