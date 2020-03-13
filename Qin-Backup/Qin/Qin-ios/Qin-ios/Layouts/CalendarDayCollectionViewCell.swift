//
//  CalendarDayCollectionViewCell.swift
//  Qin-ios
//
//  Created by 杨璨 on 2020/2/21.
//  Copyright © 2020 canyang. All rights reserved.
//

import UIKit

class CalendarDayCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var dayInMonthLabel: UILabel!
    @IBOutlet weak var dayInWeekLabel: UILabel!
    
    func initCellInterface() {
        self.layer.cornerRadius = 5
        self.contentView.layer.cornerRadius = 15
        dayInWeekLabel.layer.cornerRadius = 15
        dayInWeekLabel.layer.cornerRadius = 15
    }
}
