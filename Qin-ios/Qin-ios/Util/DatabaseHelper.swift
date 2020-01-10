//
//  DatabaseHelper.swift
//  Qin-ios
//
//  Created by 杨璨 on 2020/1/6.
//  Copyright © 2020 canyang. All rights reserved.
//

import Foundation
import RealmSwift

public class DatabaseHelper {
    //Lean Cloud
    public static var LeancloudAppid = "N4v46EIBIAWtiOANE61Fe1no-gzGzoHsz";
    public static var LeancloudAppKey = "RCzPdQyEuPLaFhcPlxaKVb9P";
    public static var LeancloudAPIBaseURL = "https://n4v46eib.lc-cn-n1-shared.com";
    public static var LeancloudIDHeader = "X-LC-Id";
    public static var LeancloudKeyHeader = "X-LC-Key";
    public static var HttpContentTypeHeader = "Content-Type";
    public static var HttpContentTypeJSONUTF8 = "application/json; charset=utf-8";
    
    public static func LCSearch(searchURL: String, completionHandler: @escaping ([String:Any], Error?) -> Void) {
        let createCheckItemURL = URL(string: searchURL)
        let leancloudSession = URLSession.shared;
        var leancloudRequest = URLRequest(url: createCheckItemURL!);
        leancloudRequest.httpMethod = "GET"
        leancloudRequest.setValue(HttpContentTypeJSONUTF8, forHTTPHeaderField: HttpContentTypeHeader)
        leancloudRequest.setValue(LeancloudAppid, forHTTPHeaderField: LeancloudIDHeader)
        leancloudRequest.setValue(LeancloudAppKey, forHTTPHeaderField: LeancloudKeyHeader)
        leancloudSession.dataTask(with: leancloudRequest) { data, response, error in
            // Do something...
            do{
                if error != nil {
                    completionHandler([String:Any](), error)
                } else {
                    let json = try JSONSerialization.jsonObject(with: data!, options: []) as! [String:Any]
                    completionHandler(json, nil)
                }
            }catch{
                completionHandler([String:Any](), error)
            }
        }.resume()
    }
    
    public static func LCUpdateAdvertising(completionHandler: @escaping (Bool) -> Void){
        let url = DatabaseHelper.LeancloudAPIBaseURL + "/1.1/classes/Student/" + ApplicationHelper.CurrentUser.LCObjectID
        let createCheckItemURL = URL(string: url)
        let leancloudSession = URLSession.shared;
        var leancloudRequest = URLRequest(url: createCheckItemURL!);
        leancloudRequest.httpMethod = "PUT"
        leancloudRequest.setValue(HttpContentTypeJSONUTF8, forHTTPHeaderField: HttpContentTypeHeader)
        leancloudRequest.setValue(LeancloudAppid, forHTTPHeaderField: LeancloudIDHeader)
        leancloudRequest.setValue(LeancloudAppKey, forHTTPHeaderField: LeancloudKeyHeader)
        let checkJson = ["Advertising": "1"]
        let checkJSONData = try? JSONSerialization.data(withJSONObject: checkJson, options: [])
        leancloudSession.uploadTask(with: leancloudRequest, from: checkJSONData) { data, response, error in
            if let httpres = response as? HTTPURLResponse {
                completionHandler(httpres.statusCode == 200)
            } else {
                completionHandler(false)
            }
        }.resume()
    }

    public static func LCCheckAdvertising(value:String, completionHandler: @escaping (Bool) -> Void) {
        let url = DatabaseHelper.LeancloudAPIBaseURL + "/1.1/classes/Student/" + ApplicationHelper.CurrentUser.LCObjectID;
        DatabaseHelper.LCSearch(searchURL: url){ json, error in
            if let advertiding = json["Advertising"] as? String , error == nil {
                //print("id: \(ApplicationHelper.CurrentUser.SchoolID) adv: \(advertiding)  value: \(value)")
                completionHandler(advertiding == value)
            } else {
                print("false")
                completionHandler(false)
            }
        }
    }

    public static func LCUploadCheckLog(completionHandler: @escaping (Bool) -> Void) {
        var checkInRoom = Room()
        autoreleasepool {
            checkInRoom =  (try! Realm()).objects(Room.self).filter("ID = \(ApplicationHelper.CheckInRoomID)").first!
        }
        let url = DatabaseHelper.LeancloudAPIBaseURL + "/1.1/classes/CheckRecording"
        let createCheckItemURL = URL(string: url)
        let leancloudSession = URLSession.shared;
        var leancloudRequest = URLRequest(url: createCheckItemURL!);
        leancloudRequest.httpMethod = "POST"
        leancloudRequest.setValue(HttpContentTypeJSONUTF8, forHTTPHeaderField: HttpContentTypeHeader)
        leancloudRequest.setValue(LeancloudAppid, forHTTPHeaderField: LeancloudIDHeader)
        leancloudRequest.setValue(LeancloudAppKey, forHTTPHeaderField: LeancloudKeyHeader)
        let checkJson = ["StudentID"    : ApplicationHelper.CurrentUser.ID,
                         "RoomID"       : checkInRoom.ID]
        let checkJSONData = try? JSONSerialization.data(withJSONObject: checkJson, options: [])
        leancloudSession.uploadTask(with: leancloudRequest, from: checkJSONData) { data, response, error in
            if let httpres = response as? HTTPURLResponse {
                completionHandler(httpres.statusCode == 201)
            } else {
                completionHandler(false)
            }
        }.resume()
    }

}
