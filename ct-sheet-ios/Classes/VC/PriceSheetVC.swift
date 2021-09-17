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

public enum LoadType : Int {
    case lefeType              = 10         // 左边
    case normal                = 20         // 正常
    case rightType             = 30         // 右边
}

// 线宽
var lineWidthHeight: CGFloat = 0.5

public class PriceSheetVC: BossViewController, CBGroupAndStreamViewDelegate {
    
    private var priceHouseEvent = PublishSubject<(curPage: Int, productIds: [String]?, channels: [Int]? ,fromDate: Int ,endDate: Int)>()
    
    private var priceChangeEvent = PublishSubject<(productId: String, dates: [Int], channel: Int ,price: Int)>()
    
    var viewModel: PriceSheetViewModel?
    
    private let disposeBag = DisposeBag()
    
    var linkageSheetView: CXLinkageSheetView = CXLinkageSheetView.init()
    
    // 颜色
    var colorArr: [String] = []
    
    // 第一列数据
    var firstModel: DayModel?
    
    // 所有数据
    var allDate: [DayModel] = []
    
    var dateArr: [Int] = [] // 选择修改价格的日期
    
    // 从日历手动选择的日期  // 左上角的选中的日期
    var showDate: String?
    
    // 展示日期
    var dateLab: UILabel = UILabel.init()
    
    // 加载数据的起始日期
    var startDate: Date = Date.init()
    // 加载数据的结束日期
    var endDate: Date = Date.init()
    // 自定义键盘
    var keyBoard: kfZNumberKeyBoard?
    
    // 第一次选择某个价格框
    var firstSelected: Bool = false
    
    // 选择的某行
    var selectIndexPath: IndexPath?
    
    // 选择了某写item
    var selectCells: [CXLinkageSheetRightItem] = []
        
    // 改价
    // 选择的房型
    var selectProductId: String?
    
    // 渠道
    var selectChannel: Int = 0
    
    // 输入的价格
    var inputPrice: Int = 0
    
    var loadNum : Int = 0
    
    // 所有的房型名称 --用于筛选
    var allProductName: [String] = []
    // 所有的房型id --用于筛选
    var allProductId: [String] = []
    // 加载状态
    var loadType: LoadType = .normal {
        didSet{
            if self.loadType == .normal{
                self.loadNum = 0
            }else{
                self.loadNum = self.loadNum + 1
            }
        }
    }
    
    var filterView: FilterView?
    
    var isFirst: Bool = true
    
    // 筛选的时候
    var filterChannelArr: [Int]?
    
    var filterProductIdArr: [String]?
    
    // 筛选框选择的index
    var selectIndexArr: [[Int]] = [[0], [0]]

    lazy var filterBtn: UIButton = {
        let filterBtn = UIButton()
        filterBtn.addTarget(self, action: #selector(filterAllDate), for: .touchUpInside)
        filterBtn.frame = CGRect(x: kScreenWidth - 76, y: kScreenHeight - 90 - 34, width: 60, height: 60)
        filterBtn.setImage(UIImage.init(named: "sheet_filter"), for: .normal)
        return filterBtn
    }()
    
    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        self.setNavColor()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        self.setNavColor()
        super.viewWillAppear(animated)
        // 今天
        let currentDate = Date.init()
        self.startDate = Date.getRequestLaterDate(from: currentDate, withYear: 0, month: 0, day: -1)
        self.endDate = Date.getRequestLaterDate(from: self.startDate, withYear: 0, month: 0, day: 29)
        self.loadType = .normal
        self.compentParamWithStartDate(startDate: startDate, endDate: self.endDate)
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
        self.filterChannelArr = []
        self.filterProductIdArr = []
        self.setupUI()
        self.bindViewModel()
        self.view.addSubview(self.filterBtn)
        self.view.bringSubviewToFront(self.filterBtn)
    }
    
