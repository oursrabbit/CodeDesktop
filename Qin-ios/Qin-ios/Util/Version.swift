//
//  Version.swift
//  Qin-ios
//
//  Created by 杨璨 on 2020/1/6.
//  Copyright © 2020 canyang. All rights reserved.
//

import Foundation

public class Version {
    public var MainVersion = 0
    public var FunctionVersion = 0
    public var BugVersion = 0
    public var DatabaseVersion = 0

    public var VersionString = ""
    
    public init() {
        
    }
    
    public init(versionString: String) {
        MainVersion = Int(versionString.components(separatedBy: ".")[0])!
        FunctionVersion = Int(versionString.components(separatedBy: ".")[1])!
        BugVersion = Int(versionString.components(separatedBy: ".")[2])!
        DatabaseVersion = Int(versionString.components(separatedBy: ".")[3])!
        VersionString = versionString;
    }
}
