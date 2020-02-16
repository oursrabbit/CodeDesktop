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
    
    public func setSections(sctionIDString: String) {
        SectionsID.removeAll()
        for id in sctionIDString.components(separatedBy: ",") {
            if id != "" {
                SectionsID.append(Int(id)!)
            }
        }
    }
}
