//
//  StaticData.swift
//  Qin-ios
//
//  Created by 杨璨 on 2020/1/6.
//  Copyright © 2020 canyang. All rights reserved.
//

import Foundation
import AVFoundation
import CoreLocation
import UIKit
import CoreTelephony
import RealmSwift

public enum QinMessage {
    case NetError
    case ApplicationVersionError
    case Nothing
    case Success
    case DatabaseUpdated
}

public protocol StaticDataUpdateInfoDelegate: NSObjectProtocol{
    func updateInfomation(message: String)
}


public class ApplicationHelper {
    public static var Orientation = false
    public static var CurrentUser = Student()
    public static var CheckInRoomID = 0;
    
    public static let localVersion = 6
    public static var serverVersion = 0
    public static var databaseVersion = 0
    public static var launchImageVersion = 0
    
    public static func checkVersion(listener: StaticDataUpdateInfoDelegate?, completionHandler: @escaping (QinMessage) -> Void) {
        listener?.updateInfomation(message: "正在检测软件版本...")
        let url = DatabaseHelper.LeancloudAPIBaseURL + "/1.1/classes/ApplicationData/5e184373562071008e2f4a0a";
        DatabaseHelper.LCSearch(searchURL: url) { json, error in
            if error == nil {
                ApplicationHelper.serverVersion = json["ApplicationVersion"] as! Int
                ApplicationHelper.databaseVersion = json["DatabaseVersion"] as! Int
                ApplicationHelper.launchImageVersion = json["LaunchImageVersion"] as! Int
                if ApplicationHelper.localVersion == ApplicationHelper.serverVersion {
                    completionHandler(.Success)
                } else {
                    UserDefaults.standard.set(-1, forKey: "localDataVersion")
                    UserDefaults.standard.set(-1, forKey: "launchImageVersion")
                    completionHandler(.ApplicationVersionError)
                }
            } else {
                completionHandler(.NetError)
            }
        }
    }
    
    public static func checkLocalDatabaseVersion(listener: StaticDataUpdateInfoDelegate?, completionHandler: @escaping (QinMessage) -> Void) {
        listener?.updateInfomation(message: "正在更新本地数据库...")
        var localDataVersion = -1
        let localStore = UserDefaults.standard
        if let _ = localStore.object(forKey: "localDataVersion") {
            localDataVersion = localStore.integer(forKey: "localDataVersion")
        }
        if localDataVersion == ApplicationHelper.databaseVersion {
            completionHandler(.Success)
        } else {
            autoreleasepool {
                let realm = try! Realm()
                realm.beginWrite()
                realm.deleteAll()
                try! realm.commitWrite()
            }
            
            //*** MUST BE IN ORDER ***
            //Building
            self.updateBuildingDatabase(listener: listener, completionHandler: { updateBuilding in
                switch updateBuilding {
                case .NetError:
                    completionHandler(.NetError)
                    break
                default:
                    //Room
                    self.updateRoomDatabase(listener: listener, completionHandler: { updateRoom in
                        switch updateRoom {
                        case .NetError:
                            completionHandler(.NetError)
                            break
                        default:
                            //Section
                            self.updateSectionDatabase(listener: listener, completionHandler: { updateSection in
                                switch updateSection {
                                case .NetError:
                                    completionHandler(.NetError)
                                    break
                                default:
                                    //Course
                                    self.updateCourseDatabase(listener: listener, completionHandler: { updateCourse in
                                        switch updateCourse {
                                        case .NetError:
                                            completionHandler(.NetError)
                                            break
                                        default:
                                            //Local DB
                                            UserDefaults.standard.set(ApplicationHelper.databaseVersion, forKey: "localDataVersion")
                                            completionHandler(.DatabaseUpdated)
                                            break
                                        }
                                    })
                                    break
                                }
                            })
                            break
                        }
                    })
                    break
                }
            })
        }
    }
    
