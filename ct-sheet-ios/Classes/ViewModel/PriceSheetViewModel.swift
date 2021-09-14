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
    
    let housePricesOutput = PublishSubject<[DayModel]>()

    let errorObservable = PublishSubject<ErrorModel>()

    let pricesChangeOutput = PublishSubject<Bool>()
    
    let errorOutPut = PublishSubject<ErrorModel>()

    init(input: input) {
        
        input.housePriceConsoleObservable?.flatMapLatest({ para -> Single<Result<[DayModel], ErrorModel>>  in
            let request = MultiTarget(PriceSheetApi.housePriceConsoleApi(curPage: para.curPage, productIds: para.productIds, channels: para.channels, fromDate: para.fromDate, endDate: para.endDate))
            return CTAPIProvider.rx.CTrequest(request).mapArray(dataType: DayModel.self)
        }).subscribe(onNext: {[unowned self] (res) in
            switch res{
            case.success(let arr):
                self.housePricesOutput.onNext(arr)
            case.failure(let error):
                self.errorObservable.onNext(error)
            }
        }).disposed(by: disposeBag)
        
        input.housePriceChangeObservable?.flatMapLatest({ para -> Single<Result<Bool, ErrorModel>>  in
            let request = MultiTarget(PriceSheetApi.housePriceUpdateApi(productId: para.productId, dates: para.dates, channel: para.channel, price: para.price))
            return CTAPIProvider.rx.CTrequest(request).mapBool()
        }).subscribe(onNext: {[unowned self] (res) in
            switch res{
            case.success(let arr):
                self.pricesChangeOutput.onNext(arr)
            case.failure(let error):
                self.errorOutPut.onNext(error)
            }
        }).disposed(by: disposeBag)
    }
}

extension PriceSheetViewModel{
    
    struct input {
        
        // 房价看板
        let housePriceConsoleObservable: Observable<(curPage: Int, productIds: [String]?, channels: [String]? ,fromDate: Int ,endDate: Int)>?
    
        // 修改房价
        let housePriceChangeObservable: Observable<(productId: String, dates: [Int], channel: Int ,price: Int)>?

    }
    
}
