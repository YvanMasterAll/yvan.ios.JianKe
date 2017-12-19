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
    case beginHeaderRefresh
    case endHeaderRefresh
    case beginFooterRefresh
    case endFooterRefresh
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
    //inputs
    public var refreshNewData = PublishSubject<Bool>()
    //outputs
    public var sections: Driver<[HomeSectionModel]>
    //get
    public var inputs: HomeViewModelInput { return self }
    public var outputs: HomeViewModelOutput { return self }
    
    init(disposeBag: DisposeBag, tableView: UITableView) {
        //服务
        let service = NewsService.instance
        //初始化
        self.disposeBag = disposeBag
        self.tableView = tableView
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
                            }
                            //结束刷新
                            self.refreshStateObserver.value = .endHeaderRefresh
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
                            }
                            //结束刷新
                            self.refreshStateObserver.value = .endFooterRefresh
                        })
                        .disposed(by: self.disposeBag)
                }
            })
            .disposed(by: disposeBag)
        refreshStateObserver.asObservable()
            .subscribe(onNext: { state in
                switch state {
                case .beginHeaderRefresh:
                    tableView.mj_header.beginRefreshing()
                    break
                case .endHeaderRefresh:
                    tableView.mj_header.endRefreshing()
                    break
                case .beginFooterRefresh:
                    tableView.mj_footer.beginRefreshing()
                    break
                case .endFooterRefresh:
                    tableView.mj_footer.endRefreshing()
                    break
                default:
                    break
                }
            })
            .disposed(by: disposeBag)
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
