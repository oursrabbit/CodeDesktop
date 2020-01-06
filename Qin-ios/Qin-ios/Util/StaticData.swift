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

public protocol StaticDataUpdateInfoDelegate: NSObjectProtocol{
    func updateInfomation(message: String)
}


public class StaticData {
    public static var CurrentUser = Student()
    public static var CheckInRoomID = 0;

    public static var localVersion = Version(versionString: "1.0.0.0");
    public static var serverVersion = Version();
    
    public static func checkPermission(listener: StaticDataUpdateInfoDelegate?) -> Bool {
        listener?.updateInfomation(message: "正在检查系统权限...");
        var internetPermission = true
        let reachability = try! Reachability()
        reachability.whenUnreachable = { _ in
            internetPermission = false
        }
        if CLLocationManager.authorizationStatus() == . {
            isOpen = true
        }
        let manager = CLLocationManager()
        CLLocationManager().requestWhenInUseAuthorization()
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
