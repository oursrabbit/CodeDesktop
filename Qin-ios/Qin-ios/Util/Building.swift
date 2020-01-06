//
//  Building.swift
//  Qin-ios
//
//  Created by 杨璨 on 2020/1/6.
//  Copyright © 2020 canyang. All rights reserved.
//

import Foundation
import RealmSwift

public class Building: Object {
    @objc dynamic var BuildingID = 0
    @objc dynamic var BuildingName = ""
    
    let Rooms = List<Room>()
}
