//
//  DebateDetailViewModel.swift
//  ShuTu
//
//  Created by yiqiang on 2017/12/24.
//  Copyright © 2017年 yiqiang. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import RxDataSources

public struct DebateDetailViewModelInput {
    var refreshNewData: PublishSubject<Bool>
}
public struct DebateDetailViewModelOutput {
    var sections: Driver<[DebateDetailSectionModel]>?
    var emptyStateObserver: Variable<EmptyViewType>
}
class DebateDetailViewModel {
    fileprivate struct DebateAnswerModel {
        var pageIndex: Int
        var models: Variable<[Answer]>
        var disposeBag: DisposeBag
        var tableView: UITableView
        var emptyView: EmptyView
        var refreshStateObserver: Variable<RefreshStatus>
    }
    //私有成员
    fileprivate var answerY:  DebateAnswerModel!
    fileprivate var answerS: DebateAnswerModel!
    fileprivate var service = DebateService.instance
    //inputs
    public var section: Debate!
    public var inputsY: DebateDetailViewModelInput!
    public var inputsS: DebateDetailViewModelInput!
    //outputs
    public var outputsY: DebateDetailViewModelOutput!
    public var outputsS: DebateDetailViewModelOutput!
    
    init(section: Debate) {
        //初始化
        self.section = section
        self.inputsY = DebateDetailViewModelInput(refreshNewData: PublishSubject<Bool>())
        self.inputsS = DebateDetailViewModelInput(refreshNewData: PublishSubject<Bool>())
        self.outputsY = DebateDetailViewModelOutput(sections: nil, emptyStateObserver: Variable<EmptyViewType>(.none))
        self.outputsS = DebateDetailViewModelOutput(sections: nil, emptyStateObserver: Variable<EmptyViewType>(.none))
    }
    
