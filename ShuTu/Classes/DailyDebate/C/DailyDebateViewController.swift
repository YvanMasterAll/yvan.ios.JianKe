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
import NVActivityIndicatorView

class DailyDebateViewController: UIViewController {
    
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
        self.navigationItem.backBarButtonItem = UIBarButtonItem.init(title: "", style: .plain, target: self, action: nil)
    }
    
    deinit {
        print("deinit: \(type(of: self))")
    }
    
    //私有成员
    fileprivate var dataSource: RxTableViewSectionedReloadDataSource<DailyDebateSectionModel>!
    fileprivate var disposeBag = DisposeBag()
    fileprivate var viewModel: DailyDebateViewModel!
    fileprivate var emptyView: EmptyView!
}

extension DailyDebateViewController {
    //初始化
    fileprivate func setupUI() {
        //EmptyView
        self.emptyView = EmptyView(target: self.view)
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
        //ViewModel
        viewModel =  DailyDebateViewModel(disposeBag: self.disposeBag, section: Auth.init())
        //TableView
        tableView.rx.setDelegate(self)
            .disposed(by: disposeBag)
        dataSource = RxTableViewSectionedReloadDataSource<DailyDebateSectionModel>(
            configureCell: { ds, tv, ip, item in
                let cell = tv.dequeueReusableCell(withIdentifier: "cell", for: ip) as! DailyDebateTableViewCell
                cell.selectionStyle = .none //取消高亮
                
                return cell
            })
        self.tableView.rx
            .modelSelected(Debate.self)
            .subscribe(onNext: { data in
                //跳转
                let detailVC = UIStoryboard.init(name: "DailyDebate", bundle: nil).instantiateViewController(withIdentifier: "DailyDebateDetail") as! DailyDebateDetailViewController
                detailVC.section = data
                
                //隐藏 Tabbar
                self.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(detailVC, animated: true)
                //显示 Tabbar
                self.hidesBottomBarWhenPushed = false
            })
            .disposed(by: disposeBag)
        self.viewModel.outputs.sections?.asDriver()
            .drive(tableView.rx.items(dataSource: dataSource))
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

extension DailyDebateViewController: UITableViewDelegate, EmptyViewDelegate {
    //TableViewDelegate
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
    //EmptyView Delegate
    func emptyViewClicked() {
        self.hideEmptyView()
    }
}
