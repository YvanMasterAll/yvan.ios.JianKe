//
//  DebateInviteViewModel.swift
//  ShuTu
//
//  Created by yiqiang on 2018/1/15.
//  Copyright © 2018年 yiqiang. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import RxDataSources

public struct DebateInviteViewModelInput {
    var refreshNewData: PublishSubject<Bool>
}
public struct DebateInviteViewModelOutput {
    var sections: Driver<[DebateInviteSectionModel]>?
    var refreshStateObserver: Variable<RefreshStatus>
}
public class DebateInviteViewModel {

    //MARK: - 私有成员
    fileprivate struct InviteModel {
        var pageIndex: Int
        var disposeBag: DisposeBag
        var models: Variable<[User]>
    }
    fileprivate var inviteModel: InviteModel!
    fileprivate var service = FriendService.instance

    //MARK: - Inputs
    open var inputs: DebateInviteViewModelInput = {
        return DebateInviteViewModelInput(refreshNewData: PublishSubject<Bool>())
    }()
    
    //MARK: - Outputs
    open var outputs: DebateInviteViewModelOutput = {
        return DebateInviteViewModelOutput(sections: nil, refreshStateObserver: Variable<RefreshStatus>(.none))
    }()
    
    init(disposeBag: DisposeBag) {
        self.inviteModel = InviteModel(pageIndex: 0, disposeBag: disposeBag, models: Variable<[User]>([]))
        //Rx
        self.outputs.sections = self.inviteModel.models.asObservable()
            .map{ models in
                return [DebateInviteSectionModel.init(items: models)]
            }
            .asDriver(onErrorJustReturn: [])
        self.inputs.refreshNewData.asObserver()
            .subscribe(onNext: { full in
                if full { //头部刷新
                    self.outputs.refreshStateObserver.value = .endFooterRefresh
                    //初始化
                    self.inviteModel.pageIndex = 1
                    //拉取数据
                    self.service.getFriend(id: 0, pageIndex: self.inviteModel.pageIndex)
                        .subscribe(onNext: { response in
                            let data = response.0
                            let result = response.1
                            switch result {
                            case .ok:
                                if data.count > 0 {
                                    self.inviteModel.models.value.removeAll()
                                    self.inviteModel.models.value = data
                                    //结束刷新
                                    self.outputs.refreshStateObserver.value = .endHeaderRefresh
                                } else {
                                    self.outputs.refreshStateObserver.value = .noData
                                }
                                break
                            default:
                                //请求错误
                                self.outputs.refreshStateObserver.value = .noNet
                                break
                            }
                        })
                        .disposed(by: self.inviteModel.disposeBag)
                } else { //加载更多
                    self.inviteModel.pageIndex += 1
                    //拉取数据
                    self.service.getFriend(id: 0, pageIndex: self.inviteModel.pageIndex)
                        .subscribe(onNext: { response in
                            let data = response.0
                            let result = response.1
                            switch result {
                            case .ok:
                                if data.count > 0 {
                                    self.inviteModel.models.value += data
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
                        .disposed(by: self.inviteModel.disposeBag)
                }
            })
            .disposed(by: inviteModel.disposeBag)
    }
}

public struct DebateInviteSectionModel {
    public var items: [item]
}

extension DebateInviteSectionModel: SectionModelType {
    public typealias item = User
    
    public init(original: DebateInviteSectionModel, items: [DebateInviteSectionModel.item]) {
        self = original
        self.items = items
    }
}
