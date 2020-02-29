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
    public var ID = 0;
    public var SectionsID = [Int]()
    public var WorkingCourseID = 0
    public var WorkingDate = Date()
    public var WorkingRoomID = 0
    
    public var CellColor: UIColor = .blue
    
    public func setSections(sctionIDString: String) {
        SectionsID.removeAll()
        for id in sctionIDString.components(separatedBy: ",") {
            if id != "" {
                SectionsID.append(Int(id)!)
            }
        }
    }
    
    public func getCellX() -> Int {
        let startDate = (try! Realm()).objects(Section.self).filter("ID = \(SectionsID.first!)").first!
        return startDate.StartTime.hour * 60 + startDate.StartTime.min * 1 - 30
    }
    
    public func getCellHeight() -> Int {
        let startTime = (try! Realm()).objects(Section.self).filter("ID = \(SectionsID.first!)").first!.StartTime
        let endTime = (try! Realm()).objects(Section.self).filter("ID = \(SectionsID.last!)").first!.EndTime
        return (endTime.hour * 60 + endTime.min * 1) - (startTime.hour * 60 + startTime.min * 1)
    }
}
