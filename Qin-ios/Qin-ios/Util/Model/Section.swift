//
//  Section.swift
//  Qin-ios
//
//  Created by 杨璨 on 2020/2/14.
//  Copyright © 2020 canyang. All rights reserved.
//

import Foundation
import RealmSwift

public class Section: Object {
    @objc dynamic var ID = 0
    @objc dynamic var StartTime = Date()
    @objc dynamic var EndTime = Date()
    @objc dynamic var Name = ""
    @objc dynamic var Order = 0
}

