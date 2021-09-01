//
//  PriceSheetVC.swift
//  AFNetworking
//
//  Created by qingping yi on 2021/8/24.
//

// 房价管理

//    var leftTableView: UITableView = UITableView.init() // 左侧标题tableview
//    var rightTableView: UITableView = UITableView.init() // 右侧内容tableview
//    var rightContentView: UIScrollView = UIScrollView.init() // 右侧底部内容容器
    
//    var contentSizeWidth: CGFloat = 0 // 宽


import Foundation
import UIKit
import RxSwift
import RxCocoa
import ct_common_ios
import RxViewController
import Toast_Swift
import boss_basic_common_ios

public class PriceSheetVC: BossViewController {
    
    private var priceHouseEvent = PublishSubject<(curPage: Int, productIds: [String]?, channels: [String]? ,fromDate: Int ,endDate: Int)>()
    
    var viewModel: PriceSheetViewModel?

    private let disposeBag = DisposeBag()
    
    var linkageSheetView: CXLinkageSheetView = CXLinkageSheetView.init()
    
    var leftDataArray: [String] = []
    
    var rightDataArray: [String] = []

    var rightDetailArray: [[String]] = []
    
    public override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func setupUI() {
        
        for i in 1...20 {
            self.leftDataArray.append("左边\(i)")
        }
        
        for i in 1...20 {
            self.rightDataArray.append("右上边\(i)")
        }
        
        for i in 1...20{
            var arrM: [String] = []
            for j in 1...20 {
                arrM.append("内容\(i)--\(j)")
            }
            self.rightDetailArray.append(arrM)
        }
        
        self.linkageSheetView = CXLinkageSheetView.init(frame: CGRect.init(x: 0, y: 0, width: kScreenWidth, height: kScreenHeight - 100))
        self.linkageSheetView.center = self.view.center
        self.view.addSubview(self.linkageSheetView)
        self.linkageSheetView.sheetHeaderHeight = 60
        self.linkageSheetView.sheetRowHeight = 50
        self.linkageSheetView.sheetLeftTableWidth = 120
        self.linkageSheetView.sheetRightTableWidth = 120
        self.linkageSheetView.showAllSheetBorder = true
        self.linkageSheetView.pagingEnabled = true
        self.linkageSheetView.leftTableCount = self.leftDataArray.count
        self.linkageSheetView.rightTableCount = self.rightDataArray.count
        self.linkageSheetView.dataSource = self
        self.linkageSheetView.showScrollShadow = true
        self.linkageSheetView.reloadData()
        
    }
    
    func bindViewModel() {
        let input = PriceSheetViewModel.input(housePriceConsoleObservable: self.priceHouseEvent)
        self.viewModel = PriceSheetViewModel.init(input: input)
        self.viewModel?.housePricesOutput.subscribe(onNext:{[unowned self] (arr)  in
            
            
            
        }).disposed(by: disposeBag)
       
        
    }
}

extension PriceSheetVC: CXLinkageSheetViewDataSource {
    
    public func createLeftItem(withContentView contentView: UIView?, indexPath: IndexPath?) -> UIView? {
        var lab: UILabel = UILabel.init(frame: CGRect.init(x: 0, y: 0, width: contentView?.width ?? 0, height: contentView?.height ?? 0))
        if self.leftDataArray.count > 0 {
            if  let index = indexPath{
                lab.text = self.leftDataArray[index.row]
            }
        }
        return lab
    }
    
    public func createRightItem(withContentView contentView: UIView?, indexPath: IndexPath?, itemIndex: Int) -> UIView? {
        let lab: UILabel = UILabel.init(frame: CGRect.init(x: 0, y: 0, width: contentView?.width ?? 0, height: contentView?.height ?? 0))
        if self.leftDataArray.count > 0 {
            if  let index = indexPath{
                lab.text = "内容呀"
            }
        }
        return lab
    }
    
    
    public func rightTitleView(_ titleContentView: UIView?, index: Int) -> UIView? {
        let lab: UILabel = UILabel.init(frame: CGRect.init(x: 0, y: 0, width: titleContentView?.width ?? 0, height: titleContentView?.height ?? 0))
        if self.leftDataArray.count > 0 {
                lab.text = self.rightDataArray[index]
        }
        return lab
    }
    
    public func leftTitleView(_ titleContentView: UIView?) -> UIView? {
        let lab: UILabel = UILabel.init(frame: CGRect.init(x: 0, y: 0, width: titleContentView?.width ?? 0, height: titleContentView?.height ?? 0))
        lab.text = "标题呀"
        return lab
    }
    
    
    
}