    func setupUI() {
        var viewHeight = screenHeight - 64
        var isphoneX : Bool = false
        if (screenWidth == 375 && screenHeight == 812 )||(screenWidth == 414 && screenHeight == 896){
            isphoneX = true
        }
        if  isphoneX {
            viewHeight = screenHeight - 88 - 34
        }
        self.filterBtn.isHidden = true
        self.filterBtn.frame.origin.y = viewHeight - 60
        self.linkageSheetView = CXLinkageSheetView.init(frame: CGRect.init(x: 0, y: 0, width: kScreenWidth, height: viewHeight))
        self.linkageSheetView.dataSource = self
        self.linkageSheetView.delegate = self
        self.view.addSubview(self.linkageSheetView)
        self.linkageSheetView.sheetHeaderHeight = 62
        self.linkageSheetView.sheetRowHeight = 50
        self.linkageSheetView.sheetLeftTableWidth = 122
        self.linkageSheetView.sheetRightTableWidth = 52
        self.linkageSheetView.showAllSheetBorder = true
        self.linkageSheetView.pagingEnabled = true
        self.linkageSheetView.rightTableCount = self.allDate.count
        self.linkageSheetView.outLineColor = UIColor.init(named: "ct_E1E1E1")
        self.linkageSheetView.innerLineColor = UIColor.init(named: "ct_E1E1E1")
        self.linkageSheetView.outLineWidth = lineWidthHeight
        self.linkageSheetView.innerLineWidth = lineWidthHeight
        self.linkageSheetView.showScrollShadow = false
        self.linkageSheetView.reloadData()
    }
    
    func bindViewModel() {
        let input = PriceSheetViewModel.input(housePriceConsoleObservable: self.priceHouseEvent, housePriceChangeObservable: self.priceChangeEvent)
        
        self.viewModel = PriceSheetViewModel.init(input: input)
        self.viewModel?.housePricesOutput.subscribe(onNext:{[unowned self] (arr)  in
            self.view.dissmissLoadingView()
            if self.loadType == .normal{
                self.firstModel = nil
                self.allDate = arr
            }else if self.loadType == .lefeType{
                self.allDate.insert(contentsOf: arr, at: 0)
            }else if self.loadType == .rightType{
                self.allDate.append(contentsOf: arr)
            }
            if self.allDate.count > 0 {
                for modelArr in self.allDate {
                    let isBefore: Bool = modelArr.isBefore // 今天之前的日期
                    for everyModel in modelArr.produtPriceList {
                        everyModel.isBefore = isBefore
                        for channelModel in everyModel.channelPriceModel{
                            channelModel.isBefore = isBefore
                        }
                    }
                }
                if (self.firstModel == nil){
                    self.firstModel = self.allDate.first
                }
                self.showDate = self.firstModel?.yearMonthDay
                self.dateLab.text = self.firstModel?.yearMonthDay
                let indexA: Int = self.allDate.firstIndex(where: { $0 == self.firstModel }) ?? 0
                let model = self.allDate[0]
                let list = model.produtPriceList
                if let listArr = list, listArr.count > 0{
                    let productModel = model.produtPriceList[0]
                    self.linkageSheetView.leftTableCount = model.produtPriceList.count *  productModel.channelPriceModel.count
                }
                self.linkageSheetView.rightTableCount = self.allDate.count
                self.linkageSheetView.reloadData()
                self.linkageSheetView.rightContentView.contentOffset.x = CGFloat(52 * indexA)
                self.filterBtn.isHidden = false
                self.linkageSheetView.isHidden = false
                                
            }else{
                // 空页面
                self.filterBtn.isHidden = true
                self.linkageSheetView.isHidden = true
                self.view.emptyViewDisplayWitMsg(message: "请先进行房源关联", imageName: nil, detailStr: nil, outStandStr: nil, btnStr: "房源关联") {
                 // 关联房源
                    "allChannelVCRouter".openURL(para: ["isPriceJump": false])
                }
            }
            
        }).disposed(by: disposeBag)
        
        self.viewModel?.pricesChangeOutput.subscribe(onNext: {[unowned self] (model) in
            self.view.dissmissLoadingView()
            // 刷新页面
            for (_,dayModel) in self.allDate.enumerated() {
                let model = dayModel.produtPriceList[self.selectIndexPath?.section ?? 0]
                let priceModel = model.channelPriceModel[self.selectIndexPath?.row ?? 0]
                if  priceModel.selected == true {
                    priceModel.selected = false
                    priceModel.price = self.inputPrice * 100
                }
            }
            if self.selectCells.count > 0 {
                self.changeColorWithItem(cellArr: self.selectCells,changePrice: true)
            }
            if let keyB = self.keyBoard{
                keyB.removeFromSuperview()
            }
            self.keyBoard = nil
            self.dateArr.removeAll()
            self.selectCells.removeAll()
            self.selectIndexPath = nil
            
        }).disposed(by: disposeBag)
        self.viewModel?.errorObservable.subscribe(onNext: {[unowned self] (model) in
            self.view.dissmissLoadingView()
            self.view.showfailMessage(message: model.zhMessage, handle: nil)
            self.filterBtn.isHidden = true
        }).disposed(by: disposeBag)
        self.viewModel?.errorOutPut.subscribe(onNext: {[unowned self] (model) in
            self.view.dissmissLoadingView()
            self.view.showfailMessage(message: model.zhMessage, handle: nil)
        }).disposed(by: disposeBag)
    }
    
