//
//  CalendarMonthCollectionViewCell.swift
//  Qin-ios
//
//  Created by 杨璨 on 2020/2/22.
//  Copyright © 2020 canyang. All rights reserved.
//

import UIKit

class CalendarMonthCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var pointImageView: UIImageView!
    
    func initCellInterface() {
        self.layer.cornerRadius = 5
        self.contentView.layer.cornerRadius = 5
        dayLabel.layer.cornerRadius = 5
        
        dayLabel.clipsToBounds = true
    }
}
