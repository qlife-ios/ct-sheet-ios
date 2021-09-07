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
    
    private var priceHouseEvent = PublishSubject<(curPage: Int, productIds: [String]?, channels: [String]? ,fromDate: Int ,endDate: Int)>()
    
    var viewModel: PriceSheetViewModel?

    private let disposeBag = DisposeBag()
    
    var linkageSheetView: CXLinkageSheetView = CXLinkageSheetView.init()
    
    var leftDataArray: [String] = []
    
    var rightDataArray: [String] = []

    var rightDetailArray: [[String]] = []
    
    var colorArr: [String] = []
    
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
        self.colorArr = ["ct_71BEFF","ct_FF839D","ct_FFDD5C"]
        self.setupUI()
        self.bindViewModel()
        
    }
    
    func setupUI() {
        self.linkageSheetView = CXLinkageSheetView.init(frame: CGRect.init(x: 0, y: 0, width: kScreenWidth, height: kScreenHeight - 100))
        self.linkageSheetView.dataSource = self
        self.linkageSheetView.delegate = self
        self.view.addSubview(self.linkageSheetView)
        
        self.linkageSheetView.sheetHeaderHeight = 62
        self.linkageSheetView.sheetRowHeight = 50
        self.linkageSheetView.sheetLeftTableWidth = 122
        self.linkageSheetView.sheetRightTableWidth = 52
        self.linkageSheetView.showAllSheetBorder = true
        self.linkageSheetView.pagingEnabled = true
        self.linkageSheetView.leftTableCount = self.leftDataArray.count
        self.linkageSheetView.rightTableCount = self.allDate.count
        self.linkageSheetView.outLineColor = .gray
//            UIColor.init(named: "ct_E1E1E1")
        self.linkageSheetView.innerLineColor = .gray
//            UIColor.init(named: "ct_E1E1E1")
        self.linkageSheetView.outLineWidth = 1
        self.linkageSheetView.innerLineWidth = 1
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
            if self.allDate.count > 0 {
                let model = self.allDate[0]
                self.linkageSheetView.leftTableCount = model.produtPriceList.count
            }
            self.linkageSheetView.rightTableCount = self.allDate.count

            self.linkageSheetView.reloadData()

        }).disposed(by: disposeBag)
       
        self.view.showLoadingMessage(message: "加载中...")
        self.priceHouseEvent.onNext((curPage: 1, productIds: nil, channels: nil, fromDate: startParam, endDate: endParam))
    }
}

extension PriceSheetVC: CXLinkageSheetViewDataSource,CXLinkageSheetViewDelegate {
    
    /// 点击事件
    // 左侧表格视图点击事件
    public func leftTableView(_ tableView: UITableView?, didSelectRowAt indexPath: IndexPath?) {
        
    }
    
    // 右侧表格视图点击事件
    public func rightTableView(_ tableView: UITableView?, didSelectRowAt indexPath: IndexPath?, andItemIndex itemIndex: Int) {
        
    }
    
    // 表格section 数目
    public func numberOfSectionsInSheetView() -> Int {
        if self.allDate.count > 0 {
            let model = self.allDate[0]
            return model.produtPriceList.count
        }
        return 0
    }
    
    // 表格section的头部视图高度
    public func heightForSheetViewHeader(inSection section: Int) -> CGFloat {
        return 0.01
    }
    
    // 左边 每组的行数
    public func numberOfRows(inLeftSheetViewSection section: Int) -> Int {
        return 1
    }
    
    // 右边 每组的行数
    public func numberOfRows(inRightSheetViewSection section: Int) -> Int {
        if self.allDate.count > 0 {
            let model = self.allDate[0]
            let productModel = model.produtPriceList[section]
            return productModel.channelPriceModel.count
        }
        return 0
    }
    
    public func heightForLeftSheetViewForRow(at indexPath: IndexPath?) -> CGFloat {
        let model = self.allDate[0]
        let productModel = model.produtPriceList[indexPath?.section ?? 0]
        // 渠道数量
        let channleCount = productModel.channelPriceModel.count
        
        return 50.0 * CGFloat(channleCount)
    }

    public func heightForRightSheetViewForRow(at indexPath: IndexPath?) -> CGFloat {
        return 50
    }
    
