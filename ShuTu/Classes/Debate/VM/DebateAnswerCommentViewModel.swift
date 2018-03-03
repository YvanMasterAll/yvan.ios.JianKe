//
//  DebateCommentViewModel.swift
//  ShuTu
//
//  Created by yiqiang on 2017/12/30.
//  Copyright © 2017年 yiqiang. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import RxDataSources

public struct DebateCommentViewModelInput {
    var refreshNewData: PublishSubject<Bool>
    var supportTap: PublishSubject<(Bool, Int)>
    var sendTap: PublishSubject<String>
}
public struct DebateCommentViewModelOutput {
    var sections: Driver<[CommentSectionModel]>?
    var emptyStateObserver: Variable<EmptyViewType>
    var supportResult: Variable<Result2>
    var sendResult: Variable<Result2>
}
class DebateCommentViewModel {
    fileprivate struct CommentModel {
        var pageIndex: Int
        var disposeBag: DisposeBag
        var models: Variable<[AnswerComment]>
        var section: Answer
        var refreshStateObserver: Variable<RefreshStatus>
        var tableView: UITableView
    }
    //私有成员
    fileprivate var commentModel: CommentModel!
    fileprivate var service = DebateService.instance
    //inputs
    public var inputs: DebateCommentViewModelInput! = {
        return DebateAnswerCommentViewModelInput(refreshNewData: PublishSubject(), supportTap: PublishSubject(), sendTap: PublishSubject())
    }()
    //outputs
    public var outputs: DebateCommentViewModelOutput! = {
        return DebateAnswerCommentViewModelOutput(sections: nil, emptyStateObserver: Variable<EmptyViewType>(.none), supportResult: Variable<Result2>(.none), sendResult: Variable<Result2>(.none))
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
                    self.answerComment.pageIndex = 1
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
        self.inputs.sendTap.asObserver()
            .subscribe(onNext: { content in
                guard Environment.tokenExists  else {
                    HUD.flash(.label("请先登录"))
                    return
                }
                HUD.show(.progress)
                self.service.commentAdd(id: self.answerComment.section.id!, content: content)
                    .subscribe(onNext: { result in
                        HUD.hide()
                        self.outputs.sendResult.value = result
                    })
                    .disposed(by: self.answerComment.disposeBag)
            })
            .disposed(by: disposeBag)
        self.inputs.supportTap.asObserver()
            .subscribe(onNext: { (add, id) in
                guard Environment.tokenExists  else {
                    HUD.flash(.label("请先登录"))
                    return
                }
                if add {
                    self.service.attitudeAdd(id, attitude: AttitudeStand.support, type: AttitudeType.comment, toggle: Toggle.on)
                        .subscribe(onNext: { response in
                            HUD.hide()
                            let result = response.1
                            //let data = response.0
                            self.outputs.supportResult.value = result
                        })
                        .disposed(by: self.answerComment.disposeBag)
                } else {
                    self.service.attitudeAdd(id, attitude: AttitudeStand.support, type: AttitudeType.comment, toggle: Toggle.off)
                        .subscribe(onNext: { response in
                            HUD.hide()
                            let result = response.1
                            //let data = response.0
                            self.outputs.supportResult.value = result
                        })
                        .disposed(by: self.answerComment.disposeBag)
                }
            })
            .disposed(by: disposeBag)
        self.answerComment.refreshStateObserver.asObservable()
            .subscribe(onNext: { state in
                switch state {
                case .noData:
                    self.outputs.emptyStateObserver.value = .empty(size: nil)
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

public struct DebateAnswerComment2ViewModelInput {
    var refreshNewData: PublishSubject<Bool>
    var sendTap: PublishSubject<String>
}
public struct DebateAnswerComment2ViewModelOutput {
    var sections: Driver<[AnswerComment2SectionModel]>?
    var emptyStateObserver: Variable<EmptyViewType>
    var sendResult: Variable<Result2>
}
class DebateAnswerComment2ViewModel {
    fileprivate struct AnswerCommentModel {
        var pageIndex: Int
        var disposeBag: DisposeBag
        var models: Variable<[AnswerComment]>
        var section: AnswerComment
        var refreshStateObserver: Variable<RefreshStatus>
        var tableView: UITableView
    }
    //私有成员
    fileprivate var answerComment: AnswerCommentModel!
    fileprivate var service = DebateService.instance
    //inputs
    public var inputs: DebateAnswerComment2ViewModelInput! = {
        return DebateAnswerComment2ViewModelInput(refreshNewData: PublishSubject(), sendTap: PublishSubject<String>())
    }()
    //outputs
    public var outputs: DebateAnswerComment2ViewModelOutput! = {
        return DebateAnswerComment2ViewModelOutput(sections: nil, emptyStateObserver: Variable<EmptyViewType>(.none), sendResult: Variable<Result2>(.none))
    }()
    
    init(disposeBag: DisposeBag, section: AnswerComment, tableView: UITableView) {
        //初始化
        self.answerComment = AnswerCommentModel(pageIndex: 0, disposeBag: disposeBag, models: Variable<[AnswerComment]>([]), section: section, refreshStateObserver: Variable<RefreshStatus>(.none), tableView: tableView)
        self.outputs.emptyStateObserver = Variable<EmptyViewType>(.none)
        //Rx
        self.outputs.sections = self.answerComment.models.asObservable()
            .map{ models in
                return [AnswerComment2SectionModel.init(items: models)]
            }
            .asDriver(onErrorJustReturn: [])
        self.inputs.refreshNewData.asObserver()
            .subscribe(onNext: { full in
                if full {//头部刷新
                    self.answerComment.refreshStateObserver.value = .endFooterRefresh
                    //初始化
                    self.answerComment.pageIndex = 1
                    //拉取数据
                    self.service.getDeepComment(id: self.answerComment.section.id!, pageIndex: self.answerComment.pageIndex)
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
        self.inputs.sendTap.asObserver()
            .subscribe(onNext: { content in
                guard Environment.tokenExists  else {
                    HUD.flash(.label("请先登录"))
                    return
                }
                HUD.show(.progress)
                self.service.commentAdd(id: self.answerComment.section.vpid!, cmid: self.answerComment.section.id!, content: content)
                    .subscribe(onNext: { result in
                        HUD.hide()
                        self.outputs.sendResult.value = result
                    })
                    .disposed(by: self.answerComment.disposeBag)
            })
            .disposed(by: disposeBag)
        self.answerComment.refreshStateObserver.asObservable()
            .subscribe(onNext: { state in
                switch state {
                case .noData:
                    self.outputs.emptyStateObserver.value = .empty(size: nil)
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

public struct AnswerComment2SectionModel {
    public var items: [item]
}

extension AnswerComment2SectionModel: SectionModelType {
    public typealias item = AnswerComment
    
    public init(original: AnswerComment2SectionModel, items: [AnswerComment2SectionModel.item]) {
        self = original
        self.items = items
    }
}
