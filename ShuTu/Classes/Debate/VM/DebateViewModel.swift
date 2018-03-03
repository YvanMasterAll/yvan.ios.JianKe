//
//  DebateViewModel.swift
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

public protocol DebateViewModelInput {
    var refreshNewData: PublishSubject<Bool>{ get }
}
public protocol DebateViewModelOutput {
    var sections: Driver<[DebateSectionModel]>{ get }
}
public protocol DebateViewModelType {
    var inputs: DebateViewModelInput { get }
    var outputs: DebateViewModelOutput { get }
}
public class DebateViewModel: DebateViewModelInput, DebateViewModelOutput, DebateViewModelType {
    //声明区
    fileprivate var pageIndex = 0
    fileprivate let models = Variable<[Debate]>([])
    fileprivate let disposeBag: DisposeBag!
    fileprivate let tableView: UITableView!
    fileprivate var pagerView: FSPagerView!
    //inputs
    public var refreshNewData = PublishSubject<Bool>()
    //outputs
    public var sections: Driver<[DebateSectionModel]>
    public var carsouselData = [DebateImage]()
    public var refreshStateObserver = Variable<RefreshStatus>(.none)
    //get
    public var inputs: DebateViewModelInput { return self }
    public var outputs: DebateViewModelOutput { return self }
    
    init(disposeBag: DisposeBag, tableView: UITableView, pagerView: FSPagerView) {
        //服务
        let service = DebateService.instance
        //初始化
        self.disposeBag = disposeBag
        self.tableView = tableView
        self.pagerView = pagerView
        //Rx
        sections = models.asObservable()
            .map{ models -> [DebateSectionModel] in
                return [DebateSectionModel(items: models)]
            }
            .asDriver(onErrorJustReturn: [])
        refreshNewData.asObserver()
            .subscribe(onNext: { full in
                if full {//头部刷新
                    self.refreshStateObserver.value = .endFooterRefresh
                    //初始化
                    self.pageIndex = 1
                    //拉取数据
                    service.getTopics(pageIndex: self.pageIndex)
                        .subscribe(onNext: { response in
                            let data = response.0
                            if data.count > 0 {
                                self.models.value.removeAll()
                                self.models.value = data
                                //结束刷新
                                self.refreshStateObserver.value = .endHeaderRefresh
                            } else {
                                //请求错误
                                self.refreshStateObserver.value = .noData
                            }
                        })
                        .disposed(by: self.disposeBag)
                    //拉取轮播数据
                    service.getDebateCarousel()
                        .subscribe(onNext: { data in
                            if data.count != 0 {
                                self.carsouselData = data
                                self.pagerView.reloadData()
                            }
                        })
                        .disposed(by: self.disposeBag)
                } else {//加载更多
                    self.pageIndex += 1
                    //拉取数据
                    service.getTopics(pageIndex: self.pageIndex)
                        .subscribe(onNext: { response in
                            let data = response.0
                            if data.count > 0 {
                                self.models.value += data
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
    }
}

public struct DebateSectionModel {
    public var items: [item]
}

extension DebateSectionModel: SectionModelType {
    public typealias item = Debate
    
    public init(original: DebateSectionModel, items: [DebateSectionModel.item]) {
        self = original
        self.items = items
    }
}
