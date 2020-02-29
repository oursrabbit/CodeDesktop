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
    @objc dynamic var ID = ""
    @objc dynamic var Name = ""
    
    let Rooms = List<Room>()
    
    public static func GetAll(refresh: Bool){
        if refresh == true {
            var DatabaseResults = [[String:Any?]]()
            var getDBR = [[String:Any?]]()
            repeat {
                getDBR = [[String:Any?]]()
                let url = DatabaseHelper.LeancloudAPIBaseURL + "/1.1/classes/Building?order=ID&limit=1000&skip=\(DatabaseResults.count)"
                if let response = DatabaseHelper.LCSearch(searchURL: url) {
                    getDBR = response["results"] as! [[String:Any?]]
                    DatabaseResults.append(contentsOf: getDBR)
                }
            } while getDBR.count != 0
            autoreleasepool {
                let realm = try! Realm()
                for checkLog in DatabaseResults {
                    realm.beginWrite()
                    realm.create(Building.self, value: [
                        "ID" : checkLog["ID"] as! String,
                        "Name" : checkLog["Name"] as! String])
                    try! realm.commitWrite()
                }
            }
        }
    }
}
