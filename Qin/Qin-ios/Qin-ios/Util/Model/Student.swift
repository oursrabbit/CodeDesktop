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
    
    //public var DrawableSchedules = [Schedule]()
    
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
                var currentScheduleDate = Date.addDays(days: 7 * i, to: currentSchedule.StartDate)
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
    
    /*
    public func setDrawableSchedules() {
        DrawableSchedules.removeAll()
        for item in self.Schedules {
            var lastSection = item.SectionsID[0]
            for sectionIndex in 1..<item.SectionsID.count {
                let nextSection = item.SectionsID[sectionIndex]
                if lastSection + sectionIndex != nextSection {
                    createDrawableSchdule(oldSchedule: item, startSectionID: lastSection, endSectionID: item.SectionsID[sectionIndex - 1])
                    lastSection = nextSection
                }
            }
            createDrawableSchdule(oldSchedule: item, startSectionID: lastSection, endSectionID: item.SectionsID.last!)
        }
    }
    
    private func createDrawableSchdule(oldSchedule: Schedule, startSectionID: Int, endSectionID: Int) {
        let newSchedule = Schedule()
        newSchedule.ID = oldSchedule.ID
        newSchedule.WorkingCourseID = oldSchedule.WorkingCourseID
        newSchedule.WorkingDate = oldSchedule.WorkingDate
        newSchedule.WorkingRoomID = oldSchedule.WorkingRoomID
        newSchedule.SectionsID.removeAll()
        for id in startSectionID...endSectionID {
            newSchedule.SectionsID.append(id)
        }
        var useableCellColor = UIColor.scheduleCellColors
        if let preSchedule = DrawableSchedules.last {
            useableCellColor = useableCellColor.filter({$0 != preSchedule.CellColor})
        }
        newSchedule.CellColor = useableCellColor[Int.random(in: 0..<useableCellColor.count)]
        DrawableSchedules.append(newSchedule)
    }
    
    public func getStudentBeaconMinor() -> [UInt8] {
        var bytes:[UInt8] = [0x00, 0x00]
        bytes[0] = (UInt8)(BLE >> 8 & 0xFF)
        bytes[1] = (UInt8)(BLE & 0xFF)
        return bytes
    }*/
    
    /*
    public func getGroupsRegex() -> String {
        var regex = ""
        for group in GroupsID {
            regex = "\(regex)(,\(group.ID))|"
        }
        regex.removeLast()
        return regex
    }*/
}
