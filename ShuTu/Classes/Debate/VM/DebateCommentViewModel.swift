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
        return DebateCommentViewModelInput(refreshNewData: PublishSubject(), supportTap: PublishSubject(), sendTap: PublishSubject())
    }()
    //outputs
    public var outputs: DebateCommentViewModelOutput! = {
        return DebateCommentViewModelOutput(sections: nil, emptyStateObserver: Variable<EmptyViewType>(.none), supportResult: Variable<Result2>(.none), sendResult: Variable<Result2>(.none))
    }()
    
    init(disposeBag: DisposeBag, section: Answer, tableView: UITableView) {
        //初始化
        self.commentModel = CommentModel(pageIndex: 0, disposeBag: disposeBag, models: Variable<[AnswerComment]>([]), section: section, refreshStateObserver: Variable<RefreshStatus>(.none), tableView: tableView)
        self.outputs.emptyStateObserver = Variable<EmptyViewType>(.none)
        //Rx
        self.outputs.sections = self.commentModel.models.asObservable()
            .map{ models in
                return [CommentSectionModel.init(items: models)]
            }
            .asDriver(onErrorJustReturn: [])
        self.inputs.refreshNewData.asObserver()
            .subscribe(onNext: { full in
                if full {//头部刷新
                    self.commentModel.refreshStateObserver.value = .endFooterRefresh
                    //初始化
                    self.commentModel.pageIndex = 1
                    //拉取数据
                    self.service.getAnswerComment(id: self.commentModel.section.id!, pageIndex: self.commentModel.pageIndex)
                        .subscribe(onNext: { response in
                            let data = response.0
                            let result = response.1
                            switch result {
                            case .ok:
                                self.commentModel.models.value.removeAll()
                                self.commentModel.models.value = data
                                //结束刷新
                                self.commentModel.refreshStateObserver.value = .endHeaderRefresh
                                break
                            default:
                                //请求错误
                                self.commentModel.refreshStateObserver.value = .noData
                                break
                            }
                        })
                        .disposed(by: self.commentModel.disposeBag)
                } else {//加载更多
                    self.commentModel.pageIndex += 1
                    //拉取数据
                    self.service.getAnswerComment(id: self.commentModel.section.id!, pageIndex: self.commentModel.pageIndex)
                        .subscribe(onNext: { response in
                            let data = response.0
                            let result = response.1
                            switch result {
                            case .ok:
                                if data.count > 0 {
                                    self.commentModel.models.value += data
                                    //结束刷新
                                    self.commentModel.refreshStateObserver.value = .endFooterRefresh
                                } else {
                                    //没有更多数据
                                    self.commentModel.refreshStateObserver.value = .endRefreshWithoutData
                                }
                                break
                            default:
                                //没有更多数据
                                self.commentModel.refreshStateObserver.value = .endRefreshWithoutData
                                break
                            }
                        })
                        .disposed(by: self.commentModel.disposeBag)
                }
            })
            .disposed(by: commentModel.disposeBag)
        self.inputs.sendTap.asObserver()
            .subscribe(onNext: { content in
                guard Environment.tokenExists  else {
                    HUD.flash(.label("请先登录"))
                    return
                }
                HUD.show(.progress)
                self.service.commentAdd(id: self.commentModel.section.id!, content: content)
                    .subscribe(onNext: { result in
                        HUD.hide()
                        self.outputs.sendResult.value = result
                    })
                    .disposed(by: self.commentModel.disposeBag)
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
                        .disposed(by: self.commentModel.disposeBag)
                } else {
                    self.service.attitudeAdd(id, attitude: AttitudeStand.support, type: AttitudeType.comment, toggle: Toggle.off)
                        .subscribe(onNext: { response in
                            HUD.hide()
                            let result = response.1
                            //let data = response.0
                            self.outputs.supportResult.value = result
                        })
                        .disposed(by: self.commentModel.disposeBag)
                }
            })
            .disposed(by: disposeBag)
        self.commentModel.refreshStateObserver.asObservable()
            .subscribe(onNext: { state in
                switch state {
                case .noData:
                    self.outputs.emptyStateObserver.value = .empty(size: nil)
                    break
                case .beginHeaderRefresh:
                    break
                case .endHeaderRefresh:
                    self.commentModel.tableView.switchRefreshHeader(to: .normal(.success, 0))
                    break
                case .beginFooterRefresh:
                    break
                case .endFooterRefresh:
                    self.commentModel.tableView.switchRefreshFooter(to: .normal)
                    break
                case .endRefreshWithoutData:
                    self.commentModel.tableView.switchRefreshFooter(to: .noMoreData)
                    break
                default:
                    break
                }
            })
            .disposed(by: disposeBag)
    }
    
}

public struct CommentSectionModel {
    public var items: [item]
}

extension CommentSectionModel: SectionModelType {
    public typealias item = AnswerComment
    
    public init(original: CommentSectionModel, items: [CommentSectionModel.item]) {
        self = original
        self.items = items
    }
}