    // 筛选
    @objc func filterAllDate()  {
        // 初始化筛选框
        if (self.filterView == nil){
            let channelNameArr: [String] = ["全部","美团民宿","小猪民宿","爱彼迎","途家"]
            self.allProductName = ["全部"]
            self.allProductId = [""]
            if self.allDate.count > 0 {
                let modelArr = self.allDate[0]
                for model in modelArr.produtPriceList{
                    self.allProductName.append(model.name)
                    self.allProductId.append(model.id)
                }
            }
            let titleArr = ["选择渠道","选择房型"]
            let contentArr = [channelNameArr,self.allProductName]
            self.filterView = FilterView.init(frame: CGRect.init(x: 0, y: 0, width: kScreenWidth, height: kScreenHeight), contetnArr: contentArr, titleArr: titleArr, defaultSelIndexArr: self.selectIndexArr)
            let window  = UIApplication.shared.keyWindow!
            if let resultView = self.filterView{
                window.addSubview(resultView)
            }
        }
        self.filterView?.isHidden = false
        self.filterView?.frame = CGRect.init(x: 0, y: 0, width: kScreenWidth, height: kScreenHeight)
        let window  = UIApplication.shared.keyWindow!
        if let resultView = self.filterView{
            window.bringSubviewToFront(resultView)
        }
        
        self.filterView?.defaultSelArr = self.selectIndexArr
        
        self.filterView?.backSelectFilter = { (selArr, saveSelGroupIndexeArr) in
            
            if  ((saveSelGroupIndexeArr as? [[Int]]) != nil) {
                // 选中的位置
                self.selectIndexArr = saveSelGroupIndexeArr as? [[Int]] ?? [[]]
            }
           
            let channelArr = selArr[0] as! Array<String>
            let productArr = selArr[1] as! Array<String>
            // 选择的渠道和房型ID
            self.filterChannelArr?.removeAll()
            
            self.filterProductIdArr = []
//            var fistIndex = self.selectIndexArr[0]
//            fistIndex.removeAll()
//            var secondIndex = self.selectIndexArr[1]
//            secondIndex.removeAll()
//
//            print(channelArr)
//
//            print(fistIndex)
//
//            print(secondIndex)
            
            for str in channelArr  {
                if str.contains("全部") {
                    self.filterChannelArr?.removeAll()
//                    fistIndex.append(0)
                }
                if str.contains("美团民宿"){
                    self.filterChannelArr?.append(40)
//                    fistIndex.append(1)
                }
                if str.contains("小猪民宿")  {
                    self.filterChannelArr?.append(30)
//                    fistIndex.append(2)
                }
                if str.contains("爱彼迎") {
                    self.filterChannelArr?.append(20)
//                    fistIndex.append(3)
                }
                if str.contains("途家") {
                    self.filterChannelArr?.append(10)
//                    fistIndex.append(4)
                }
            }
            for (index,nameStr) in self.allProductName.enumerated(){
                if productArr.contains(where: { $0.contains(nameStr)}){
                    if index > 0{
                        let idP = self.allProductId[index]
                        if idP.count > 0 {
                            self.filterProductIdArr?.append(idP)
                        }
                    }
//                    secondIndex.append(index)
                }
            }
//            if secondIndex.count == 0{
//                secondIndex = [0]
//            }
            
//            self.selectIndexArr.removeAll()
//            self.selectIndexArr = [fistIndex, secondIndex]
            
//            print(channelArr)
//
//            print(fistIndex)

            print("========")
            print(self.selectIndexArr)
            print(self.filterChannelArr)
            print(self.filterProductIdArr)
            
            // 调用接口
            self.firstModel = nil
            let currentDate = Date.init()
            self.startDate = Date.getRequestLaterDate(from: currentDate, withYear: 0, month: 0, day: -1)
            self.endDate = Date.getRequestLaterDate(from: self.startDate, withYear: 0, month: 0, day: 29)
            self.loadType = .normal
            self.compentParamWithStartDate(startDate: self.startDate, endDate: self.endDate)
        }
       
    }
    // 组装请求参数
    func compentParamWithStartDate(startDate: Date = Date.init(), endDate: Date = Date.init()){
        // T ~ T + 30
        let startParam = Date.changeTimesFormatContainYearMouthDayAndLine(date: startDate).1
        let endParam = Date.changeTimesFormatContainYearMouthDay(date: endDate).1
        self.view.showLoadingMessage(message: "加载中...")
        self.priceHouseEvent.onNext((curPage: 1, productIds: self.filterProductIdArr, channels: self.filterChannelArr, fromDate: startParam, endDate: endParam))
    }
}

