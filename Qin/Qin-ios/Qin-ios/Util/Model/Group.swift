//
//  Group.swift
//  Qin-ios
//
//  Created by 杨璨 on 2020/2/14.
//  Copyright © 2020 canyang. All rights reserved.
//

import Foundation
import RealmSwift

public class Group {
    public var ID = ""
    public var Name = ""
    
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
