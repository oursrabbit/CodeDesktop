//
//  Room.swift
//  Qin-ios
//
//  Created by 杨璨 on 2020/1/6.
//  Copyright © 2020 canyang. All rights reserved.
//

import Foundation
import RealmSwift

public class Room: Object {
    @objc dynamic var ID = 0
    @objc dynamic var Name = ""
    
    let Location = LinkingObjects(fromType: Building.self, property: "Rooms")
}
