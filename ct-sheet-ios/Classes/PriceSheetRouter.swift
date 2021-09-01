//
//  PriceSheetRouter.swift
//  ct-sheet-ios
//
//  Created by qingping yi on 2021/8/31.
//

import UIKit
import Foundation
import URLNavigator
import ct_common_ios

public struct PriceSheetRouter {
    
    public static func initialize() {
        // 房价看板
        navigator.register("PriceSheetVCRouter".routerUrl) { url, values,context in
            let vc = PriceSheetVC()
            vc.hidesBottomBarWhenPushed = true
            return vc
        }
    }
}