public struct DebateComment2ViewModelInput {
    var refreshNewData: PublishSubject<Bool>
    var sendTap: PublishSubject<String>
}
public struct DebateComment2ViewModelOutput {
    var sections: Driver<[Comment2SectionModel]>?
    var emptyStateObserver: Variable<EmptyViewType>
    var sendResult: Variable<Result2>
}
class DebateComment2ViewModel {
    fileprivate struct CommentModel {
        var pageIndex: Int
        var disposeBag: DisposeBag
        var models: Variable<[AnswerComment]>
        var section: AnswerComment
        var refreshStateObserver: Variable<RefreshStatus>
        var tableView: UITableView
    }
    //私有成员
    fileprivate var commentModel: CommentModel!
    fileprivate var service = DebateService.instance
    //inputs
    public var inputs: DebateComment2ViewModelInput! = {
        return DebateComment2ViewModelInput(refreshNewData: PublishSubject(), sendTap: PublishSubject<String>())
    }()
    //outputs
    public var outputs: DebateComment2ViewModelOutput! = {
        return DebateComment2ViewModelOutput(sections: nil, emptyStateObserver: Variable<EmptyViewType>(.none), sendResult: Variable<Result2>(.none))
    }()
    
    init(disposeBag: DisposeBag, section: AnswerComment, tableView: UITableView) {
        //初始化
        self.commentModel = CommentModel(pageIndex: 0, disposeBag: disposeBag, models: Variable<[AnswerComment]>([]), section: section, refreshStateObserver: Variable<RefreshStatus>(.none), tableView: tableView)
        self.outputs.emptyStateObserver = Variable<EmptyViewType>(.none)
        //Rx
        self.outputs.sections = self.commentModel.models.asObservable()
            .map{ models in
                return [Comment2SectionModel.init(items: models)]
            }
            .asDriver(onErrorJustReturn: [])
        self.inputs.refreshNewData.asObserver()
            .subscribe(onNext: { full in
                if full {//头部刷新
                    self.commentModel.refreshStateObserver.value = .endFooterRefresh
                    //初始化
                    self.commentModel.pageIndex = 1
                    //拉取数据
                    self.service.getDeepComment(id: self.commentModel.section.id!, pageIndex: self.commentModel.pageIndex)
                        .subscribe(onNext: { response in
                            let data = response.0
                            let result = response.1
                            switch result {
                            case .ok:
                                self.commentModel.models.value.removeAll()
                                self.commentModel.models.value = data
                                //结束刷新
                                self.commentModel.refreshStateObserver.value = .endHeaderRefresh
                                break
                            default:
                                //请求错误
                                self.commentModel.refreshStateObserver.value = .noData
                                break
                            }
                        })
                        .disposed(by: self.commentModel.disposeBag)
                } else {//加载更多
                    self.commentModel.pageIndex += 1
                    //拉取数据
                    self.service.getAnswerComment(id: self.commentModel.section.id!, pageIndex: self.commentModel.pageIndex)
                        .subscribe(onNext: { response in
                            let data = response.0
                            let result = response.1
                            switch result {
                            case .ok:
                                if data.count > 0 {
                                    self.commentModel.models.value += data
                                    //结束刷新
                                    self.commentModel.refreshStateObserver.value = .endFooterRefresh
                                } else {
                                    //没有更多数据
                                    self.commentModel.refreshStateObserver.value = .endRefreshWithoutData
                                }
                                break
                            default:
                                //没有更多数据
                                self.commentModel.refreshStateObserver.value = .endRefreshWithoutData
                                break
                            }
                        })
                        .disposed(by: self.commentModel.disposeBag)
                }
            })
            .disposed(by: commentModel.disposeBag)
        self.inputs.sendTap.asObserver()
            .subscribe(onNext: { content in
                guard Environment.tokenExists  else {
                    HUD.flash(.label("请先登录"))
                    return
                }
                HUD.show(.progress)
                self.service.commentAdd(id: self.commentModel.section.vpid!, cmid: self.commentModel.section.id!, content: content)
                    .subscribe(onNext: { result in
                        HUD.hide()
                        self.outputs.sendResult.value = result
                    })
                    .disposed(by: self.commentModel.disposeBag)
            })
            .disposed(by: self.commentModel.disposeBag)
        self.commentModel.refreshStateObserver.asObservable()
            .subscribe(onNext: { state in
                switch state {
                case .noData:
                    self.outputs.emptyStateObserver.value = .empty(size: nil)
                    break
                case .beginHeaderRefresh:
                    break
                case .endHeaderRefresh:
                    self.commentModel.tableView.switchRefreshHeader(to: .normal(.success, 0))
                    break
                case .beginFooterRefresh:
                    break
                case .endFooterRefresh:
                    self.commentModel.tableView.switchRefreshFooter(to: .normal)
                    break
                case .endRefreshWithoutData:
                    self.commentModel.tableView.switchRefreshFooter(to: .noMoreData)
                    break
                default:
                    break
                }
            })
            .disposed(by: self.commentModel.disposeBag)
    }
    
}

public struct Comment2SectionModel {
    public var items: [item]
}

extension Comment2SectionModel: SectionModelType {
    public typealias item = AnswerComment
    
    public init(original: Comment2SectionModel, items: [Comment2SectionModel.item]) {
        self = original
        self.items = items
    }
}
