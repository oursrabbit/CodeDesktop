//
//  Student.swift
//  Qin-ios
//
//  Created by 杨璨 on 2020/1/6.
//  Copyright © 2020 canyang. All rights reserved.
//

import Foundation

public class Student {
    public var ObjectID: String = ""
    public var StudentID: String = ""
    public var Advertising: String = ""
    public var BaiduFaceID: String = ""
    public var StudentBeaconID: Int = 0
    
    public func getStudentBeaconMinor() -> [UInt8] {
        var bytes:[UInt8] = [0x00, 0x00]
        bytes[0] = (UInt8)(StudentBeaconID >> 8 & 0xFF)
        bytes[1] = (UInt8)(StudentBeaconID & 0xFF)
        return bytes
    }
}
