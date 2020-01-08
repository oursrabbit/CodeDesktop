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
    @objc dynamic var RoomID = 0
    @objc dynamic var RoomName = ""
    
    let Location = LinkingObjects(fromType: Building.self, property: "Rooms")
    
    override public static func primaryKey() -> String? {
        return "RoomID"
    }
}
