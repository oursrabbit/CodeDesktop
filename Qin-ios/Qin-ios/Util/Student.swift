//
//  Student.swift
//  Qin-ios
//
//  Created by 杨璨 on 2020/1/6.
//  Copyright © 2020 canyang. All rights reserved.
//

import Foundation

public class Student {
    public var LCObjectID: String = ""
    public var SchoolID: String = ""
    public var Advertising: String = ""
    public var BaiduFaceID: String = ""
    public var ID: Int = 0
    public var Name: String = ""
    
    public func getStudentBeaconMinor() -> [UInt8] {
        var bytes:[UInt8] = [0x00, 0x00]
        bytes[0] = (UInt8)(ID >> 8 & 0xFF)
        bytes[1] = (UInt8)(ID & 0xFF)
        return bytes
    }
}
