//
//  PriceSheetVC.swift
//  AFNetworking
//
//  Created by qingping yi on 2021/8/24.
//

// 房价管理

import Foundation
import UIKit
import RxSwift
import RxCocoa
import ct_common_ios
import RxViewController
import Toast_Swift
import boss_basic_common_ios

public class PriceSheetVC: BossViewController {
    
//    var leftTableView: UITableView = UITableView.init() // 左侧标题tableview
//    var rightTableView: UITableView = UITableView.init() // 右侧内容tableview
//    var rightContentView: UIScrollView = UIScrollView.init() // 右侧底部内容容器
    
//    var contentSizeWidth: CGFloat = 0 // 宽
    
    
    var linkageSheetView: CXLinkageSheetView = CXLinkageSheetView.init()
    
    public override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func setupUI() {
        self.linkageSheetView = CXLinkageSheetView.init(frame: CGRect.init(x: 0, y: 0, width: kScreenWidth, height: kScreenHeight - 100))
        self.linkageSheetView.center = self.view.center
        self.view.addSubview(self.linkageSheetView)
        
    }
}

extension PriceSheetVC: CXLinkageSheetViewDataSource {
    
    
}
