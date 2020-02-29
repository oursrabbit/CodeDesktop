//
//  Group.swift
//  Qin-ios
//
//  Created by 杨璨 on 2020/2/14.
//  Copyright © 2020 canyang. All rights reserved.
//

import Foundation
import RealmSwift

public class Group: Object {
    @objc dynamic var ID = ""
    @objc dynamic var Name = ""
    
    public static func GetAll(refresh: Bool){
        if refresh == true {
            var DatabaseResults = [[String:Any?]]()
            var getDBR = [[String:Any?]]()
            repeat {
                getDBR = [[String:Any?]]()
                let url = DatabaseHelper.LeancloudAPIBaseURL + "/1.1/classes/Group?order=ID&limit=1000&skip=\(DatabaseResults.count)"
                if let response = DatabaseHelper.LCSearch(searchURL: url) {
                    getDBR = response["results"] as! [[String:Any?]]
                    DatabaseResults.append(contentsOf: getDBR)
                }
            } while getDBR.count != 0
            autoreleasepool {
                let realm = try! Realm()
                for checkLog in DatabaseResults {
                    realm.beginWrite()
                    realm.create(Group.self, value: [
                        "ID" : checkLog["ID"] as! String,
                        "Name" : checkLog["Name"] as! String])
                    try! realm.commitWrite()
                }
            }
        }
    }
    
    public static func GetGroup() {
        let checkJson = ["StudentID": ApplicationHelper.CurrentUser.ID]
        let checkJSONData = try? JSONSerialization.data(withJSONObject: checkJson, options: [])
        let jsonString = String(data: checkJSONData!, encoding: .utf8)
        let urlString = jsonString!.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        let url = "\(DatabaseHelper.LeancloudAPIBaseURL)/1.1/classes/ReStudentGroup?where=\(urlString)"
        if let response = DatabaseHelper.LCSearch(searchURL: url) {
            let DatabaseResults = response["results"] as! [[String:Any?]]
            for checkLog in DatabaseResults {
                let groupID = checkLog["GroupID"] as! String
                ApplicationHelper.CurrentUser.GroupsID.append(groupID)
            }
        }
    }
}
