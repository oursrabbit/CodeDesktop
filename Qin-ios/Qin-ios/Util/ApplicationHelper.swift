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
    
    public static let localVersion = 3
    public static var serverVersion = 0
    public static var databaseVersion = 0
    
    public static func checkVersion(listener: StaticDataUpdateInfoDelegate?, completionHandler: @escaping (QinMessage) -> Void) {
        listener?.updateInfomation(message: "正在检测软件版本...")
        let url = DatabaseHelper.LeancloudAPIBaseURL + "/1.1/classes/ApplicationData/5e184373562071008e2f4a0a";
        DatabaseHelper.LCSearch(searchURL: url) { json, error in
            if error == nil {
                ApplicationHelper.serverVersion = json["ApplicationVersion"] as! Int
                ApplicationHelper.databaseVersion = json["DatabaseVersion"] as! Int
                if ApplicationHelper.localVersion >= ApplicationHelper.serverVersion {
                    completionHandler(.Success)
                } else {
                    UserDefaults.standard.set(-1, forKey: "localDataVersion")
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
        if localDataVersion >= ApplicationHelper.databaseVersion {
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
