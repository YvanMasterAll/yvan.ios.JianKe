//
//  HomeViewModel.swift
//  JianKe
//
//  Created by yiqiang on 2017/12/15.
//  Copyright © 2017年 yiqiang. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import Moya
import RxDataSources

//刷新状态
public enum RefreshStatus {
    case none
    case noData
    case beginHeaderRefresh
    case endHeaderRefresh
    case beginFooterRefresh
    case endFooterRefresh
    case endRefreshWithoutData
}

public protocol HomeViewModelInput {
    var refreshNewData: PublishSubject<Bool>{ get }
}
public protocol HomeViewModelOutput {
    var sections: Driver<[HomeSectionModel]>{ get }
}
public protocol HomeViewModelType {
    var inputs: HomeViewModelInput { get }
    var outputs: HomeViewModelOutput { get }
}
public class HomeViewModel: HomeViewModelInput, HomeViewModelOutput, HomeViewModelType {
    //声明区
    fileprivate var pageIndex = 0
    fileprivate let models = Variable<[NewsStory]>([])
    fileprivate let disposeBag: DisposeBag!
    fileprivate let tableView: UITableView!
    fileprivate var refreshStateObserver = Variable<RefreshStatus>(.none)
    fileprivate var emptyZone: EmptyZone!
    fileprivate var pagerView: FSPagerView!
    //inputs
    public var refreshNewData = PublishSubject<Bool>()
    //outputs
    public var sections: Driver<[HomeSectionModel]>
    public var carsouselData = [NewsImage]()
    //get
    public var inputs: HomeViewModelInput { return self }
    public var outputs: HomeViewModelOutput { return self }
    
    init(disposeBag: DisposeBag, tableView: UITableView, emptyZone: EmptyZone, pagerView: FSPagerView) {
        //服务
        let service = NewsService.instance
        //初始化
        self.disposeBag = disposeBag
        self.tableView = tableView
        self.emptyZone = emptyZone
        self.pagerView = pagerView
        //Rx
        sections = models.asObservable()
            .map{ models -> [HomeSectionModel] in
                return [HomeSectionModel(items: models)]
            }
            .asDriver(onErrorJustReturn: [])
        refreshNewData.asObserver()
            .subscribe(onNext: { full in
                if full {//头部刷新
                    //初始化
                    self.pageIndex = 0
                    //拉取数据
                    service.getNewsByDate()
                        .subscribe(onNext: { data in
                            if data.stories != nil {
                                self.models.value.removeAll()
                                self.models.value = data.stories!
                                //结束刷新
                                self.refreshStateObserver.value = .endHeaderRefresh
                            } else {
                                //没有数据
                                self.refreshStateObserver.value = .noData
                            }
                        })
                        .disposed(by: self.disposeBag)
                    //拉取轮播数据
                    service.getNewsCarousel()
                        .subscribe(onNext: { data in
                            if data.count != 0 {
                                self.carsouselData = data
                                self.pagerView.reloadData()
                            }
                        })
                        .disposed(by: self.disposeBag)
                } else {//加载更多
                    self.pageIndex += 1
                    let date = Date.toString(date: Date(timeIntervalSinceNow: -Double(self.pageIndex) * 24 * 60 * 60), dateFormat: "yyyyMMdd")
                    //拉取数据
                    service.getNewsByDate(date)
                        .subscribe(onNext: { data in
                            if data.stories != nil {
                                self.models.value += data.stories!
                                //结束刷新
                                self.refreshStateObserver.value = .endFooterRefresh
                            } else {//没有更多数据
                                //结束刷新
                                self.refreshStateObserver.value = .endRefreshWithoutData
                            }
                        })
                        .disposed(by: self.disposeBag)
                }
            })
            .disposed(by: disposeBag)
        refreshStateObserver.asObservable()
            .subscribe(onNext: { state in
                switch state {
                case .noData:
                    self.showEmptyZone(type: .empty)
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
        self.emptyZone.delegate = self
    }
}

extension HomeViewModel {
    //显示 & 隐藏 Empty Zone
    fileprivate func showEmptyZone(type: EmptyZoneType) {
        self.tableView.switchRefreshHeader(to: .normal(.none, 0))
        tableView.isHidden = true
        self.emptyZone.show(type: type)
    }
    fileprivate func hideEmptyZone() {
        self.emptyZone.hide()
        tableView.isHidden = false
        self.tableView.switchRefreshHeader(to: .refreshing)
    }
}

extension HomeViewModel: EmptyZoneDelegate {
    func emptyZoneClicked() {
        self.hideEmptyZone()
    }
}

public struct HomeSectionModel {
    public var items: [item]
}

extension HomeSectionModel: SectionModelType {
    public typealias item = NewsStory
    
    public init(original: HomeSectionModel, items: [HomeSectionModel.item]) {
        self = original
        self.items = items
    }
}
