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
    
    
    var allDate: [DayModel] = []
    
    // 左上角的选中的日期
    var showDate: String?
    
    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        self.setNavColor()
    }

    public override func viewWillAppear(_ animated: Bool) {
        self.setNavColor()
        super.viewWillAppear(animated)
    }
    
    func setNavColor()  {
        let showdowColor = UIColor(named: "linecolor_E8E8E8_2B2B2B") ?? .darkGray
        self.navigationController?.navigationBar.setBackgroundColorAndshowdowColor(BackgroundColor: UIColor.white, showdowColor: showdowColor)
        if let titleColor = UIColor.init(named:"ct_000000-90_FFFFFF-90"){
            self.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor:titleColor]
        }
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.title = "房价管理"
        self.setupUI()
        self.bindViewModel()
    }
    
    func setupUI() {
        
        for i in 1...100 {
            self.leftDataArray.append("左边\(i)")
        }
        
//        for i in 1...100 {
//            self.rightDataArray.append("右上边\(i)")
//        }
        
//        for i in 1...100{
//            var arrM: [String] = []
//            for j in 1...20 {
//                arrM.append("内容\(i)--\(j)")
//            }
//            self.rightDetailArray.append(arrM)
//        }
        self.linkageSheetView = CXLinkageSheetView.init(frame: CGRect.init(x: 0, y: 0, width: kScreenWidth, height: kScreenHeight - 100))
        self.view.addSubview(self.linkageSheetView)
        self.linkageSheetView.sheetHeaderHeight = 62
        self.linkageSheetView.sheetRowHeight = 50
        self.linkageSheetView.sheetLeftTableWidth = 122
        self.linkageSheetView.sheetRightTableWidth = 52
        self.linkageSheetView.showAllSheetBorder = true
        self.linkageSheetView.pagingEnabled = true
        self.linkageSheetView.leftTableCount = self.leftDataArray.count
        self.linkageSheetView.rightTableCount = self.allDate.count
        self.linkageSheetView.dataSource = self
        self.linkageSheetView.showScrollShadow = true
        self.linkageSheetView.reloadData()
        
    }
    
    func bindViewModel() {
        
        // 今天
        let currentDate: Date = Date.init()
        self.showDate = Date.changeTimesFormatContainYearMouthDay(date: currentDate).0
        
        let startParam =  Date.changeTimesFormatContainYearMouthDay(date: currentDate).1
        // T-1 ~ T + 60
        let endDate = Date.getRequestLaterDate(from: currentDate, withYear: 0, month: 0, day: 60)
        let endParam = Date.changeTimesFormatContainYearMouthDay(date: endDate).1
        
        let input = PriceSheetViewModel.input(housePriceConsoleObservable: self.priceHouseEvent)
        self.viewModel = PriceSheetViewModel.init(input: input)
        
        self.viewModel?.housePricesOutput.subscribe(onNext:{[unowned self] (arr)  in
            self.view.dissmissLoadingView()
            self.allDate = arr
            self.linkageSheetView.leftTableCount = self.leftDataArray.count
            self.linkageSheetView.rightTableCount = self.allDate.count
            self.linkageSheetView.reloadData()

        }).disposed(by: disposeBag)
       
        self.view.showLoadingMessage(message: "加载中...")
        self.priceHouseEvent.onNext((curPage: 1, productIds: nil, channels: nil, fromDate: startParam, endDate: endParam))
    }
}

extension PriceSheetVC: CXLinkageSheetViewDataSource {
    
    // 日期选择
    public func leftTitleView(_ titleContentView: UIView?) -> UIView? {
        let contView: UIView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: titleContentView?.width ?? 0, height: titleContentView?.height ?? 0))
        let selectDate: UIGestureRecognizer = UIGestureRecognizer.init(target: self, action: Selector(("selectDate")))
        contView.addGestureRecognizer(selectDate)
        let lab: UILabel = UILabel.init(frame: CGRect.init(x: 0, y: 0, width: contView.width , height: contView.height))
        lab.textColor = UIColor.init(named: "buttonBg_F38C27")
        lab.font = UIFont.boldSystemFont(ofSize: 14)
        lab.textAlignment = .center
        lab.text = self.showDate
        contView.addSubview(lab)
        return contView
    }
    
    // 横- 日期
    public func rightTitleView(_ titleContentView: UIView?, index: Int) -> UIView? {
        
        let contView: UIView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: titleContentView?.width ?? 0, height: titleContentView?.height ?? 0))
        let lab1: UILabel = UILabel.init(frame: CGRect.init(x: 0, y: 5, width: contView.width , height: 20))
        lab1.textColor = UIColor.init(named: "ct_000000-20_FFFFFF-20")
        lab1.font = UIFont.systemFont(ofSize: 12)
        lab1.textAlignment = .center
        contView.addSubview(lab1)
        let lab2: UILabel = UILabel.init(frame: CGRect.init(x: 0, y: lab1.bottom + 5, width: contView.width , height:30))
        lab2.textColor = UIColor.init(named: "ct_000000-65")
        lab2.font = UIFont.boldSystemFont(ofSize: 16)
        lab2.textAlignment = .center
        contView.addSubview(lab2)
        
        if self.allDate.count > 0 {
            let model = self.allDate[index]
            lab1.text = model.dateName
            lab2.text = String(model.dayStr)
        }else{
            lab1.text = ""
            lab2.text = ""
        }
        return contView

    }
    
    public func createLeftItem(withContentView contentView: UIView?, indexPath: IndexPath?) -> UIView? {
        let lab: UILabel = UILabel.init(frame: CGRect.init(x: 0, y: 0, width: contentView?.width ?? 0, height: contentView?.height ?? 0))
        if self.leftDataArray.count > 0 {
            if  let index = indexPath{
                lab.text = self.leftDataArray[index.row]
            }
        }
        return lab
    }
    
    public func createRightItem(withContentView contentView: UIView?, indexPath: IndexPath?, itemIndex: Int) -> UIView? {
        
        let contView: UIView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: contentView?.width ?? 0, height: contentView?.height ?? 0))
        let lab1: UILabel = UILabel.init(frame: CGRect.init(x: 0, y: 5, width: contView.width , height: 20))
        lab1.textColor = UIColor.init(named: "ct_000000-20_FFFFFF-20")
        lab1.font = UIFont.systemFont(ofSize: 12)
        lab1.textAlignment = .center
        contView.addSubview(lab1)
        let lab2: UILabel = UILabel.init(frame: CGRect.init(x: 0, y: lab1.bottom + 5, width: contView.width , height:30))
        lab2.textColor = UIColor.init(named: "ct_000000-65")
        lab2.font = UIFont.boldSystemFont(ofSize: 16)
        lab2.textAlignment = .center
        contView.addSubview(lab2)
        
        if self.allDate.count > 0 {
            let model = self.allDate[index]
            lab1.text = model.dateName
            lab2.text = String(model.dayStr)
        }else{
            lab1.text = ""
            lab2.text = ""
        }
        return contView

    }
    
    

 
    
    
}
