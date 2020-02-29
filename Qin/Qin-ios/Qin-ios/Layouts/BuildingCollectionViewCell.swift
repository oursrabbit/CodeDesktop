//
//  BuildingCollectionViewCell.swift
//  Qin-ios
//
//  Created by 杨璨 on 2020/2/9.
//  Copyright © 2020 canyang. All rights reserved.
//

import UIKit

class BuildingCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var buildingImage: UIImageView!
    @IBOutlet weak var buildingNameLabel: UILabel!
    @IBOutlet weak var buildingRoomsLabel: UILabel!
    
    func initCellInterface() {
        self.contentView.layer.cornerRadius = 15
        self.contentView.layer.borderWidth = 0.0

        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width:0,height: 0)
        self.layer.shadowRadius = 5
        self.layer.shadowOpacity = 0.5
        self.layer.masksToBounds = false;
        //self.layer.shadowPath = UIBezierPath(roundedRect:self.contentView.bounds, cornerRadius:self.contentView.layer.cornerRadius).cgPath
    }
}

