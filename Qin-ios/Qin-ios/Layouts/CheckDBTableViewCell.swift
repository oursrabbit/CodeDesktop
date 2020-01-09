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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
