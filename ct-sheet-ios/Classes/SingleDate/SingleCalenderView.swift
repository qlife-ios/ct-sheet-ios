//
//  SingleCalenderView.swift
//  ct-sheet-ios
//
//  Created by qingping yi on 2021/9/9.
//

import UIKit
import boss_basic_common_ios
import ct_common_ios

public class SingleCalenderView: UIView {

    public typealias BackSelectDataBlock = (_ selectedTime: String) ->()
    
    public var backSelectData: BackSelectDataBlock?
    
    var selectString: String?
    
    /// 标题栏高度
    let headerHeight:CGFloat = 47
    
    var titleLabel = UILabel()
    
    // 取消
    var cancelBtn = UIButton()
    
    // 确定
    var confirmBtn = UIButton()
    
    lazy var calendar: HZCalenderContent = {
        var dateCompents = DateComponents.init()
        let date = self.selectString?.toDate()?.date ?? Date.init()
        dateCompents.year = date.year
        dateCompents.month = date.month
        dateCompents.day = date.day
        let calendar = HZCalenderContent.init(frame: CGRect.init(x: 0, y: kScreenHeight - 330, width: kScreenWidth, height: 330), selectDay: dateCompents)
        calendar.backgroundColor = UIColor.white
        calendar.delegate = self
        return calendar
    }()
    
    public required init(frame: CGRect, selectedStr: String? ) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.init(named: "ct_000000-60_FFFFFF-60")
        self.selectString = selectedStr
        self.addSubview(self.calendar)
        let header = UIView.init(frame: CGRect.init(x: 0, y: kScreenHeight - 330 - 48, width: screenWidth, height: 48))
        header.backgroundColor = UIColor.init(named: "linecolor_E8E8E8_2B2B2B")
        let cornerRadiusPath = UIBezierPath(roundedRect: header.bounds, byRoundingCorners: [.topLeft,.topRight], cornerRadii: CGSize(width: 13, height: 13))
        let cornerRadiusLayer = CAShapeLayer()
        cornerRadiusLayer.frame = header.bounds
        cornerRadiusLayer.path = cornerRadiusPath.cgPath
        header.layer.mask = cornerRadiusLayer
        let buttonWidth: CGFloat = 74
        // 标题
        self.titleLabel = UILabel.init(frame: CGRect.init(x: buttonWidth, y: 0, width: kScreenWidth - 2 * buttonWidth, height: 47.0))
        self.titleLabel.textAlignment = NSTextAlignment.center
        self.titleLabel.textColor = UIColor.init(named: "ct_000000-90_FFFFFF-90")
        self.titleLabel.font = mediumFont(size: 16)
        self.titleLabel.text = "选择日期"
        header.addSubview(self.titleLabel)
        // 线条
        let line = UIView.init(frame: CGRect.init(x: 0, y: self.titleLabel.bottom - 1, width: kScreenWidth, height: 1))
        line.backgroundColor = UIColor.init(named: "ct_DFDFDF")
        header.addSubview(line)
            // 取消按钮
        self.cancelBtn = UIButton.init(frame: CGRect.init(x: 0, y: 0, width: buttonWidth, height: 47))
        self.cancelBtn.setTitle("取消", for: UIControl.State.normal)
        self.cancelBtn.titleLabel?.font = mediumFont(size: 15)
        self.cancelBtn.setTitleColor(UIColor.init(named: "ct_000000-60_FFFFFF-60"), for: UIControl.State.normal)
        self.cancelBtn.addTarget(self, action: #selector(tagBlackBg), for: UIControl.Event.touchUpInside)
        header.addSubview(self.cancelBtn)
        
        // 确定按钮
        self.confirmBtn = UIButton.init(frame: CGRect.init(x: kScreenWidth - buttonWidth, y: 0, width: buttonWidth, height: 47))
        self.confirmBtn.setTitle("确定", for: UIControl.State.normal)
        self.confirmBtn.titleLabel?.font = mediumFont(size: 15)
        self.confirmBtn.setTitleColor(UIColor.init(named: "title_F09A19"), for: UIControl.State.normal)
        self.confirmBtn.addTarget(self, action: #selector(confirmButtonDidClicked), for: UIControl.Event.touchUpInside)
        header.addSubview(self.confirmBtn)
        self.addSubview(header)
               
    }
    
    // MARK: - 按钮方法
    @objc func confirmButtonDidClicked() {
        // 未选中任何一行
        if let str = self.selectString, str.count > 0 {
            if let block = self.backSelectData {
                block(str)
            }
            self.alertDismiss()
        }else{
            let window = UIApplication.shared.keyWindow
            window?.showfailMessage(message: "请选择", handle: nil)
          
        }
    }
    
    @objc func tagBlackBg() {
        self.alertDismiss()
    }
    
    @objc func tagBlackBgGesture() {
        self.alertDismiss()
    }
    
    // MARK: - 弹框动画
    func alertShow() -> Void {
        let window = UIApplication.shared.keyWindow
        window?.addSubview(blackBg)
        window?.addSubview(self)
        self.blackBg.alpha = 0
        self.frame = CGRect.init(x: 0, y: screenHeight, width: screenWidth, height: self.bounds.size.height)
        UIView.animate(withDuration: 0.3) {
            self.blackBg.alpha = 0.5
            self.frame = CGRect.init(x: 0, y: screenHeight - self.bounds.size.height, width: screenWidth, height: self.bounds.size.height)
        }
    }
    
    func alertDismiss() -> Void {
        self.frame = CGRect.init(x: 0, y: screenHeight - self.bounds.size.height, width: screenWidth, height: self.bounds.size.height)
        self.blackBg.alpha = 0.5
        UIView.animate(withDuration: 0.3) {
            self.blackBg.alpha = 0
            self.frame = CGRect.init(x: 0, y: screenHeight, width: screenWidth, height: self.bounds.size.height)
            self.blackBg.removeFromSuperview()
        }
    }
    
    lazy var blackBg: UIView = {
        let blackBg = UIView.init(frame: CGRect.init(x: 0, y: 0, width: screenWidth, height: screenHeight))
        blackBg.backgroundColor = UIColor.black
        blackBg.alpha = 0.5
        blackBg.isUserInteractionEnabled = true
        blackBg.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(tagBlackBgGesture)))
        return blackBg
    }()
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension SingleCalenderView: HZCalenderContentDelegate{
    
    func newSelect(day: String) {
        self.selectString = day
    }
    func newPage(year: String, month: String) {
        
    }

}
