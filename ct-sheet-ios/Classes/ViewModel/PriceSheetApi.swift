//
//  PriceSheetApi.swift
//  ct-sheet-ios
//
//  Created by qingping yi on 2021/8/24.
//

import Foundation
import ct_net_ios
import Moya
import RxSwift
import ct_common_ios

public enum PriceSheetApi {
    // 房价看板
    case housePriceConsoleApi(curPage: Int, productIds: [String]?, channels: [Int]? ,fromDate: Int ,endDate: Int)

    // 修改房价
    case housePriceUpdateApi(productId: String, dates: [Int], channel: Int ,price: Int)

}

extension PriceSheetApi: TargetType, AuthenticationProtocol{
    
    public var method: Moya.Method {
        switch self {
            default:
                return .post
        }
    }
    
    public var task: Task {
        var params:[String : Any] = [:]
        switch self {
            
            // 房价看板
            case .housePriceConsoleApi(let curPage,let productIds,let channels ,let fromDate, let endDate):
                params["_meta"] = ["page":curPage, "limit":30]
                params["from_date"] = fromDate
                params["end_date"] = endDate
                if let productIds = productIds, productIds.count > 0 {
                    params["product_ids"] = productIds
                }

                if let channels = channels, channels.count > 0{
                    params["channels"] = channels
                }
                
            case .housePriceUpdateApi(let productId,let dates,let channel ,let price):
                params["product_id"] = productId
                params["dates"] = dates
                params["channel"] = channel
                params["price"] = price

        }
        return .requestParameters(parameters: params, encoding: JSONEncoding.default)
    }
    
    public var headers: [String : String]? {
        switch self {
            
            // 房价看板
            case .housePriceConsoleApi(_,_,_,_,_):
                return [
                    "X-CMD": "ct-tob.house.price.console"
                ]
                
            // 改价
            case .housePriceUpdateApi(_,_,_,_):
                return [
                    "X-CMD": "ct-tob.house.price.update_price"
                ]
        }
    }
    public var authenticationType: AuthenticationType?{
        return .xToken
    }
}

