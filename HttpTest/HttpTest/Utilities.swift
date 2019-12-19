//
//  Utilities.swift
//  HttpTest
//
//  Created by 杨璨 on 2019/12/4.
//  Copyright © 2019 canyang. All rights reserved.
//

import Foundation
import AVFoundation
import CoreLocation
import UIKit

class Utilities {
    public static func checkPermission() -> Int {
        //Location
        if CLLocationManager.authorizationStatus() != .authorizedWhenInUse {
            return 1
        }
        //Network
        let url = URL(string: "http://www.baidu.com")
        let session = URLSession.shared;
        let semaphore = DispatchSemaphore(value: 0)
        var networkAuthor = false
        session.dataTask(with: url!, completionHandler: { _, _, error in
            if error == nil {
                networkAuthor = false
            } else {
                networkAuthor = true
            }
            semaphore.signal()
        }).resume()
        semaphore.wait()
        if networkAuthor == false {
            return 2
        }
        //Camera
        if AVCaptureDevice.authorizationStatus(for: .video) != .authorized {
            return 3
        }
        return 0
    }
    
    public static func openSystemSetting(controller: UIViewController) {
        let alert = UIAlertController(title: "权限不足", message: "进行签到需要以下权限:\n位置访问权限\n网络访问权限\n摄像头访问权限\n", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "退出程序", style: .default, handler: { _ in
            exit(0)
        }))
        alert.addAction(UIAlertAction(title: "开启权限", style: .default, handler: { _ in
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
        }))
        controller.present(alert, animated: true, completion: { exit(0) })
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
}
extension String {
    var iso8601: Date? {
        return Formatter.iso8601.date(from: self)
    }
}