    // 日期选择 -- 表格左上角视图
    public func leftTitleView(_ titleContentView: UIView?) -> UIView? {
        let contView: UIView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: titleContentView?.width ?? 0, height: titleContentView?.height ?? 0))
        let selectDate: UIGestureRecognizer = UIGestureRecognizer.init(target: self, action: Selector(("selectDate")))
        contView.addGestureRecognizer(selectDate)
        let lab: UILabel = UILabel.init(frame: CGRect.init(x: 0, y: 15, width: contView.width , height: 25))
        lab.textColor = UIColor.init(named: "buttonBg_F38C27")
        lab.font = UIFont.boldSystemFont(ofSize: 14)
        lab.textAlignment = .center
        lab.text = self.showDate
        contView.addSubview(lab)

        let imgView: UIImageView = UIImageView.init(frame: CGRect.init(x: 58, y: 46, width: 8, height: 4))
        imgView.image = UIImage.init(named: "sheet_date")
        contView.addSubview(imgView)
        return contView
    }
    
    //  自定义表格左侧标题视图 -- 房间名称和渠道
    public func createLeftItem(withContentView contentView: UIView?, indexPath: IndexPath?) -> UIView? {
        let model = self.allDate[0]
        let productModel = model.produtPriceList[indexPath?.section ?? 0]
        // 渠道数量
        let channleCount = productModel.channelPriceModel.count
        let allHeight: CGFloat = 50.0 * CGFloat(channleCount)

        let allView: UIView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: 122, height: allHeight))
        let leftBgView: UIView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: 8, height: allHeight))
        let section: Int = (indexPath?.section ?? 0 + 3) % 3
        leftBgView.backgroundColor = UIColor.init(named: self.colorArr[section])
        allView.addSubview(leftBgView)
        
        // 房型名称
        let nameView: UITextView = UITextView.init(frame: CGRect.init(x: 8, y: 0, width: 80, height: allHeight))
        nameView.textColor = UIColor.init(named: "ct_000000-65")
        nameView.font = UIFont.boldSystemFont(ofSize: 14)
        nameView.text = productModel.name
        nameView.textAlignment = .center
        let contentSize: CGSize = nameView.contentSize
        if contentSize.height < allHeight {
            // 居中展示
            let offsetY: CGFloat = (nameView.height - contentSize.height) / 2.0
            let offset = UIEdgeInsets.init(top: offsetY, left: 0, bottom: 0, right: 0)
            nameView.contentInset = offset
        }
        allView.addSubview(nameView)
        let lineView: UIView = UIView.init(frame: CGRect.init(x: 88.0, y: 0, width: 1, height:allHeight))
        lineView.backgroundColor = UIColor.init(named: "ct_E1E1E1")
        allView.addSubview(lineView)
        
        let channelList: [ChannelPriceModel] = productModel.channelPriceModel
        // 渠道
        for i  in 0...channleCount - 1 {
            let channelView: UIView = UIView.init(frame: CGRect.init(x: 89, y: 50 * i, width: 32, height: 50))
            let imgView: UIImageView = UIImageView.init(frame: CGRect.init(x: 3, y: 12, width: 24, height: 24))
            let channelModel = channelList[i]
            imgView.image = UIImage.init(named: channelModel.channelImg ?? "")
            channelView.addSubview(imgView)
            if i != channleCount - 1 {
                let line1View: UIView = UIView.init(frame: CGRect.init(x: 0, y:  49 , width: 32.0, height: 1.0))
                line1View.backgroundColor = UIColor.init(named: "ct_E1E1E1")
                channelView.addSubview(line1View)
            }
            allView.addSubview(channelView)
        }
        return allView
    }
    
    // 自定义表格右侧标题视图
    public func rightTitleView(_ titleContentView: UIView?, index: Int) -> UIView? {
        let contView: UIView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: titleContentView?.width ?? 0, height: titleContentView?.height ?? 0))
        let lab1: UILabel = UILabel.init(frame: CGRect.init(x: 0, y: 0, width: contView.width , height: 20))
        lab1.textColor = UIColor.init(named: "ct_000000-20_FFFFFF-20")
        lab1.font = UIFont.systemFont(ofSize: 12)
        lab1.textAlignment = .center
        contView.addSubview(lab1)
        let lab2: UILabel = UILabel.init(frame: CGRect.init(x: 9, y: lab1.bottom + 5, width: 34 , height:34))
        lab2.textColor = UIColor.init(named: "ct_000000-65")
        lab2.font = UIFont.boldSystemFont(ofSize: 16)
        lab2.textAlignment = .center
        contView.addSubview(lab2)
        if self.allDate.count > 0 {
            let model = self.allDate[index]
            if model.dateName.count > 0 {
                 // 节假日
                contView.backgroundColor = UIColor.init(named: "ct_FFF5E6")
                lab1.text = model.dateName
                lab1.textColor = UIColor.init(named: "ct_F09A19")
                lab2.font = UIFont.boldSystemFont(ofSize: 16)
            }else{
                lab1.textColor = UIColor.init(named: "ct_000000-30")
                contView.backgroundColor = .white
                lab1.text = model.showWeek
                lab2.font = UIFont.systemFont(ofSize: 16)
            }
            
            lab2.text = String(model.dayStr)
            if model.isToday == true{
                lab2.textColor = .white
                lab1.textColor = UIColor.init(named: "ct_F09A19")
                lab2.backgroundColor = UIColor.init(named: "buttonBg_F38C27")
                lab2.layer.cornerRadius = 17
                lab2.layer.masksToBounds = true
            }else{
                lab2.textColor = UIColor.init(named: "ct_000000-65")
            }
        }else{
            lab1.text = "--"
            lab2.text = "--"
        }
        return contView
    }
    
    // 自定义表格右侧每一个格子的视图
    public func createRightItem(withContentView contentView: UIView?, indexPath: IndexPath?, itemIndex: Int) -> UIView? {
        let contView: UIView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: contentView?.width ?? 0, height: contentView?.height ?? 0))
        let priceLab: UILabel = UILabel.init(frame: CGRect.init(x: 0, y: 5, width: contView.width , height: 20))
        priceLab.textColor = UIColor.init(named: "ct_000000-20_FFFFFF-20")
        priceLab.font = UIFont.systemFont(ofSize: 12)
        priceLab.textAlignment = .center
        contView.addSubview(priceLab)
        let surplusLab: UILabel = UILabel.init(frame: CGRect.init(x: 0, y: priceLab.bottom + 5, width: contView.width , height:20))
        surplusLab.textColor = UIColor.init(named: "ct_000000-65")
        surplusLab.font = UIFont.boldSystemFont(ofSize: 16)
        surplusLab.textAlignment = .center
        contView.addSubview(surplusLab)
        if self.allDate.count > 0 {
            let modelArr = self.allDate[itemIndex]
            let model = modelArr.produtPriceList[indexPath?.section ?? 0]
            let priceModel =  model.channelPriceModel[indexPath?.row ?? 0]
            priceLab.text = String(priceModel.price)
            surplusLab.text = String(priceModel.price)
        }else{
            priceLab.text = "--"
            surplusLab.text = "--"
        }
        return contView

    }
    
}
