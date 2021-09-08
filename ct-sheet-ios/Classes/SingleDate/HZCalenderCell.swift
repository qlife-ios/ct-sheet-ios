//
//  HZCalenderCell.swift
//  CalendarTest
//
//  Created by welkj on 2017/10/25.
//  Copyright © 2017年 Heinz. All rights reserved.
//

import UIKit
import boss_basic_common_ios

class HZCalenderCell: UICollectionViewCell {
    
    var label: UILabel = UILabel.init()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let labelWidth:CGFloat = 36
        
        label.textAlignment = .center
        label.font = regularFont(size: 14)
        label.layer.cornerRadius = labelWidth/2
        label.clipsToBounds = true
        self.addSubview(label)
        
        //约束
        label.translatesAutoresizingMaskIntoConstraints = false
        self.addConstraint(NSLayoutConstraint(item: label, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: label, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: label, attribute: .width, relatedBy: .greaterThanOrEqual, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: labelWidth))
        self.addConstraint(NSLayoutConstraint(item: label, attribute: .height, relatedBy: .greaterThanOrEqual, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: labelWidth))
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
