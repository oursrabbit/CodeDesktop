//
//  StaticData.swift
//  ProjectSolitaire
//
//  Created by 杨璨 on 2019/12/26.
//  Copyright © 2019 canyang. All rights reserved.
//

import Foundation
import RealmSwift

public class StaticData
{
    public static let realm = try! Realm()
}

public class Utils
{
    public static func dateConvertString(date:Date, dateFormat:String = "yyyy-MM-dd") -> String {
        let timeZone = TimeZone.init(identifier: "UTC")
        let formatter = DateFormatter()
        formatter.timeZone = timeZone
        formatter.locale = Locale.init(identifier: "zh_CN")
        formatter.dateFormat = dateFormat
        let date = formatter.string(from: date)
        return date.components(separatedBy: " ").first!
    }
    
    public static func stringConvertDate(string:String?, dateFormat:String = "yyyy-MM-dd") -> Date? {
        let dateFormatter = DateFormatter.init()
        dateFormatter.dateFormat = dateFormat
        if let dateString = string
        {
            let date = dateFormatter.date(from: dateString)
            return date
        }
        else
        {
            return nil
        }
    }
}

public class Project: Object
{
    @objc dynamic public var Name = "";
    @objc dynamic public var StartDate = Date();
    @objc dynamic public var EndDate: Date? = nil;
}

public enum EditProjectType
{
    case Edit
    case Create
    case Delete
}