    public static func updateBuildingDatabase(listener: StaticDataUpdateInfoDelegate?, completionHandler: @escaping (QinMessage) -> Void) {
        listener?.updateInfomation(message: "正在更新建筑信息...")
        let url = DatabaseHelper.LeancloudAPIBaseURL + "/1.1/classes/Building?limit=1000&&&&"
        DatabaseHelper.LCSearch(searchURL: url) { response, error in
            if error == nil {
                let DatabaseResults = response["results"] as! [[String:Any?]]
                autoreleasepool {
                    let realm = try! Realm()
                    for checkLog in DatabaseResults {
                        realm.beginWrite()
                        realm.create(Building.self, value: [
                            "ID" : checkLog["ID"] as! Int,
                            "Name" : checkLog["Name"] as! String])
                        try! realm.commitWrite()
                    }
                }
                completionHandler(.DatabaseUpdated)
            } else {
                completionHandler(.NetError)
            }
        }
    }
    
    public static func updateRoomDatabase(listener: StaticDataUpdateInfoDelegate?, completionHandler: @escaping (QinMessage) -> Void) {
        listener?.updateInfomation(message: "正在更新房间信息...")
        let url = DatabaseHelper.LeancloudAPIBaseURL + "/1.1/classes/Room?limit=1000&&&&"
        DatabaseHelper.LCSearch(searchURL: url) { roomresponse, roomerror in
            if roomerror == nil {
                let DatabaseResults = roomresponse["results"] as! [[String:Any?]]
                listener?.updateInfomation(message: "正在更新房间信息...")
                autoreleasepool {
                    let realm = try! Realm()
                    for checkLog in DatabaseResults {
                        realm.beginWrite()
                        let newRoom = realm.create(Room.self, value: [
                            "ID" : checkLog["ID"] as! Int,
                            "Name" : checkLog["Name"] as! String
                        ])
                        let locationID = checkLog["LocationID"] as! Int
                        let building = realm.objects(Building.self).filter("ID = \(locationID)").first!
                        building.Rooms.append(newRoom)
                        try! realm.commitWrite()
                    }
                }
                completionHandler(.DatabaseUpdated)
            } else {
                completionHandler(.NetError)
            }
        }
    }
    
    public static func updateSectionDatabase(listener: StaticDataUpdateInfoDelegate?, completionHandler: @escaping (QinMessage) -> Void) {
        listener?.updateInfomation(message: "正在更新学时信息...")
        let url = DatabaseHelper.LeancloudAPIBaseURL + "/1.1/classes/Section?limit=1000&&&&"
        DatabaseHelper.LCSearch(searchURL: url) { response, error in
            if error == nil {
                let DatabaseResults = response["results"] as! [[String:Any?]]
                autoreleasepool {
                    let realm = try! Realm()
                    for checkLog in DatabaseResults {
                        realm.beginWrite()
                        realm.create(Section.self, value: [
                            "ID" : checkLog["ID"] as! Int,
                            "StartTime" : (checkLog["StartTime"] as! String).timeDate!,
                            "EndTime" : (checkLog["EndTime"] as! String).timeDate!,
                            "Name" : checkLog["Name"] as! String,
                            "Order" : checkLog["Order"] as! Int
                        ])
                        try! realm.commitWrite()
                    }
                }
                completionHandler(.DatabaseUpdated)
            } else {
                completionHandler(.NetError)
            }
        }
    }
    
    public static func updateCourseDatabase(listener: StaticDataUpdateInfoDelegate?, completionHandler: @escaping (QinMessage) -> Void) {
        listener?.updateInfomation(message: "正在更新课程信息...")
        let url = DatabaseHelper.LeancloudAPIBaseURL + "/1.1/classes/Course?limit=1000&&&&"
        DatabaseHelper.LCSearch(searchURL: url) { response, error in
            if error == nil {
                let DatabaseResults = response["results"] as! [[String:Any?]]
                autoreleasepool {
                    let realm = try! Realm()
                    for checkLog in DatabaseResults {
                        realm.beginWrite()
                        realm.create(Course.self, value: [
                            "ID" : checkLog["ID"] as! Int,
                            "Name" : checkLog["Name"] as! String])
                        try! realm.commitWrite()
                    }
                }
                completionHandler(.DatabaseUpdated)
            } else {
                completionHandler(.NetError)
            }
        }
    }
    
