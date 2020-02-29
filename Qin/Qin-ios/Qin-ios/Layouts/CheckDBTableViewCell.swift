//
//  CheckDBTableViewCell.swift
//  Qin-ios
//
//  Created by 杨璨 on 2020/1/8.
//  Copyright © 2020 canyang. All rights reserved.
//

import UIKit

class CheckDBTableViewCell: UITableViewCell {
    
    @IBOutlet weak var roomidlabel: UILabel!
    @IBOutlet weak var checkdatelabel: UILabel!
    @IBOutlet weak var checktimelabel: UILabel!
    @IBOutlet weak var uiView:UIView!
    @IBOutlet weak var buildingImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func initCellInterface() {
        self.uiView.layer.cornerRadius = 15
        self.uiView.layer.borderWidth = 0.0

        self.uiView.layer.shadowColor = UIColor.black.cgColor
        self.uiView.layer.shadowOffset = CGSize(width:0,height: 0)
        self.uiView.layer.shadowRadius = 5
        self.uiView.layer.shadowOpacity = 0.5
        self.uiView.layer.masksToBounds = false;
        //self.layer.shadowPath = UIBezierPath(roundedRect:self.contentView.bounds, cornerRadius:self.contentView.layer.cornerRadius).cgPath
    }
}
