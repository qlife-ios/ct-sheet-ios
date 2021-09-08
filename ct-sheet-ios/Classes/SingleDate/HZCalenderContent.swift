//
//  HZCalenderContent.swift
//  CalendarTest
//
//  Created by welkj on 2017/10/25.
//  Copyright © 2017年 Heinz. All rights reserved.
//

import UIKit
import boss_basic_common_ios

protocol HZCalenderContentDelegate: NSObjectProtocol {
    func newSelect(day: String)
    func newPage(year: String, month: String)
}

class HZCalenderContent: UIView {
    
    weak var delegate: HZCalenderContentDelegate? {
        didSet {
            let calendar = Calendar.current
            /**初始化月份的符号*/
            let month = calendar.shortMonthSymbols[self.select_day.month! - 1]
            delegate?.newPage(year: "\(self.select_day.year!)", month: month)
            delegate?.newSelect(day: self.selectCalendarToString())
        }
    }
    
    private let reuseId = "HZCalenderCell"
    private let dayLabels: [UILabel] = {
        var ary: [UILabel] = []
        let weekName = ["日", "一", "二", "三", "四", "五", "六"]
        for index in 0...6 {
            let label = UILabel()
            label.textAlignment = .center
            label.font = regularFont(size: 12)
            /**周的符号*/
            label.text = weekName[index]
            label.textColor =  hexColor("9FA5B4")
            ary.append(label)
        }
        return ary
    }()
    