    public static func getaccessToken(completionHandler: @escaping (String?) -> Void)
    {
        let url = URL(string: "https://aip.baidubce.com/oauth/2.0/token?grant_type=client_credentials&client_id=CGFGbXrchcUA0KwfLTpCQG0T&client_secret=IyGcGlMoB26U1Zf2s2qX05O9dETGGxHg")!
        let session = URLSession.shared;
        var request = URLRequest(url: url);
        request.httpMethod = "POST";
        session.dataTask(with: request){ data, response, error in
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: []) as! [String:Any]
                completionHandler(json["access_token"] as? String)
            } catch {
                completionHandler(nil)
            }
        }.resume()
    }
        
    public static func checkLaunchImageVersion() {
        var launchImageVersion = -1
        let localStore = UserDefaults.standard
        if let _ = localStore.object(forKey: "launchImageVersion") {
            launchImageVersion = localStore.integer(forKey: "launchImageVersion")
        }
        if launchImageVersion != ApplicationHelper.launchImageVersion {
            let realm = try! Realm()
            realm.beginWrite()
            realm.delete(realm.objects(LaunchImage.self))
            try! realm.commitWrite()
            let url = DatabaseHelper.LeancloudAPIBaseURL + "/1.1/classes/LaunchImage?limit=1000&&&&"
            DatabaseHelper.LCSearch(searchURL: url) { response, error in
                if error == nil {
                    let DatabaseResults = response["results"] as! [[String:Any?]]
                    for checkLog in DatabaseResults {
                            createLaunchImage(json: checkLog)
                    }
                    UserDefaults.standard.set(ApplicationHelper.launchImageVersion, forKey: "launchImageVersion")
                }
            }
        }
    }
    
    public static func createLaunchImage(json: [String: Any?]) {
        let leancloudSession = URLSession.shared;
        let launchImageJson = json["LaunchImageData"] as! [String:Any]
        var launchImageURL = launchImageJson["url"] as! String
        launchImageURL = launchImageURL.replacingOccurrences(of: "http://", with: "https://")
        var launchImageRequest = URLRequest(url: URL(string: launchImageURL)!)
        launchImageRequest.httpMethod = "GET"
        launchImageRequest.setValue(DatabaseHelper.LeancloudAppid, forHTTPHeaderField: DatabaseHelper.LeancloudIDHeader)
        launchImageRequest.setValue(DatabaseHelper.LeancloudAppKey, forHTTPHeaderField: DatabaseHelper.LeancloudKeyHeader)
        leancloudSession.dataTask(with: launchImageRequest, completionHandler: { launchImageData, response, error in
            if error == nil {
                let launchImageBackgroundJson = json["LaunchImageBackgroundData"] as! [String:Any]
                var launchImageBackgroundURL = launchImageBackgroundJson["url"] as! String
                launchImageBackgroundURL = launchImageBackgroundURL.replacingOccurrences(of: "http://", with: "https://")
                var launchImageBackgroundRequest = URLRequest(url: URL(string: launchImageBackgroundURL)!)
                launchImageBackgroundRequest.httpMethod = "GET"
                launchImageBackgroundRequest.setValue(DatabaseHelper.LeancloudAppid, forHTTPHeaderField: DatabaseHelper.LeancloudIDHeader)
                launchImageBackgroundRequest.setValue(DatabaseHelper.LeancloudAppKey, forHTTPHeaderField: DatabaseHelper.LeancloudKeyHeader)
                leancloudSession.dataTask(with: launchImageBackgroundRequest, completionHandler: { launchImageBackgroundData, response, error in
                    if error == nil {
                        let realm = try! Realm()
                        realm.beginWrite()
                        let newLaunchImage = realm.create(LaunchImage.self)
                        newLaunchImage.LaunchImage = launchImageData
                        newLaunchImage.LaunchImageBackground = launchImageBackgroundData
                        try! realm.commitWrite()
                        print("Save Launch Image SUCCESS")
                }}).resume()
        }}).resume()
    }
}

extension ISO8601DateFormatter {
    convenience init(_ formatOptions: Options, timeZone: TimeZone = TimeZone(secondsFromGMT: 0)!) {
        self.init()
        self.formatOptions = formatOptions
        self.timeZone = timeZone
    }
}

extension Formatter {
    static let iso8601 = ISO8601DateFormatter([.withInternetDateTime, .withFractionalSeconds])
}

extension Date {
    var iso8601: String {
        return Formatter.iso8601.string(from: self)
    }
    
    var yearMonthStringZH: String {
        let df = DateFormatter()
        df.dateFormat = "yyyy年MM月"
        return df.string(from: self)
    }
    
