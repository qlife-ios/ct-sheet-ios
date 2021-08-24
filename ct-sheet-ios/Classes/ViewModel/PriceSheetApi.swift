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
    case housePriceConsoleApi(curPage: Int, productIds: [String]?, channels: [String]? ,fromDate: Int ,endDate: Int)

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
                if let productIds = productIds {
                    params["product_ids"] = productIds
                }

                if let channels = channels{
                    params["channels"] = channels
                }
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
        }
    }
    public var authenticationType: AuthenticationType?{
        return .xToken
    }
}