extension PriceSheetVC: CXLinkageSheetViewDataSource,CXLinkageSheetViewDelegate, kfZNumberKeyBoardDelegate {
    
    public func erroTip(withMinPrice minPrice: Int, maxPrice: Int) {
        guard let keyWindow = UIApplication.shared.keyWindow else { return }
        keyWindow.dissmissLoadingView()
        keyWindow.justTitleMessageView(message: "请输入\(minPrice) ~ \(maxPrice) 元内的价格", handle: nil)
    }
    /*
     * kfZNumberKeyBoardDelegate
     */
    // 批量改价
    public func delegateBatchBtnClick() {
        // 跳转下个页面,回来刷新
        if let keyB = self.keyBoard{
            keyB.removeFromSuperview()
        }
        self.keyBoard = nil
        self.dateArr.removeAll()
        self.selectCells.removeAll()
        self.selectIndexPath = nil
        // 去批量改价页
        "BatchPriceVCRouter".openURL()
    }
    
    // 取消
    public func delegateTagBlackBg() {
        // 键盘下去, 已选价格框取消选中
        if let keyB = self.keyBoard {
            keyB.removeFromSuperview()
        }
        self.keyBoard = nil
        for (_,dayModel) in self.allDate.enumerated() {
            let model = dayModel.produtPriceList[self.selectIndexPath?.section ?? 0]
            let priceModel = model.channelPriceModel[self.selectIndexPath?.row ?? 0]
            if  priceModel.selected == true {
                priceModel.selected = false
            }
        }
        if self.selectCells.count > 0 {
            self.changeColorWithItem(cellArr: self.selectCells,changePrice: false)
        }
        self.dateArr.removeAll()
        self.selectCells.removeAll()
        self.selectIndexPath = nil
    }
    
