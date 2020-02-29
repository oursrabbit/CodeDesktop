//
//  Section.swift
//  Qin-ios
//
//  Created by 杨璨 on 2020/2/14.
//  Copyright © 2020 canyang. All rights reserved.
//

import Foundation
import RealmSwift

public class Section: Object {
    @objc dynamic var ID = ""
    @objc dynamic var StartTime = Date()
    @objc dynamic var EndTime = Date()
    @objc dynamic var Name = ""
    @objc dynamic var Order = 0
    
    public static func GetAll(refresh: Bool){
        if refresh == true {
            var DatabaseResults = [[String:Any?]]()
            var getDBR = [[String:Any?]]()
            repeat {
                getDBR = [[String:Any?]]()
                let url = DatabaseHelper.LeancloudAPIBaseURL + "/1.1/classes/Section?order=ID&limit=1000&skip=\(DatabaseResults.count)"
                if let response = DatabaseHelper.LCSearch(searchURL: url) {
                    getDBR = response["results"] as! [[String:Any?]]
                    DatabaseResults.append(contentsOf: getDBR)
                }
            } while getDBR.count != 0
            autoreleasepool {
                let realm = try! Realm()
                for checkLog in DatabaseResults {
                    realm.beginWrite()
                    realm.create(Section.self, value: [
                        "ID" : checkLog["ID"] as! String,
                        "StartTime" : (checkLog["StartTime"] as! String).sectionTimeDate!,
                        "EndTime" : (checkLog["EndTime"] as! String).sectionTimeDate!,
                        "Name" : checkLog["Name"] as! String,
                        "Order" : checkLog["Order"] as! Int])
                    try! realm.commitWrite()
                }
            }
        }
    }
}