    var longString: String {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return df.string(from: self)
    }
    
    var dateString: String {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        return df.string(from: self)
    }
    
    var timeString: String {
        let df = DateFormatter()
        df.dateFormat = "HH:mm:ss"
        return df.string(from: self)
    }
    
    var shortTimeString: String {
        let df = DateFormatter()
        df.dateFormat = "HH:mm"
        return df.string(from: self)
    }
    
    var dayInMonth: Int {
        return Calendar.current.component(.day, from: self)
    }
    
    var dayInMonthString: String {
        let df = DateFormatter()
        df.dateFormat = "dd"
        return df.string(from: self)
    }
    
    var daysInMonth: Int {
        return Calendar.current.range(of: .day, in: .month, for: self)!.count
    }
    
    var dayInWeek: Int {
        return Calendar.current.component(.weekday, from: self)
    }
    
    var dayInWeekString: String {
        let weekDayString = ["", "Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
        return weekDayString[self.dayInWeek]
    }
    
    var year: Int {
        return Calendar.current.component(.year, from: self)
    }
    
    var monthInYear: Int {
        return Calendar.current.component(.month, from: self)
    }
    
    var min: Int {
        return Calendar.current.component(.minute, from: self)
    }
    
    var hour: Int {
        return Calendar.current.component(.hour, from: self)
    }
    
    static func getIndexRow(year: Int, month: Int) -> [Int] {
        let firstDay = Calendar.current.date(from: DateComponents(year: year, month: month, day: 1))!
        var rowIndex = [Int]()
        for day in 0..<firstDay.daysInMonth {
            rowIndex.append(6 + firstDay.dayInWeek + day)
        }
        return rowIndex
    }
    
    static func getDayByIndexRow(year: Int, month: Int, row: Int, column: Int) -> Int {
        if month == 2 {
            print("")
        }
        let firstDay = Calendar.current.date(from: DateComponents(year: year, month: month, day: 1))!
        let day = ((row - 1) * 7 + column + 1) - (firstDay.dayInWeek - 1)
        return ((day > 0) && (day <= firstDay.daysInMonth)) ? day : 0
    }
    
    func equelsTo(date: Date) -> Bool {
        return self.year == date.year && self.monthInYear == date.monthInYear && self.dayInMonth == date.dayInMonth
    }
}

extension String {
    var iso8601: Date? {
        return Formatter.iso8601.date(from: self)
    }
    
    var dateDate: Date? {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        return df.date(from: self)
    }
    
    var timeDate: Date? {
        let df = DateFormatter()
        df.dateFormat = "HH:mm:ss"
        return df.date(from: self)
    }
    
    var longDate: Date? {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return df.date(from: self)
    }
}

extension UIColor {
    static func getColorByRGB (red: Double, green: Double, blue: Double, alpha: Double) -> UIColor {
        return UIColor(red: CGFloat(red/255.0), green: CGFloat(green/255.0), blue: CGFloat(blue/255.0), alpha: CGFloat(alpha/100.0))
    }

    static var calendarBg: UIColor {
        return getColorByRGB(red: 70.0, green: 79.0, blue: 229.0, alpha: 100.0)
    }
    
    static var selectDayTextColor: UIColor {
        return getColorByRGB(red: 48, green: 78, blue: 236, alpha: 100)
    }
    
    static var deselectDayTextColor: UIColor {
        return getColorByRGB(red: 255, green: 255, blue: 255, alpha: 60)
    }
    
    static var scheduleCellColor1: UIColor {
        return getColorByRGB(red: 241, green: 99, blue: 19, alpha: 100)
    }
    
    static var scheduleCellColor2: UIColor {
        return getColorByRGB(red: 13, green: 89, blue: 60, alpha: 100)
    }
    
    static var scheduleCellColor3: UIColor {
        return getColorByRGB(red: 61, green: 131, blue: 249, alpha: 100)
    }
    
    static var scheduleCellColor4: UIColor {
        return getColorByRGB(red: 105, green: 40, blue: 212, alpha: 100)
    }
    
    static var scheduleCellColors: [UIColor] {
        return [scheduleCellColor1, scheduleCellColor2, scheduleCellColor3, scheduleCellColor4]
    }
}