    private let scrollView: UIScrollView = UIScrollView()
    private let collectionL: UICollectionView = UICollectionView.init(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    private let collectionM: UICollectionView = UICollectionView.init(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    private let collectionR: UICollectionView = UICollectionView.init(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    var select_day: DateComponents = {
        return Calendar.current.dateComponents([.year, .month, .day], from: Date())
    }()
    private var cur_year_month: DateComponents = Calendar.current.dateComponents([.year, .month], from: Date()) {
        willSet {
            days_left = HZDayModel.creatDays(by: newValue.previousMonth())
            days_middle = HZDayModel.creatDays(by: newValue)
            days_right = HZDayModel.creatDays(by: newValue.nextMonth())
            /**月份的符号*/
            let calendar = Calendar.current
            let month = calendar.shortMonthSymbols[newValue.month! - 1]
            delegate?.newPage(year: "\(newValue.year!)", month: month)
        }
    }
    private var days_left: [HZDayModel] = [] {
        didSet { collectionL.reloadData() }
    }
    private var days_middle: [HZDayModel] = [] {
        didSet { collectionM.reloadData() }
    }
    private var days_right: [HZDayModel] = [] {
        didSet { collectionR.reloadData() }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init(frame: CGRect, selectDay: DateComponents) {
        super.init(frame: frame)
        self.select_day = selectDay
        cur_year_month = self.select_day
        self.onCreat()
        days_left = HZDayModel.creatDays(by: selectDay.previousMonth())
        days_middle = HZDayModel.creatDays(by: selectDay)
        days_right = HZDayModel.creatDays(by: selectDay.nextMonth())
    }
    
    func nextDay() {
        let nextday = select_day.nextDay()
        if nextday.isFuture() {
            return
        }
        select_day = nextday
        collectionL.reloadData()
        collectionM.reloadData()
        collectionR.reloadData()
        delegate?.newSelect(day: self.selectCalendarToString())
    }
    
    func nextMonth() {
        cur_year_month = cur_year_month.nextMonth()
    }
    
    func nextYear() {
        cur_year_month = cur_year_month.nextYear()
    }
    
    func beforeDay() {
        select_day = select_day.previousDay()
        collectionL.reloadData()
        collectionM.reloadData()
        collectionR.reloadData()
        delegate?.newSelect(day: self.selectCalendarToString())
    }
    
    func beforeMonth() {
        cur_year_month = cur_year_month.previousMonth()
    }
    
    func beforeYear() {
        cur_year_month = cur_year_month.previousYear()
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if (scrollView.contentOffset.y < scrollView.bounds.size.height) {// 向左
            cur_year_month = cur_year_month.previousMonth()
        } else if (scrollView.contentOffset.y > scrollView.bounds.size.height) {
            cur_year_month = cur_year_month.nextMonth()
        }
        scrollView.setContentOffset(collectionM.frame.origin, animated: false)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let width = self.bounds.size.width
        let labelWidth = width / 7
        for index in 0...(dayLabels.count - 1) {
            let label = dayLabels[index]
            label.frame = CGRect.init(x: labelWidth*CGFloat(index), y: 0, width: labelWidth, height: 22)
        }
        let height = self.bounds.size.height - 22
        scrollView.frame = CGRect.init(x: 0, y: 22, width: width, height: height)
        scrollView.contentSize = CGSize.init(width: width, height: height * 3)
        collectionL.frame = CGRect.init(x: 0, y: 0, width: width, height: height)
        collectionM.frame = CGRect.init(x: 0, y: height, width: width, height: height)
        collectionR.frame = CGRect.init(x: 0, y: height*2, width: width, height: height)
        scrollView.setContentOffset(collectionM.frame.origin, animated: false)
        collectionL.reloadData()
        collectionM.reloadData()
        collectionR.reloadData()
    }
    
    private func onCreat() {
        for label in dayLabels {
            self.addSubview(label)
        }
        scrollView.delegate = self
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.bounces = false
        self.addSubview(scrollView)
        collectionL.delegate = self
        collectionL.dataSource = self
        collectionL.backgroundColor = .white
        collectionL.register(HZCalenderCell.classForCoder(), forCellWithReuseIdentifier: reuseId)
        collectionM.delegate = self
        collectionM.dataSource = self
        collectionM.backgroundColor = .white
        collectionM.register(HZCalenderCell.classForCoder(), forCellWithReuseIdentifier: reuseId)
        collectionR.delegate = self
        collectionR.dataSource = self
        collectionR.backgroundColor = .white
        collectionR.register(HZCalenderCell.classForCoder(), forCellWithReuseIdentifier: reuseId)
        scrollView.addSubview(collectionL)
        scrollView.addSubview(collectionM)
        scrollView.addSubview(collectionR)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension HZCalenderContent: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        scrollView.setContentOffset(collectionM.frame.origin, animated: false)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 42 //(6*7)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseId, for: indexPath) as! HZCalenderCell
        var ary: [HZDayModel]!
        if collectionView == collectionL {
            ary = days_left
        } else if collectionView == collectionM {
            ary = days_middle
        } else if collectionView == collectionR {
            ary = days_right
        }
        let day = ary[indexPath.row]
        cell.label.text = "\(day.year_month_day.day!)"
        if day.isEnable && day.year_month_day.isEque(day: select_day) {
            // 选中的
            cell.label.backgroundColor = hexColor("F69535")
            cell.label.textColor = hexColor("FEFFFF")
            cell.label.layer.shadowColor = UIColor(red: 0.98, green: 0.51, blue: 0.19, alpha: 0.24).cgColor
            cell.label.layer.shadowOffset = CGSize(width: 0, height: 10)
            cell.label.layer.shadowOpacity = 1
            cell.label.layer.shadowRadius = 25
        } else if day.isEnable {
            // 可点击的
            cell.label.backgroundColor = self.collectionL.backgroundColor
            cell.label.textColor = hexColor("626B80")
            cell.label.layer.shadowOpacity = 0
        } else {
            // 不可点击的
            cell.label.backgroundColor = self.collectionL.backgroundColor
            cell.label.textColor = hexColor("9FA5B4")
            cell.label.layer.shadowOpacity = 0
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        var ary: [HZDayModel]!
        if collectionView == collectionL {
            ary = days_left
        } else if collectionView == collectionM {
            ary = days_middle
        } else if collectionView == collectionR {
            ary = days_right
        }
        let day = ary[indexPath.row]
        if day.isEnable {
            self.select_day = day.year_month_day
            collectionL.reloadData()
            collectionM.reloadData()
            collectionR.reloadData()
            delegate?.newSelect(day: self.selectCalendarToString())
        }
    }
    
    func selectCalendarToString() -> (String) {
        let string = "\(select_day.year!)-\(String(format: "%02d", select_day.month!))-\(String(format: "%02d", select_day.day!))"
        return string
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.size.width
        let height = collectionView.frame.size.height
        return CGSize.init(width: width / 7 - 4, height: height / 6)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
}
