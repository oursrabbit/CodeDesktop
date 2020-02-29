//
//  CheckLog.swift
//  Qin-ios
//
//  Created by 杨璨 on 2020/1/6.
//  Copyright © 2020 canyang. All rights reserved.
//

import Foundation

public class CheckLog {
    public var StudentID = ""
    public var RoomID = ""
    public var CheckDate = Date()
    
    public static func GetAll() -> [CheckLog] {
        var checkLogs = [CheckLog]()
        var DatabaseResults = [[String:Any?]]()
        var getDBR = [[String:Any?]]()
        repeat {
            getDBR = [[String:Any?]]()
            let checkJson = ["StudentID": ApplicationHelper.CurrentUser.ID]
            let checkJSONData = try? JSONSerialization.data(withJSONObject: checkJson, options: [])
            let jsonString = String(data: checkJSONData!, encoding: .utf8)
            let urlString = jsonString!.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
            let url = "\(DatabaseHelper.LeancloudAPIBaseURL)/1.1/classes/CheckRecording?where=\(urlString)&order=createAt&limit=1000&skip=\(DatabaseResults.count)"
            if let response = DatabaseHelper.LCSearch(searchURL: url) {
                getDBR = response["results"] as! [[String:Any?]]
                DatabaseResults.append(contentsOf: getDBR)
            }
        } while getDBR.count != 0
        for checkLog in DatabaseResults {
            let newLog = CheckLog()
            newLog.StudentID = checkLog["StudentID"] as! String
            newLog.RoomID = checkLog["RoomID"] as! String
            newLog.CheckDate = (checkLog["createdAt"] as! String).iso8601!
            checkLogs.append(newLog)
        }
        return checkLogs
    }
}
