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
    public var SchoolID: String = ""
    public var Advertising: String = ""
    public var BaiduFaceID: String = ""
    public var ID: Int = 0
    public var Name: String = ""
    
    public var Groups = [Group]()
    public var Schedules = [Schedule]()
    
    public var DrawableSchedules = [Schedule]()
    
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
        bytes[0] = (UInt8)(ID >> 8 & 0xFF)
        bytes[1] = (UInt8)(ID & 0xFF)
        return bytes
    }
    
    public func getGroupsRegex() -> String {
        var regex = ""
        for group in Groups {
            regex = "\(regex)(,\(group.ID))|"
        }
        regex.removeLast()
        return regex
    }
}