    //初始化
    public func initAnswerY(answer: (disposeBag: DisposeBag, tableView: UITableView, emptyView: EmptyView)) {
        self.answerY = DebateAnswerModel(pageIndex: 0, models: Variable<[Answer]>([]), disposeBag: answer.disposeBag, tableView: answer.tableView, emptyView: answer.emptyView, refreshStateObserver: Variable<RefreshStatus>(.none))
        //Rx
        self.outputsY.sections = self.answerY.models.asObservable()
            .map{ models -> [DebateDetailSectionModel] in
                return [DebateDetailSectionModel(items: models)]
            }
            .asDriver(onErrorJustReturn: [])
        self.inputsY.refreshNewData.asObserver()
            .subscribe(onNext: { full in
                if full {//头部刷新
                    self.answerY.refreshStateObserver.value = .endFooterRefresh
                    //初始化
                    self.answerY.pageIndex = 0
                    //拉取数据
                    self.service.getAnswer(id: self.section.id!, pageIndex: self.answerY.pageIndex, side: .SY)
                        .subscribe(onNext: { response in
                            let data = response.0
                            let result = response.1
                            if data.count > 0 {
                                self.answerY.models.value.removeAll()
                                self.answerY.models.value = data
                                //结束刷新
                                self.answerY.refreshStateObserver.value = .endHeaderRefresh
                            } else {
                                switch result {
                                case .failed:
                                    //请求错误
                                    self.answerY.refreshStateObserver.value = .noData
                                default:
                                    break
                                }
                            }
                        })
                        .disposed(by: self.answerY.disposeBag)
                } else {//加载更多
                    self.answerY.pageIndex += 1
                    //拉取数据
                    self.service.getAnswer(id: self.section.id!, pageIndex: self.answerY.pageIndex, side: .SY)
                        .subscribe(onNext: { response in
                            let data = response.0
                            // let result = response.1
                            if data.count > 0 {
                                self.answerY.models.value += data
                                //结束刷新
                                self.answerY.refreshStateObserver.value = .endFooterRefresh
                            } else {//没有更多数据
                                //结束刷新
                                self.answerY.refreshStateObserver.value = .endRefreshWithoutData
                            }
                        })
                        .disposed(by: self.answerY.disposeBag)
                }
            })
            .disposed(by: self.answerY.disposeBag)
        self.answerY.refreshStateObserver.asObservable()
            .subscribe(onNext: { state in
                switch state {
                case .noData:
                    self.outputsY.emptyStateObserver.value = .empty
                    break
                case .beginHeaderRefresh:
                    break
                case .endHeaderRefresh:
                    self.answerY.tableView.switchRefreshHeader(to: .normal(.success, 0))
                    break
                case .beginFooterRefresh:
                    break
                case .endFooterRefresh:
                    self.answerY.tableView.switchRefreshFooter(to: .normal)
                    break
                case .endRefreshWithoutData:
                    self.answerY.tableView.switchRefreshFooter(to: .noMoreData)
                    break
                default:
                    break
                }
            })
            .disposed(by: self.answerY.disposeBag)
    }
    public func initAnswerS(answer: (disposeBag: DisposeBag, tableView: UITableView, emptyView: EmptyView)) {
        self.answerS = DebateAnswerModel(pageIndex: 0, models: Variable<[Answer]>([]), disposeBag: answer.disposeBag, tableView: answer.tableView, emptyView: answer.emptyView, refreshStateObserver: Variable<RefreshStatus>(.none))
        //Rx
        self.outputsS.sections = self.answerS.models.asObservable()
            .map{ models -> [DebateDetailSectionModel] in
                return [DebateDetailSectionModel(items: models)]
            }
            .asDriver(onErrorJustReturn: [])
        self.inputsS.refreshNewData.asObserver()
            .subscribe(onNext: { full in
                if full {//头部刷新
                    self.answerS.refreshStateObserver.value = .endFooterRefresh
                    //初始化
                    self.answerS.pageIndex = 0
                    //拉取数据
                    self.service.getAnswer(id: self.section.id!, pageIndex: self.answerS.pageIndex, side: .SY)
                        .subscribe(onNext: { response in
                            let data = response.0
                            let result = response.1
                            if data.count > 0 {
                                self.answerS.models.value.removeAll()
                                self.answerS.models.value = data
                                //结束刷新
                                self.answerS.refreshStateObserver.value = .endHeaderRefresh
                            } else {
                                switch result {
                                case .failed:
                                    //没有数据
                                    self.answerS.refreshStateObserver.value = .noData
                                default:
                                    break
                                }
                            }
                        })
                        .disposed(by: self.answerS.disposeBag)
                } else {//加载更多
                    self.answerS.pageIndex += 1
                    //拉取数据
                    self.service.getAnswer(id: self.section.id!, pageIndex: self.answerS.pageIndex, side: .SY)
                        .subscribe(onNext: { response in
                            let data = response.0
                            // let result = response.1
                            if data.count > 0 {
                                self.answerS.models.value += data
                                //结束刷新
                                self.answerS.refreshStateObserver.value = .endFooterRefresh
                            } else {//没有更多数据
                                //结束刷新
                                self.answerS.refreshStateObserver.value = .endRefreshWithoutData
                            }
                        })
                        .disposed(by: self.answerS.disposeBag)
                }
            })
            .disposed(by: self.answerS.disposeBag)
        self.answerS.refreshStateObserver.asObservable()
            .subscribe(onNext: { state in
                switch state {
                case .noData:
                    self.outputsS.emptyStateObserver.value = .empty
                    break
                case .beginHeaderRefresh:
                    break
                case .endHeaderRefresh:
                    self.answerS.tableView.switchRefreshHeader(to: .normal(.success, 0))
                    break
                case .beginFooterRefresh:
                    break
                case .endFooterRefresh:
                    self.answerS.tableView.switchRefreshFooter(to: .normal)
                    break
                case .endRefreshWithoutData:
                    self.answerS.tableView.switchRefreshFooter(to: .noMoreData)
                    break
                default:
                    break
                }
            })
            .disposed(by: self.answerS.disposeBag)
    }
}

public struct DebateDetailSectionModel {
    public var items: [item]
}

extension DebateDetailSectionModel: SectionModelType {
    public typealias item = Answer
    
    public init(original: DebateDetailSectionModel, items: [DebateDetailSectionModel.item]) {
        self = original
        self.items = items
    }
}

