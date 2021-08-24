//
//  PriceSheetViewModel.swift
//  ct-sheet-ios
//
//  Created by qingping yi on 2021/8/24.
//

import UIKit
import RxSwift
import SwiftyJSON
import boss_model_protocol_ios
import Moya
import ct_common_ios
import ct_net_ios

public class PriceSheetViewModel {
    
    let disposeBag = DisposeBag()
    
    let billDetailListOutput = PublishSubject<BillDetailListModel>()

    let billMarkOutput = PublishSubject<Bool>()

    let errorObservable = PublishSubject<ErrorModel>()

    init(input: input) {
        
        input.billMarkConfirmObservable?.flatMapLatest({ para -> Single<Result<Bool, ErrorModel>>  in
            let request = MultiTarget(BillIncomeAPi.billMarkConfirmApi(ownerBillId: para))
            return CTAPIProvider.rx.CTrequest(request).mapBool()

        }).subscribe(onNext: {[unowned self] (res) in
            switch res{
            case.success(let arr):
                self.billMarkOutput.onNext(arr)
            case.failure(let error):
                self.errorObservable.onNext(error)
            }
        }).disposed(by: disposeBag)
    }
}

extension PriceSheetViewModel{
    
    struct input {
        
        // 结算单列表
        let settlementBillObservable: Observable<(curPage: Int,ownerBillId: String, billType: Int,houseId: String? ,month: Int?, manageType: Int?, isAdvance: Bool)>?
    
    }
}
