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
import Reachability
import RealmSwift

public protocol StaticDataUpdateInfoDelegate: NSObjectProtocol{
    func updateInfomation(message: String)
}


public class StaticData {
    public static var CurrentUser = Student()
    public static var CheckInRoomID = 0;

    public static let localVersion = Version(versionString: "1.0.0.0");
    public static var serverVersion = Version(versionString: "2.0.0.0");
    
    public static func checkCLLocationPermission(manager: CLLocationManager, completionHandler: @escaping (Bool) -> Void) {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedAlways:
            completionHandler(true)
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .restricted:
            completionHandler(false)
        case .denied:
            completionHandler(false)
        case .authorizedWhenInUse:
            completionHandler(true)
        @unknown default:
            completionHandler(false)
        }
    }
    
    public static func checkVersion(listener: StaticDataUpdateInfoDelegate?, completionHandler: @escaping (Int) -> Void) {
        listener?.updateInfomation(message: "正在检测软件版本...")
        let url = DatabaseHelper.LeancloudAPIBaseURL + "/1.1/classes/QinSetting/5e0c10ae562071008e1fcc28";
        DatabaseHelper.LCSearch(searchURL: url) { json, error in
            if error == nil {
                StaticData.serverVersion = Version(versionString: json["Version"] as! String)
                if StaticData.localVersion.MainVersion != StaticData.serverVersion.MainVersion || StaticData.localVersion.FunctionVersion != StaticData.serverVersion.FunctionVersion || StaticData.localVersion.BugVersion != StaticData.serverVersion.BugVersion {
                    completionHandler(1)
                } else {
                    completionHandler(0)
                }
            } else {
                completionHandler(2)
            }
        }
    }
    
    public static func checkLocalDatabaseVersion(listener: StaticDataUpdateInfoDelegate?, completionHandler: @escaping (Int) -> Void) {
        listener?.updateInfomation(message: "正在检查本地数据库版本...")
        var localDataVersion = 0
        let localStore = UserDefaults.standard
        if let _ = localStore.object(forKey: "localDataVersion") {
            localDataVersion = localStore.integer(forKey: "localDataVersion")
        } else {
            localDataVersion = -1
        }
        if localDataVersion == StaticData.serverVersion.DatabaseVersion {
            completionHandler(0)
        } else {
            listener?.updateInfomation(message: "正在更新本地数据版本...")
            listener?.updateInfomation(message: "正在获取建筑信息...")
            let url = DatabaseHelper.LeancloudAPIBaseURL + "/1.1/classes/Building?limit=1000&&&&"
            DatabaseHelper.LCSearch(searchURL: url) { response, error in
                if error == nil {
                    let DatabaseResults = response["results"] as! [[String:Any?]]
                    listener?.updateInfomation(message: "正在更新建筑信息...")
                    let realm = try! Realm()
                    try! realm.write {
                        for checkLog in DatabaseResults {
                            let newBuilding = Building()
                            newBuilding.BuildingID = checkLog["BuildingID"] as! Int
                            newBuilding.BuildingName = checkLog["BuildingName"] as! String
                            realm.add(newBuilding)
                            print(newBuilding.BuildingName)
                        }
                    }
                    listener?.updateInfomation(message: "正在获取房间信息...")
                    let url = DatabaseHelper.LeancloudAPIBaseURL + "/1.1/classes/Room?limit=1000&&&&"
                    DatabaseHelper.LCSearch(searchURL: url) { roomresponse, roomerror in
                        if roomerror == nil {
                            let DatabaseResults = roomresponse["results"] as! [[String:Any?]]
                            listener?.updateInfomation(message: "正在更新房间信息...")
                            let roomrealm = try! Realm()
                            try! roomrealm.write {
                                for checkLog in DatabaseResults {
                                    let newRoom = Room()
                                    newRoom.RoomID = checkLog["RoomID"] as! Int
                                    newRoom.RoomName = checkLog["RoomName"] as! String
                                    let locationName = checkLog["BuildingName"] as! String
                                    roomrealm.add(newRoom)
                                    roomrealm.objects(Building.self).filter("BuildingName = \(locationName)").first!.Rooms.append(newRoom)
                                    print(newRoom.RoomName)
                                }
                            }
                            UserDefaults.standard.set(StaticData.serverVersion.DatabaseVersion, forKey: "localDataVersion")
                            completionHandler(1)
                        } else {
                            completionHandler(2)
                        }
                    }
                } else {
                    completionHandler(2)
                }
            }
        }
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
    
    var shortString: String {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd hh:mm:ss"
        return df.string(from: self)
    }
    
    var dateString: String {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        return df.string(from: self)
    }
    
    var timeString: String {
        let df = DateFormatter()
        df.dateFormat = "hh:mm:ss"
        return df.string(from: self)
    }
}
extension String {
    var iso8601: Date? {
        return Formatter.iso8601.date(from: self)
    }
}
