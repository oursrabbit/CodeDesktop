//
//  ReBuildingRoom.swift
//  Qin-ios
//
//  Created by 杨璨 on 2020/2/29.
//  Copyright © 2020 canyang. All rights reserved.
//

import Foundation
import RealmSwift

public class ReBuildingRoom {
    public static func CreateBuildingRoom(refresh: Bool) {
        if refresh == true {
            var DatabaseResults = [[String:Any?]]()
            var getDBR = [[String:Any?]]()
            repeat {
                getDBR = [[String:Any?]]()
                let url = DatabaseHelper.LeancloudAPIBaseURL + "/1.1/classes/ReBuildingRoom?order=ID&limit=1000&skip=\(DatabaseResults.count)"
                if let response = DatabaseHelper.LCSearch(searchURL: url) {
                    getDBR = response["results"] as! [[String:Any?]]
                    DatabaseResults.append(contentsOf: getDBR)
                }
            } while getDBR.count != 0
            Building.GetAll(refresh: true)
            Room.GetAll(refresh: true)
            autoreleasepool {
                let realm = try! Realm()
                for checkLog in DatabaseResults {
                    realm.beginWrite()
                    let buildingID = checkLog["BuildingID"] as! String
                    let roomID = checkLog["RoomID"] as! String
                    if let building = realm.objects(Building.self).first(where: {$0.ID == buildingID}) {
                        if let room = realm.objects(Room.self).first(where: {$0.ID == roomID}) {
                            room.Location = building
                            building.Rooms.append(room)
                        }
                    }
                    try! realm.commitWrite()
                }
            }
        }
    }
}
