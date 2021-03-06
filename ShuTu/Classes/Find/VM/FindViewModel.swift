//
//  FindViewModel.swift
//  ShuTu
//
//  Created by yiqiang on 2018/2/8.
//  Copyright © 2018年 yiqiang. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

public struct FindViewModelInput {
    var refreshNewData1: PublishSubject<Bool>
    var refreshNewData2: PublishSubject<Bool>
    var refreshNewData3: PublishSubject<Bool>
    var voteTap: PublishSubject<(Int, AttitudeStand)>
    var followTap: PublishSubject<(Int, Bool)>
}
public struct FindViewModelOutput {
    var models1: Variable<([Debate], ResultType)>
    var models2: Variable<([DebateCollect], ResultType)>
    var models3: Variable<([User], ResultType)>
    var voteResult: Variable<ResultType>
    var followResult: Variable<ResultType>
}
public class FindViewModel {

    //MARK: - 私有成员
    fileprivate struct FindModel {
        var disposeBag: DisposeBag
    }
    fileprivate var findModel: FindModel!
    fileprivate var service = FindService.instance
    fileprivate var fservice = FriendService.instance

    //MARK: - Inputs
    open var inputs: FindViewModelInput = {
        return FindViewModelInput(refreshNewData1: PublishSubject<Bool>(), refreshNewData2: PublishSubject<Bool>(), refreshNewData3: PublishSubject<Bool>(), voteTap: PublishSubject<(Int, AttitudeStand)>(), followTap: PublishSubject<(Int, Bool)>())
    }()

    //MARK: - Outputs
    open var outputs: FindViewModelOutput = {
        return FindViewModelOutput.init(models1: Variable<([Debate], ResultType)>(([], ResultType.empty)), models2: Variable<([DebateCollect], ResultType)>(([], ResultType.empty)), models3: Variable<([User], ResultType)>(([], ResultType.empty)), voteResult: Variable<ResultType>(.none), followResult: Variable<ResultType>(.none))
    }()
    
    init(disposeBag: DisposeBag) {
        self.findModel = FindModel(disposeBag: disposeBag)
        //Rx
        self.inputs.refreshNewData1.asObserver()
            .subscribe(onNext: { _ in
                //拉取数据
                self.service.findTopic()
                    .subscribe(onNext: { response in
                        self.outputs.models1.value = response
                    })
                    .disposed(by: self.findModel.disposeBag)
            })
            .disposed(by: findModel.disposeBag)
        self.inputs.refreshNewData2.asObserver()
            .subscribe(onNext: { _ in
                //拉取数据
                self.service.findCollect()
                    .subscribe(onNext: { response in
                        self.outputs.models2.value = response
                    })
                    .disposed(by: self.findModel.disposeBag)
            })
            .disposed(by: findModel.disposeBag)
        self.inputs.refreshNewData3.asObserver()
            .subscribe(onNext: { _ in
                //拉取数据
                self.service.findPerson()
                    .subscribe(onNext: { response in
                        self.outputs.models3.value = response
                    })
                    .disposed(by: self.findModel.disposeBag)
            })
            .disposed(by: findModel.disposeBag)
        self.inputs.voteTap.asObserver()
            .subscribe(onNext: { (id, attitude) in
                guard Environment.tokenExists  else {
                    HUD.flash(.label("请先登录"))
                    return
                }
                HUD.show(.progress)
                self.service.vote(id, attitude)
                    .subscribe(onNext: { result in
                        HUD.hide()
                        self.outputs.voteResult.value = result
                    })
                    .disposed(by: self.findModel.disposeBag)
            })
            .disposed(by: self.findModel.disposeBag)
        self.inputs.followTap.asObserver()
            .subscribe(onNext: { (id, add) in
                guard Environment.tokenExists  else {
                    HUD.flash(.label("请先登录"))
                    return
                }
                HUD.show(.progress)
                if add {
                    self.fservice.followAdd(id, Toggle.on)
                        .subscribe(onNext: { result in
                            HUD.hide()
                            self.outputs.followResult.value = result
                        })
                        .disposed(by: self.findModel.disposeBag)
                } else {
                    self.fservice.followAdd(id, Toggle.off)
                        .subscribe(onNext: { result in
                            HUD.hide()
                            self.outputs.followResult.value = result
                        })
                        .disposed(by: self.findModel.disposeBag)
                }
            })
            .disposed(by: self.findModel.disposeBag)
    }
}
