//
//  DebateSearchViewModel.swift
//  ShuTu
//
//  Created by yiqiang on 2018/2/28.
//  Copyright © 2018年 yiqiang. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import RxDataSources

public struct DebateSearchViewModelInput {
    var refreshNewData: PublishSubject<(Bool, String)>
}
public struct DebateSearchViewModelOutput {
    var sections: Driver<[DebateSearchSectionModel]>?
    var refreshStateObserver: Variable<RefreshStatus>
}
public class DebateSearchViewModel {
    fileprivate struct SearchModel {
        var pageIndex: Int
        var disposeBag: DisposeBag
        var models: Variable<[Debate]>
    }
    //私有成员
    fileprivate var searchModel: SearchModel!
    fileprivate var service = DebateService.instance
    //Inputs
    open var inputs: DebateSearchViewModelInput = {
        return DebateSearchViewModelInput(refreshNewData: PublishSubject<(Bool, String)>())
    }()
    //Outputs
    open var outputs: DebateSearchViewModelOutput = {
        return DebateSearchViewModelOutput(sections: nil, refreshStateObserver: Variable<RefreshStatus>(.none))
    }()
    
    init(disposeBag: DisposeBag) {
        self.searchModel = SearchModel(pageIndex: 0, disposeBag: disposeBag, models: Variable<[Debate]>([]))
        //Rx
        self.outputs.sections = self.searchModel.models.asObservable()
            .map{ models in
                return [DebateSearchSectionModel.init(items: models)]
            }
            .asDriver(onErrorJustReturn: [])
        self.inputs.refreshNewData.asObserver()
            .subscribe(onNext: { (full, title) in
                if full {//头部刷新
                    self.outputs.refreshStateObserver.value = .endFooterRefresh
                    //初始化
                    self.searchModel.pageIndex = 0
                    //拉取数据
                    self.service.getTopics(title: title, pageIndex: self.searchModel.pageIndex)
                        .subscribe(onNext: { response in
                            let data = response.0
                            let result = response.1
                            switch result {
                            case .ok:
                                self.searchModel.models.value.removeAll()
                                self.searchModel.models.value = data
                                //结束刷新
                                self.outputs.refreshStateObserver.value = .endHeaderRefresh
                                break
                            default:
                                //请求错误
                                self.outputs.refreshStateObserver.value = .noData
                                break
                            }
                        })
                        .disposed(by: self.searchModel.disposeBag)
                } else {//加载更多
                    self.searchModel.pageIndex += 1
                    //拉取数据
                    self.service.getTopics(title: title, pageIndex: self.searchModel.pageIndex)
                        .subscribe(onNext: { response in
                            let data = response.0
                            let result = response.1
                            switch result {
                            case .ok:
                                if data.count > 0 {
                                    self.searchModel.models.value += data
                                    //结束刷新
                                    self.outputs.refreshStateObserver.value = .endFooterRefresh
                                } else {
                                    //没有更多数据
                                    self.outputs.refreshStateObserver.value = .endRefreshWithoutData
                                }
                                break
                            default:
                                //没有更多数据
                                self.outputs.refreshStateObserver.value = .endRefreshWithoutData
                                break
                            }
                        })
                        .disposed(by: self.searchModel.disposeBag)
                }
            })
            .disposed(by: searchModel.disposeBag)
    }
}

public struct DebateSearchSectionModel {
    public var items: [item]
}

extension DebateSearchSectionModel: SectionModelType {
    public typealias item = Debate
    
    public init(original: DebateSearchSectionModel, items: [DebateSearchSectionModel.item]) {
        self = original
        self.items = items
    }
}
