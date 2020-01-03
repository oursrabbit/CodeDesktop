//
//  YearCollectionViewCell.swift
//  ProjectSolitaire
//
//  Created by 杨璨 on 2020/1/3.
//  Copyright © 2020 canyang. All rights reserved.
//

import UIKit

class YearCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var yearLabel: UILabel!
    
    public func setupInterface(year:Int) {
        yearLabel.text = String(year);
    }
}
