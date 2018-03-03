//
//  DailyDebateViewModel.swift
//  ShuTu
//
//  Created by yiqiang on 2018/1/11.
//  Copyright © 2018年 yiqiang. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import RxDataSources

public struct DailyDebateViewModelInput {
    var refreshNewData: PublishSubject<Bool>
}
public struct DailyDebateViewModelOutput {
    var sections: Driver<[DailyDebateSectionModel]>?
    var refreshStateObserver: Variable<RefreshStatus>
}
public class DailyDebateViewModel {
    fileprivate struct DailyDebateModel {
        var pageIndex: Int
        var disposeBag: DisposeBag
        var models: Variable<[Debate]>
    }
    //私有成员
    fileprivate var debateModel: DailyDebateModel!
    fileprivate var service = DebateService.instance
    //Inputs
    open var inputs: DailyDebateViewModelInput = {
        return DailyDebateViewModelInput(refreshNewData: PublishSubject<Bool>())
    }()
    //Outputs
    open var outputs: DailyDebateViewModelOutput = {
        return DailyDebateViewModelOutput(sections: nil, refreshStateObserver: Variable<RefreshStatus>(.none))
    }()
    
    init(disposeBag: DisposeBag) {
        self.debateModel = DailyDebateModel(pageIndex: 0, disposeBag: disposeBag, models: Variable<[Debate]>([]))
        //Rx
        self.outputs.sections = self.debateModel.models.asObservable()
            .map{ models in
                return [DailyDebateSectionModel.init(items: models)]
            }
            .asDriver(onErrorJustReturn: [])
        self.inputs.refreshNewData.asObserver()
            .subscribe(onNext: { full in
                if full {//头部刷新
                    self.outputs.refreshStateObserver.value = .endFooterRefresh
                    //初始化
                    self.debateModel.pageIndex = 1
                    //拉取数据
                    self.service.getDailyTopics(pageIndex: self.debateModel.pageIndex)
                        .subscribe(onNext: { response in
                            let data = response.0
                            let result = response.1
                            switch result {
                            case .ok:
                                self.debateModel.models.value.removeAll()
                                self.debateModel.models.value = data
                                //结束刷新
                                self.outputs.refreshStateObserver.value = .endHeaderRefresh
                                break
                            default:
                                //请求错误
                                self.outputs.refreshStateObserver.value = .noData
                                break
                            }
                        })
                        .disposed(by: self.debateModel.disposeBag)
                } else {//加载更多
                    self.debateModel.pageIndex += 1
                    //拉取数据
                    self.service.getDailyTopics(pageIndex: self.debateModel.pageIndex)
                        .subscribe(onNext: { response in
                            let data = response.0
                            let result = response.1
                            switch result {
                            case .ok:
                                if data.count > 0 {
                                    self.debateModel.models.value += data
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
                        .disposed(by: self.debateModel.disposeBag)
                }
            })
            .disposed(by: debateModel.disposeBag)
    }
}

public struct DailyDebateSectionModel {
    public var items: [item]
}

extension DailyDebateSectionModel: SectionModelType {
    public typealias item = Debate
    
    public init(original: DailyDebateSectionModel, items: [DailyDebateSectionModel.item]) {
        self = original
        self.items = items
    }
}
