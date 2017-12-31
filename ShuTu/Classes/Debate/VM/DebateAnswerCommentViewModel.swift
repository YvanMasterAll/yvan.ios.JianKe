//
//  DebateAnswerCommentViewModel.swift
//  ShuTu
//
//  Created by yiqiang on 2017/12/30.
//  Copyright © 2017年 yiqiang. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import RxDataSources

public struct DebateAnswerCommentViewModelInput {
    var refreshNewData: PublishSubject<Bool>
}
public struct DebateAnswerCommentViewModelOutput {
    var sections: Driver<[AnswerCommentSectionModel]>?
    var emptyStateObserver: Variable<EmptyViewType>
}
class DebateAnswerCommentViewModel {
    fileprivate struct AnswerCommentModel {
        var pageIndex: Int
        var disposeBag: DisposeBag
        var models: Variable<[AnswerComment]>
        var section: Answer
        var refreshStateObserver: Variable<RefreshStatus>
        var tableView: UITableView
    }
    //私有成员
    fileprivate var answerComment: AnswerCommentModel!
    fileprivate var service = DebateService.instance
    //inputs
    public var inputs: DebateAnswerCommentViewModelInput! = {
        return DebateAnswerCommentViewModelInput(refreshNewData: PublishSubject())
    }()
    //outputs
    public var outputs: DebateAnswerCommentViewModelOutput! = {
        return DebateAnswerCommentViewModelOutput(sections: nil, emptyStateObserver: Variable<EmptyViewType>(.none))
    }()
    
    init(disposeBag: DisposeBag, section: Answer, tableView: UITableView) {
        //初始化
        self.answerComment = AnswerCommentModel(pageIndex: 0, disposeBag: disposeBag, models: Variable<[AnswerComment]>([]), section: section, refreshStateObserver: Variable<RefreshStatus>(.none), tableView: tableView)
        self.outputs.emptyStateObserver = Variable<EmptyViewType>(.none)
        //Rx
        self.outputs.sections = self.answerComment.models.asObservable()
            .map{ models in
                return [AnswerCommentSectionModel.init(items: models)]
            }
            .asDriver(onErrorJustReturn: [])
        self.inputs.refreshNewData.asObserver()
            .subscribe(onNext: { full in
                if full {//头部刷新
                    self.answerComment.refreshStateObserver.value = .endFooterRefresh
                    //初始化
                    self.answerComment.pageIndex = 0
                    //拉取数据
                    self.service.getAnswerComment(id: self.answerComment.section.id!, pageIndex: self.answerComment.pageIndex)
                        .subscribe(onNext: { response in
                            let data = response.0
                            let result = response.1
                            switch result {
                            case .ok:
                                self.answerComment.models.value.removeAll()
                                self.answerComment.models.value = data
                                //结束刷新
                                self.answerComment.refreshStateObserver.value = .endHeaderRefresh
                                break
                            default:
                                //请求错误
                                self.answerComment.refreshStateObserver.value = .noData
                                break
                            }
                        })
                        .disposed(by: self.answerComment.disposeBag)
                } else {//加载更多
                    self.answerComment.pageIndex += 1
                    //拉取数据
                    self.service.getAnswerComment(id: self.answerComment.section.id!, pageIndex: self.answerComment.pageIndex)
                        .subscribe(onNext: { response in
                            let data = response.0
                            let result = response.1
                            switch result {
                            case .ok:
                                if data.count > 0 {
                                    self.answerComment.models.value += data
                                    //结束刷新
                                    self.answerComment.refreshStateObserver.value = .endFooterRefresh
                                } else {
                                    //没有更多数据
                                    self.answerComment.refreshStateObserver.value = .endRefreshWithoutData
                                }
                                break
                            default:
                                //没有更多数据
                                self.answerComment.refreshStateObserver.value = .endRefreshWithoutData
                                break
                            }
                        })
                        .disposed(by: self.answerComment.disposeBag)
                }
            })
            .disposed(by: answerComment.disposeBag)
        self.answerComment.refreshStateObserver.asObservable()
            .subscribe(onNext: { state in
                switch state {
                case .noData:
                    self.outputs.emptyStateObserver.value = .empty
                    break
                case .beginHeaderRefresh:
                    break
                case .endHeaderRefresh:
                    self.answerComment.tableView.switchRefreshHeader(to: .normal(.success, 0))
                    break
                case .beginFooterRefresh:
                    break
                case .endFooterRefresh:
                    self.answerComment.tableView.switchRefreshFooter(to: .normal)
                    break
                case .endRefreshWithoutData:
                    self.answerComment.tableView.switchRefreshFooter(to: .noMoreData)
                    break
                default:
                    break
                }
            })
            .disposed(by: disposeBag)
    }
    
}

public struct AnswerCommentSectionModel {
    public var items: [item]
}

extension AnswerCommentSectionModel: SectionModelType {
    public typealias item = AnswerComment
    
    public init(original: AnswerCommentSectionModel, items: [AnswerCommentSectionModel.item]) {
        self = original
        self.items = items
    }
}
