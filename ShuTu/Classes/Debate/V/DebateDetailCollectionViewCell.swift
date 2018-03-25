//
//  DebateDetailCollectionViewCell.swift
//  ShuTu
//
//  Created by yiqiang on 2017/12/23.
//  Copyright © 2017年 yiqiang. All rights reserved.
//

import UIKit
import RxDataSources
import RxCocoa
import RxSwift

class DebateDetailCollectionViewCell: FSPagerViewCell {

    @IBOutlet weak var tableView: UITableView! {
        didSet {
            self.tableView.register(UINib(nibName: "DebateAnswerTableViewCell", bundle: nil), forCellReuseIdentifier: "answerCell")
            self.tableView.showsVerticalScrollIndicator = false
        }
    }
    
    //MARK: - 声明区域
    public var side: AnswerSide!
    public var viewModel: DebateDetailViewModel! {
        didSet {
            self.bindRx()
        }
    }
    public var section: Debate!
    public var navigationController: UINavigationController!
    
    //MARK: - 私有成员
    fileprivate var disposeBag = DisposeBag()
    fileprivate var dataSource: RxTableViewSectionedReloadDataSource<DebateDetailSectionModel>!
    fileprivate var scrollDragging: Bool = false
    fileprivate var parentTableStatus: TableState = .headBottom
    fileprivate var contentOffset: CGPoint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupUI()
    }
    
    override func reload() {
        self.tableView.switchRefreshHeader(to: .refreshing)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}

extension DebateDetailCollectionViewCell {

    //MARK: - 初始化
    fileprivate func setupUI() {
        //TableView
        self.tableView.tableFooterView = UIView() //消除底部视图
        self.tableView.separatorStyle = .none //消除分割线
        //PullToRefreshKit
        let secondHeader = SecondRefreshHeader()
        self.tableView.configRefreshHeader(with: secondHeader, action: {
            switch self.side {
            case .SY:
                self.viewModel.inputsY.refreshNewData.onNext(true)
            case .ST:
                self.viewModel.inputsS.refreshNewData.onNext(true)
            default:
                break
            }
        })
        self.tableView.configRefreshFooter(with: FirstRefreshFooter(), action: {
            switch self.side {
            case .SY:
                self.viewModel.inputsY.refreshNewData.onNext(false)
            case .ST:
                self.viewModel.inputsS.refreshNewData.onNext(false)
            default:
                break
            }
        })
    }
    fileprivate func bindRx() {
        //TableStatus
        TableStatus.asObserver()
            .subscribe(onNext: { [weak self] state in
                self?.parentTableStatus = state
            })
            .disposed(by: self.disposeBag)
        //Delegate
        tableView.rx.setDelegate(self)
            .disposed(by: disposeBag)
        dataSource = RxTableViewSectionedReloadDataSource<DebateDetailSectionModel>(
            configureCell: { ds, tv, ip, item in
                let cell = tv.dequeueReusableCell(withIdentifier: "answerCell", for: ip) as! DebateAnswerTableViewCell
                if !item.isanonymous {
                    cell.thumbnail.kf.setImage(with: URL(string: item.portrait!))
                }
                cell.name.text = item.nickname
                cell.answer.text = item.pureanswer
                cell.score.text = "\(item.supports ?? 0 ) 赞同 · \(item.comments ?? 0) 评论"
                //计算 answer label 高度
                cell.setupConstraint()
                
                return cell
            }
        )
        self.tableView.rx
            .modelSelected(Answer.self)
            .subscribe(onNext: { [unowned self] data in
                //跳转至详情
                let debateAnswerVC = GeneralFactory.getVCfromSb("Debate", "DebateAnswerDetail") as! DebateAnswerDetailViewController
                debateAnswerVC.section = data
                debateAnswerVC.section.title = self.section.title
                
                self.navigationController?.pushViewController(debateAnswerVC, animated: true)
            })
            .disposed(by: disposeBag)
        //Side
        switch self.side {
        case .SY:
            self.viewModel.initAnswerY(disposeBag: self.disposeBag)
            self.viewModel.outputsY.sections!.asDriver()
                .drive(tableView.rx.items(dataSource: dataSource))
                .disposed(by: disposeBag)
            self.viewModel.outputsY.refreshStateObserver.asObservable()
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
            break
        case .ST:
            self.viewModel.initAnswerS(disposeBag: self.disposeBag)
            self.viewModel.outputsS.sections!.asDriver()
                .drive(tableView.rx.items(dataSource: dataSource))
                .disposed(by: disposeBag)
            self.viewModel.outputsS.refreshStateObserver.asObservable()
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
            break
        default:
            break
        }
        //刷新
        self.tableView.switchRefreshHeader(to: .refreshing)
    }
}

extension DebateDetailCollectionViewCell: UITableViewDelegate {
    
    //MARK: - TableViewDelegate && TableViewDataSource
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //取消cell选中状态
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //MARK: - ScrollView Delegate
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.scrollDragging = true
        self.contentOffset = scrollView.contentOffset
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if self.scrollDragging {
            let direction = self.contentOffset.y - scrollView.contentOffset.y
            switch self.parentTableStatus {
            case .headTop:
                if direction > 0 && scrollView.contentOffset.y <= 0 {
                    self.tableView.contentOffset.y = 0
                    SonTableStatus.onNext(.canParentScroll)
                } else {
                    SonTableStatus.onNext(.noParentScroll)
                }
                break
            case .headBottom:
                if direction < 0 && scrollView.contentOffset.y > 0 {
                    self.tableView.contentOffset.y = 0
                    SonTableStatus.onNext(.canParentScroll)
                } else {
                    SonTableStatus.onNext(.noParentScroll)
                }
                break
            case .headMid:
                self.tableView.contentOffset.y = 0
                SonTableStatus.onNext(.canParentScroll)
                break
            default:
                break
            }
        }
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.scrollDragging = false
    }
}

