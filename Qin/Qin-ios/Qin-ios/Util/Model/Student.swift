//
//  Student.swift
//  Qin-ios
//
//  Created by 杨璨 on 2020/1/6.
//  Copyright © 2020 canyang. All rights reserved.
//

import Foundation
import UIKit

public class Student {
    public var LCObjectID: String = ""
    public var ID: String = ""
    public var Advertising: Int = 0
    public var BaiduFaceID: String = ""
    public var BLE: Int = 0
    public var Name: String = ""
    
    public var GroupsID = [String]()
    public var Schedules = [Schedule]()
    
    public static func SetupCurrentStudent() -> Bool {
        let checkJson = ["ID": ApplicationHelper.CurrentUser.ID]
        let checkJSONData = try? JSONSerialization.data(withJSONObject: checkJson, options: [])
        let jsonString = String(data: checkJSONData!, encoding: .utf8)
        let urlString = jsonString!.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        let url = "\(DatabaseHelper.LeancloudAPIBaseURL)/1.1/classes/Student?where=\(urlString)"
        if let response = DatabaseHelper.LCSearch(searchURL: url) {
            let DatabaseResults = response["results"] as! [[String:Any?]]
            if DatabaseResults.count != 1 {
                return false
            } else {
                //Student Info
                let checkLog = DatabaseResults[0]
                ApplicationHelper.CurrentUser.Advertising = 0
                ApplicationHelper.CurrentUser.BaiduFaceID = checkLog["BaiduFaceID"] as! String
                ApplicationHelper.CurrentUser.LCObjectID = checkLog["objectId"] as! String
                ApplicationHelper.CurrentUser.BLE = checkLog["BLE"] as! Int
                ApplicationHelper.CurrentUser.ID = checkLog["ID"] as! String
                ApplicationHelper.CurrentUser.Name = checkLog["Name"] as! String
                
                Group.GetGroup()
                Schedule.GetSchedules()
            }
        } else {
            return false;
        }
        return true
    }
    
    public func GetScheduleBy(date: Date) -> [Schedule] {
        var scheduleOnDate = [Schedule]()
        for currentSchedule in Schedules {
            for i in 0..<currentSchedule.ContinueWeek {
                let currentScheduleDate = Date.addDays(days: 7 * i, to: currentSchedule.StartDate)
                if currentScheduleDate.year == date.year && currentScheduleDate.monthInYear == date.monthInYear && currentScheduleDate.dayInMonth == date.dayInMonth {
                    scheduleOnDate.append(currentSchedule)
                    break
                }
            }
        }
        return scheduleOnDate
    }
    
    public func GetCheckLogBy(startDate: Date, endDate: Date, roomID: String) -> CheckLog? {
        for checkLog in CheckLog.GetAll() {
            if checkLog.CheckDate.compare(startDate) == .orderedDescending && checkLog.CheckDate.compare(endDate) == .orderedAscending {
                if checkLog.RoomID == roomID {
                    return checkLog
                }
            }
        }
        return nil
    }
}
