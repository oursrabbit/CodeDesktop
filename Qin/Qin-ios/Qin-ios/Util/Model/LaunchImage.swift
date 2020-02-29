//
//  ApplicationData.swift
//  Qin-ios
//
//  Created by 杨璨 on 2020/2/18.
//  Copyright © 2020 canyang. All rights reserved.
//

import Foundation
import RealmSwift

public class LaunchImage: Object {
    @objc dynamic var LaunchImage: Data?
    @objc dynamic var LaunchImageBackground: Data?
}
