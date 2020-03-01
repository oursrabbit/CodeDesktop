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
    public static var CheckInRoomID = "";
    
    public static let localVersion = 7
    public static var serverVersion = 0
    public static var databaseVersion = 0
    public static var launchImageVersion = 0
    
    public static func checkVersion(listener: StaticDataUpdateInfoDelegate?) -> QinMessage {
        listener?.updateInfomation(message: "正在检测软件版本...")
        let url = DatabaseHelper.LeancloudAPIBaseURL + "/1.1/classes/ApplicationData/5e59e2ec21b47e0081de8189";
        if let json = DatabaseHelper.LCSearch(searchURL: url){
            ApplicationHelper.serverVersion = json["ApplicationVersion"] as! Int
            ApplicationHelper.databaseVersion = json["DatabaseVersion"] as! Int
            ApplicationHelper.launchImageVersion = json["LaunchImageVersion"] as! Int
            if ApplicationHelper.localVersion == ApplicationHelper.serverVersion {
                return .Success
            } else {
                UserDefaults.standard.set(-1, forKey: "localDataVersion")
                UserDefaults.standard.set(-1, forKey: "launchImageVersion")
                return .ApplicationVersionError
            }
        } else {
            return .NetError
        }
    }
    
    public static func checkLocalDatabaseVersion(listener: StaticDataUpdateInfoDelegate?) -> QinMessage {
        listener?.updateInfomation(message: "正在更新本地数据库...")
        var localDataVersion = -1
        let localStore = UserDefaults.standard
        if let _ = localStore.object(forKey: "localDataVersion") {
            localDataVersion = localStore.integer(forKey: "localDataVersion")
        }
        if localDataVersion == ApplicationHelper.databaseVersion {
            return .Success
        } else {
            autoreleasepool {
                let realm = try! Realm()
                realm.beginWrite()
                realm.deleteAll()
                try! realm.commitWrite()
            }
            
            //*** MUST BE IN ORDER ***
            ReBuildingRoom.CreateBuildingRoom(refresh: true)
            Section.GetAll(refresh: true)
            Course.GetAll(refresh: true)
            Professor.GetAll(refresh: true)
            UserDefaults.standard.set(ApplicationHelper.databaseVersion, forKey: "localDataVersion")
        }
        return .DatabaseUpdated
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
        
    /*
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
    }*/
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
    
    static func convert(date: Date, By format: String) -> String {
        let df = DateFormatter()
        df.dateFormat = format
        return df.string(from: date)
    }
    
    static func convert(string: String, By format: String) -> Date {
        let df = DateFormatter()
        df.dateFormat = format
        return df.date(from: string) ?? Date()
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
    
    static func addDays(days: Int, to: Date) -> Date {
        return Calendar.current.date(byAdding: .day, value: days, to: to)!
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
    
    var sectionTimeDate: Date? {
        let df = DateFormatter()
        df.dateFormat = "HH:mm"
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
