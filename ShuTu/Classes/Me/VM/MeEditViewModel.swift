//
//  MeEditViewModel.swift
//  ShuTu
//
//  Created by yiqiang on 2018/3/14.
//  Copyright © 2018年 yiqiang. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

public struct MeEditViewModelInput {
    var saveTap: PublishSubject<[String: Any]>
}
public struct MeEditViewModelOutput {
    var saveResult: Variable<ResultType>
}
public class MeEditViewModel {

    //MARK: - 私有成员
    fileprivate struct MeEditModel {
        var disposeBag: DisposeBag
    }
    fileprivate var editModel: MeEditModel!
    fileprivate var service = MeService.instance

    //MARK: - Inputs
    open var inputs: MeEditViewModelInput = {
        return MeEditViewModelInput(saveTap: PublishSubject<[String: Any]>())
    }()

    //MARK: - Outputs
    open var outputs: MeEditViewModelOutput = {
        return MeEditViewModelOutput(saveResult: Variable<ResultType>(.none))
    }()
    
    init(disposeBag: DisposeBag) {
        self.editModel = MeEditModel(disposeBag: disposeBag)
        //Rx
        self.inputs.saveTap.asObserver()
            .subscribe(onNext: { infos in
                HUD.show(.progress)
                self.service.setuserinfo(infos)
                    .subscribe(onNext: { [unowned self] result in
                        self.outputs.saveResult.value = result
                    })
                    .disposed(by: self.editModel.disposeBag)
            })
            .disposed(by: editModel.disposeBag)
    }
}