    // 改变颜色
    func changeColorWithItem(cellArr: [CXLinkageSheetRightItem] ,changePrice: Bool)  {
        for (_, item) in cellArr.enumerated() {
            let itemSubArr: [UIView] = item.subviews
            if itemSubArr.count > 0 {
                for itemSubview in itemSubArr {
                    if itemSubview.tag == 78 {
                        itemSubview.backgroundColor = .white
                        let labArr: [UIView] = itemSubview.subviews
                        for labItem in labArr {
                            if labItem is UILabel {
                                let changeLab: UILabel = labItem as! UILabel
                                if changeLab.tag == 7 {
                                    changeLab.textColor = UIColor.init(named: "ct_000000-85_FFFFFF-85")
                                    if changePrice == true {
                                        changeLab.text = "¥ " + String(self.inputPrice)
                                    }
                                }
                                if changeLab.tag == 8 {
                                    changeLab.textColor = UIColor.init(named: "ct_000000-50")
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    // 改价
    public func delegatechangePriceBtnClick(_ inputNum: Int) {
        // 键盘下去, 调用接口
        self.inputPrice = inputNum
        if let proId = self.selectProductId{
            self.view.showLoadingMessage(message: "加载中...")
            let price: Int = self.inputPrice * 100
            self.priceChangeEvent.onNext((productId: proId, dates: self.dateArr, channel: self.selectChannel, price: price))
        }
    }
    
    /*
     * CXLinkageSheetViewDelegate
     */
    // 加载之前的数据
    public func loadBeforeData() {
        if self.loadNum > 2 {
            self.view.justTitleMessageView(message: "试试点击日期筛选", handle: nil)
            return
        }
        self.endDate = Date.getRequestLaterDate(from: self.startDate, withYear: 0, month: 0, day: -1)
        self.startDate = Date.getRequestLaterDate(from: self.endDate, withYear: 0, month: 0, day: -29)
        self.loadType = .lefeType
        self.compentParamWithStartDate(startDate: startDate, endDate: self.endDate)
    }
    
    // 加载之后的数据
    public func loadFurtureData() {
        if self.loadNum > 2 {
            self.view.justTitleMessageView(message: "试试点击日期筛选", handle: nil)
            return
        }
        self.startDate = Date.getRequestLaterDate(from: self.endDate, withYear: 0, month: 0, day: 1)
        self.endDate = Date.getRequestLaterDate(from: self.startDate, withYear: 0, month: 0, day: 29)
        self.loadType = .rightType
        self.compentParamWithStartDate(startDate: startDate, endDate: self.endDate)
    }
    
    public func getvisibleFirstDate(_ index: NSInteger) {
        self.firstModel = self.allDate[index]
        self.showDate = self.firstModel?.yearMonthDay
        self.dateLab.text = self.firstModel?.yearMonthDay
    }
    
    // 点击事件
    // 左侧表格视图点击事件
    public func leftTableView(_ tableView: UITableView?, didSelectRowAt indexPath: IndexPath?) {
        
        
    }
    
    // 右侧表格视图点击事件
    public func rightTableView(_ tableView: UITableView?, didSelectRowAt indexPath: IndexPath?, andItemIndex itemIndex: Int) {
        let modelArr = self.allDate[itemIndex]
        let model = modelArr.produtPriceList[indexPath?.section ?? 0]
        let priceModel = model.channelPriceModel[indexPath?.row ?? 0]
        if priceModel.canChoose == false ||  priceModel.isBefore == true {
            return
        }
        if self.selectIndexPath == nil {
            self.selectIndexPath = indexPath
        }
        if self.selectIndexPath != indexPath {
            return
        }
        priceModel.selected = !priceModel.selected
        
        self.selectProductId = model.id
        self.selectChannel = priceModel.channel
        // 获取item
        let indexN = indexPath ?? IndexPath.init(row: 0, section: 0)
        let cell = tableView?.cellForRow(at: indexN) as? CXLinkageSheetRightCell
        let item = cell?.itemArr[itemIndex] as? CXLinkageSheetRightItem
        let itemSubArr: [UIView] = item?.subviews ?? [UIView.init()]
        // 改变item 颜色
        if itemSubArr.count > 0 {
            for itemSubview in itemSubArr {
                if itemSubview.tag == 78 {
                    if priceModel.selected == true {
                        itemSubview.backgroundColor = UIColor.init(named: "buttonBg_F38C27")
                    }else {
                        if priceModel.canChoose == false || priceModel.isBefore == true {
                            itemSubview.backgroundColor = UIColor.init(named: "ct_F1F1F1")
                        }else {
                            itemSubview.backgroundColor = UIColor.white
                        }
                    }
                    let labArr: [UIView] = itemSubview.subviews
                    for labItem in labArr {
                        if labItem is UILabel {
                            let changeLab: UILabel = labItem as! UILabel
                            if changeLab.tag == 7 {
                                if priceModel.selected == true {
                                    changeLab.textColor = UIColor.white
                                }else{
                                    changeLab.textColor = UIColor.init(named: "ct_000000-85_FFFFFF-85")
                                }
                            }
                            if changeLab.tag == 8 {
                                if priceModel.selected == true {
                                    changeLab.textColor = UIColor.init(named: "ct_FFFFFF-60")
                                }else{
                                    changeLab.textColor = UIColor.init(named: "ct_000000-50")
                                }
                            }
                        }
                    }
                }
            }
        }
        
        if priceModel.selected == true {
            self.selectCells.append(item ?? CXLinkageSheetRightItem.init())
            self.dateArr.append(modelArr.date)
            self.dateArr.sort {
                $0 < $1
            }
        }else{
            var ind = 0
            for (i , date) in self.dateArr.enumerated(){
                if date == modelArr.date{
                    ind = i
                }
            }
            if self.dateArr.count > 0{
                self.dateArr.remove(at: ind)
            }
            
            var cellInd = 0
            for (i , cellItem) in self.selectCells.enumerated(){
                if item == cellItem {
                    cellInd = i
                }
            }
            if self.selectCells.count > 0{
                self.selectCells.remove(at: cellInd)
            }
        }
        
        if self.dateArr.count > 0 { // 调起键盘
            if self.keyBoard == nil {
                self.keyBoard = kfZNumberKeyBoard.moneyKeyBoardBuyer(withImageName: priceModel.channelImg ?? "")
                if let board = self.keyBoard {
                    self.keyBoard?.delegate = self
                    self.view.addSubview(board)
                }
            }
            self.keyBoard?.minPrice = priceModel.minPrice
            self.keyBoard?.maxPrice = priceModel.maxPrice
            if self.dateArr.count == 1 {
                let firstDate = self.dateArr.first
                let showDate = Date.changeMonthDayFormatContainMonthDay(date: Date.intChangeDate(resultDate: firstDate ?? 0))
                if let date = showDate {
                    self.keyBoard?.titileStr = "已选\(date)共1个间夜"
                }
                
            }else{
                let firstDate = self.dateArr.first
                let lastDate = self.dateArr.last
                let showFirst = Date.changeMonthDayFormatContainMonthDay(date: Date.intChangeDate(resultDate: firstDate ?? 0))
                let showLast = Date.changeMonthDayFormatContainMonthDay(date: Date.intChangeDate(resultDate: lastDate ?? 0))
                if let oneDate = showFirst, let twoDate = showLast {
                    self.keyBoard?.titileStr = "已选\(oneDate) ~ \(twoDate) 共\(self.dateArr.count)个间夜"
                }
            }
            
        }else{
            self.keyBoard?.removeFromSuperview()
            self.keyBoard = nil
            self.dateArr.removeAll()
            self.selectCells.removeAll()
            self.selectIndexPath = nil
        }
    }
    
    // 表格section 数目
    public func numberOfSectionsInSheetView() -> Int {
        if self.allDate.count > 0 {
            let model = self.allDate[0]
            return model.produtPriceList.count
        }
        return 0
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
        return 50.0
    }
    
    // 日期选择 -- 表格左上角视图
    public func leftTitleView(_ titleContentView: UIView?) -> UIView? {
        let contView: UIView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: titleContentView?.width ?? 0, height: titleContentView?.height ?? 0))
        contView.isUserInteractionEnabled = true
        self.dateLab = UILabel.init(frame: CGRect.init(x: 0, y: 15, width: contView.width , height: 25))
        self.dateLab .textColor = UIColor.init(named: "buttonBg_F38C27")
        self.dateLab .font = mediumFont(size: 14)
        self.dateLab .textAlignment = .center
        self.dateLab .text = self.firstModel?.yearMonthDay
        contView.addSubview(self.dateLab )
        let imgView: UIImageView = UIImageView.init(frame: CGRect.init(x: 58, y: 46, width: 8, height: 4))
        imgView.image = UIImage.init(named: "sheet_date")
        contView.addSubview(imgView)
        let btn: UIButton = UIButton.init(frame: CGRect.init(x: 0, y: 0, width: titleContentView?.width ?? 0, height: titleContentView?.height ?? 0))
        btn.addTarget(self, action:  #selector(selectDate), for: .touchUpInside)
        contView.addSubview(btn)
        return contView
    }
    
    // 日期选择
    @objc func selectDate()  {
        let singleCalenderView = SingleCalenderView.init(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height:  UIScreen.main.bounds.height) , selectedStr: self.showDate)
        singleCalenderView.backSelectData = { str  in
            if self.showDate == str {
                return
            }
            self.showDate = str
            self.startDate = Date.selectedIntChangeDate(resultDate: self.showDate ?? "2021-09-10")
            self.endDate =  Date.getRequestLaterDate(from: self.startDate, withYear: 0, month: 0, day: 30)
            self.loadType = .normal
            // 调用接口
            self.compentParamWithStartDate(startDate: self.startDate, endDate: self.endDate)
        }
        let window  = UIApplication.shared.keyWindow!
        window.addSubview(singleCalenderView)
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
        let nameView: UITextView = UITextView.init(frame: CGRect.init(x: 8, y: 0, width: 80, height: allHeight - 0.5))
        nameView.textColor = UIColor.init(named: "ct_000000-65")
        nameView.font = mediumFont(size: 14)
        nameView.text = productModel.name
        nameView.isUserInteractionEnabled = false
        nameView.textAlignment = .center
        let contentSize: CGSize = nameView.contentSize
        if contentSize.height < allHeight {
            // 居中展示
            let offsetY: CGFloat = (nameView.height - contentSize.height) / 2.0
            let offset = UIEdgeInsets.init(top: offsetY, left: 0, bottom: 0, right: 0)
            nameView.contentInset = offset
        }
        allView.addSubview(nameView)
        let lineView: UIView = UIView.init(frame: CGRect.init(x: 88.0, y: 0, width: lineWidthHeight , height:allHeight))
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
                let line1View: UIView = UIView.init(frame: CGRect.init(x: 0, y:  49.5 , width: 32.0, height: lineWidthHeight))
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
        lab1.font = regularFont(size: 12)
        lab1.textAlignment = .center
        contView.addSubview(lab1)
        let lab2: UILabel = UILabel.init(frame: CGRect.init(x: 9, y: lab1.bottom + 5, width: 34 , height:34))
        lab2.textColor = UIColor.init(named: "ct_000000-65")
        lab2.font = regularFont(size: 16)
        lab2.textAlignment = .center
        contView.addSubview(lab2)
        if self.allDate.count > 0 {
            let model = self.allDate[index]
            if model.dateName.count > 0 {
                // 节假日
                contView.backgroundColor = UIColor.init(named: "ct_FFF5E6")
                lab1.text = model.dateName
                lab1.textColor = UIColor.init(named: "ct_F09A19")
                lab2.font = mediumFont(size: 16)
            }else{
                lab1.textColor = UIColor.init(named: "ct_000000-30")
                contView.backgroundColor = .white
                lab1.text = model.showWeek
                lab2.font = regularFont(size: 16)
            }
            
            lab2.text = String(model.dayStr)
            if model.isToday == true {
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
        let contWidth = contentView?.width ?? 1.0
        let contView: UIView = UIView.init(frame: CGRect.init(x: 0, y: 0, width:contWidth - 1.0 , height: contentView?.height ?? 0))
        contView.tag = 78
        contView.isUserInteractionEnabled = false
        let priceLab: UILabel = UILabel.init(frame: CGRect.init(x: 0, y: 0, width: contView.width, height: 25))
        priceLab.textColor = UIColor.init(named: "ct_000000-85_FFFFFF-85")
        priceLab.font = mediumFont(size: 12)
        priceLab.tag = 7
        priceLab.textAlignment = .center
        contView.addSubview(priceLab)
        let surplusLab: UILabel = UILabel.init(frame: CGRect.init(x: 0, y: priceLab.bottom , width: contView.width , height:25))
        surplusLab.textColor = UIColor.init(named: "ct_000000-50")
        surplusLab.font = regularFont(size: 12)
        surplusLab.textAlignment = .center
        surplusLab.tag = 8
        contView.addSubview(surplusLab)
        if self.allDate.count > 0 {
            let modelArr = self.allDate[itemIndex]
            //            let isBefore: Bool = modelArr.isBefore // 今天之前的日期
            //            for everyModel in modelArr.produtPriceList {
            //                everyModel.isBefore = isBefore
            //                for channelModel in everyModel.channelPriceModel{
            //                    channelModel.isBefore = isBefore
            //                }
            //            }
            let model = modelArr.produtPriceList[indexPath?.section ?? 0]
            let priceModel =  model.channelPriceModel[indexPath?.row ?? 0]
            if priceModel.price >= 0{
                priceLab.text =  "¥ " + String(format:"%d",Int(priceModel.price)/100)
            }else{
                priceLab.text = "¥ --"
            }
            if priceModel.allowStock >= 0{
                surplusLab.text = "余 " + String(priceModel.allowStock)
            }else{
                surplusLab.text = "余 0"
            }
            priceLab.textColor = UIColor.init(named: "ct_000000-85_FFFFFF-85")
            surplusLab.textColor = UIColor.init(named: "ct_000000-50")
            if priceModel.isBefore == true  || priceModel.canChoose == false {
                contView.backgroundColor = UIColor.init(named: "ct_F1F1F1")
            } else {
                if priceModel.selected == true {
                    contView.backgroundColor = UIColor.init(named: "buttonBg_F38C27")
                    priceLab.textColor = UIColor.white
                    surplusLab.textColor = UIColor.init(named: "ct_FFFFFF-60")
                }else{
                    contView.backgroundColor = .white
                }
            }
        }else{
            priceLab.text = "¥ --"
            surplusLab.text = "余 --"
            contView.backgroundColor = UIColor.init(named: "ct_F1F1F1")
        }
        let lineView: UIView = UIView.init(frame: CGRect.init(x: 0, y: 49.5, width: 52, height:lineWidthHeight))
        lineView.backgroundColor = UIColor.init(named: "ct_E1E1E1")
        contView.addSubview(lineView)
        return contView
    }
}


