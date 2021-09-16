//
//  FilterView.swift
//  ct-sheet-ios
//
//  Created by qingping yi on 2021/9/16.
//

import UIKit
import boss_basic_common_ios
import ct_common_ios

public typealias BackSelectFilterBlock = (_ selectArr: Array<Any>) ->()

class FilterView: UIView {
    // 标题栏高度
    let headerHeight:CGFloat = 47
    
    var titleLabel = UILabel()
    
    public var backSelectFilter: BackSelectFilterBlock?

    // 取消
    var cancelBtn = UIButton()
    
    // 确定
    var confirmBtn = UIButton()
    
    // 筛选
    var labGroup = CBGroupAndStreamView()
    
    
    public required init(frame: CGRect,contetnArr : Array<Any>, titleArr : Array<String>, defaultSelIndexArr : Array<Any> ) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.init(named: "ct_000000-60_FFFFFF-60")
        let header = UIView.init(frame: CGRect.init(x: 0, y:200, width: screenWidth, height: 48))
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
        self.titleLabel.text = "筛选"
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
        self.cancelBtn.addTarget(self, action: #selector(cancelBtnClick), for: UIControl.Event.touchUpInside)
        header.addSubview(self.cancelBtn)
        
        // 确定按钮
        self.confirmBtn = UIButton.init(frame: CGRect.init(x: kScreenWidth - buttonWidth, y: 0, width: buttonWidth, height: 47))
        self.confirmBtn.setTitle("确定", for: UIControl.State.normal)
        self.confirmBtn.titleLabel?.font = mediumFont(size: 15)
        self.confirmBtn.setTitleColor(UIColor.init(named: "title_F09A19"), for: UIControl.State.normal)
        self.confirmBtn.addTarget(self, action: #selector(confirmButtonDidClicked), for: UIControl.Event.touchUpInside)
        header.addSubview(self.confirmBtn)
        self.addSubview(header)

        labGroup = CBGroupAndStreamView.init(frame: CGRect(x: 0, y: header.bottom , width: kScreenWidth, height: kScreenHeight - header.bottom  - 48 * 2))
        labGroup.titleTextFont = .systemFont(ofSize: 14)
        labGroup.titleLabHeight = 30
        labGroup.titleTextColor = .red
        labGroup.isSingle = true
        //使用该参数则默认为多选 isSingle 无效 defaultSelSingleIndeArr 设置无效
        labGroup.defaultSelIndexArr = [0,0]
        //分别设置每个组的单选与多选
        labGroup.defaultGroupSingleArr = [0,0]
        labGroup.defaultSelIndexArr = defaultSelIndexArr
        labGroup.setDataSource(contetnArr: contetnArr, titleArr: titleArr)
        self.addSubview(labGroup)
        labGroup.confirmReturnValueClosure = { (selArr,groupIdArr) in
            print(selArr)
            if let block = self.backSelectFilter{
                block(selArr)
            }
        }
        
        labGroup.currentSelValueClosure = {
            (valueStr,index,groupId) in
                print("\(valueStr) index = \(index), groupid = \(groupId)")
        }
        let bottomView = UIView.init(frame: CGRect.init(x: 0, y: kScreenHeight - 48 * 2, width: screenWidth, height: 48 * 2))
        bottomView.backgroundColor = .white
        self.addSubview(bottomView)
        
        let btnMargin = (kScreenWidth - 2 * 120 - 16) * 0.5
            // 重置按钮
        let resetBtn = UIButton.init(frame: CGRect.init(x: btnMargin, y: 14, width: 120, height: 48))
        resetBtn.setTitle("重置", for: UIControl.State.normal)
        resetBtn.titleLabel?.font = mediumFont(size: 17)
        resetBtn.backgroundColor = UIColor.init(named: "ct_000000-10")
        resetBtn.setTitleColor(UIColor.black, for: UIControl.State.normal)
        resetBtn.addTarget(self, action: #selector(resetBtnClick), for: UIControl.Event.touchUpInside)
        bottomView.addSubview(resetBtn)
        resetBtn.layer.cornerRadius = 4
        // 确定按钮
        let sureBtn = UIButton.init(frame: CGRect.init(x: kScreenWidth - btnMargin - 120, y: 14, width: 120, height: 48))
        sureBtn.setTitle("确定", for: UIControl.State.normal)
        sureBtn.titleLabel?.font = mediumFont(size: 17)
        sureBtn.backgroundColor = UIColor.init(named: "title_F09A19")
        sureBtn.setTitleColor(UIColor.white, for: UIControl.State.normal)
        sureBtn.addTarget(self, action: #selector(confirmButtonDidClicked), for: UIControl.Event.touchUpInside)
        bottomView.addSubview(sureBtn)
        sureBtn.layer.cornerRadius = 4
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
 
    // 确认
    @objc func confirmButtonDidClicked() {
        self.removeFromSuperview()
        labGroup.comfirm()
    }
    
    // 重置
    @objc func resetBtnClick()  {
        labGroup.reload()
    }
    
    @objc func cancelBtnClick()  {
        self.removeFromSuperview()
    }
}
