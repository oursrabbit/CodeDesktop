//
//  ScheduleTableViewCell.swift
//  Qin-ios
//
//  Created by 杨璨 on 2020/2/15.
//  Copyright © 2020 canyang. All rights reserved.
//

import UIKit

class ScheduleTableViewCell: UITableViewCell {

    @IBOutlet weak var NameLabel: UILabel!
    @IBOutlet weak var RoomLabel: UILabel!
    @IBOutlet weak var DateLabel: UILabel!
    @IBOutlet weak var SectionLabel: UILabel!
    @IBOutlet weak var TimeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
