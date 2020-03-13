//
//  Schedule.swift
//  Qin-ios
//
//  Created by 杨璨 on 2020/2/14.
//  Copyright © 2020 canyang. All rights reserved.
//

import Foundation
import RealmSwift

public class Schedule {
    public var ID = ""
    public var StartDate = Date()
    public var ContinueWeek = 0
    public var StartSectionID = ""
    public var ContinueSection = 0
    public var RoomID = ""
    public var CourseID = ""
    public var ProfessorID = [String]()
    
    public var CellColor: UIColor = .blue
    
    public func getCellX() -> Int {
        let startDate = (try! Realm()).objects(Section.self).first(where: {$0.ID == StartSectionID})!
        return startDate.StartTime.hour * 60 + startDate.StartTime.min * 1 - 30
    }
    
    public func getCellHeight() -> Int {
        let startSection = (try! Realm()).objects(Section.self).first(where: {$0.ID == StartSectionID})!
        let startTime = startSection.StartTime
        let endTime = (try! Realm()).objects(Section.self).first(where: {$0.Order == (startSection.Order + ContinueSection - 1)})!.EndTime
        return (endTime.hour * 60 + endTime.min * 1) - (startTime.hour * 60 + startTime.min * 1)
    }
    
    public static func GetSchedules() {
        let checkJson = ["StudentID": ["$regex":"(^\(ApplicationHelper.CurrentUser.ID);)|(;\(ApplicationHelper.CurrentUser.ID);)|(;\(ApplicationHelper.CurrentUser.ID)$)|(^\(ApplicationHelper.CurrentUser.ID)$)"]]
        let checkJSONData = try? JSONSerialization.data(withJSONObject: checkJson, options: [])
        let jsonString = String(data: checkJSONData!, encoding: .utf8)
        let urlString = jsonString!.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        let url = "\(DatabaseHelper.LeancloudAPIBaseURL)/1.1/classes/Schedule?where=\(urlString)"
        if let response = DatabaseHelper.LCSearch(searchURL: url) {
            ApplicationHelper.CurrentUser.Schedules.removeAll()
            let DatabaseResults = response["results"] as! [[String:Any?]]
            for checkLog in DatabaseResults {
                let newSchedule = Schedule()
                newSchedule.ID = checkLog["ID"] as! String
                newSchedule.StartDate = (checkLog["StartDate"] as! String).dateDate!
                newSchedule.ContinueWeek = checkLog["ContinueWeek"] as! Int
                newSchedule.StartSectionID = checkLog["StartSectionID"] as! String
                newSchedule.ContinueSection = checkLog["ContinueSection"] as! Int
                newSchedule.CourseID = checkLog["CourseID"] as! String
                newSchedule.RoomID = checkLog["RoomID"] as! String
                newSchedule.ProfessorID = (checkLog["ProfessorID"] as! String).components(separatedBy: ";")
                ApplicationHelper.CurrentUser.Schedules.append(newSchedule)
            }
            //ApplicationHelper.CurrentUser.setDrawableSchedules()
        }
    }
}
