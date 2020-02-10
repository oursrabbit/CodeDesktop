//
//  DatabaseHelper.swift
//  Qin-ios
//
//  Created by 杨璨 on 2020/1/6.
//  Copyright © 2020 canyang. All rights reserved.
//

import Foundation

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
        let checkJson = ["Advertising": "0"]
        let checkJSONData = try? JSONSerialization.data(withJSONObject: checkJson, options: [])
        leancloudSession.uploadTask(with: leancloudRequest, from: checkJSONData) { data, response, error in
            if let httpres = response as? HTTPURLResponse {
                completionHandler(httpres.statusCode == 200)
            } else {
                completionHandler(false)
            }
        }.resume()
    }
    
    public static func getCurrentUserInfomation(completionHandler: @escaping (Bool) -> Void){
        let checkJson = ["SchoolID": ApplicationHelper.CurrentUser.SchoolID]
        let checkJSONData = try? JSONSerialization.data(withJSONObject: checkJson, options: [])
        let jsonString = String(data: checkJSONData!, encoding: .utf8)
        let urlString = jsonString!.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        let url = "\(DatabaseHelper.LeancloudAPIBaseURL)/1.1/classes/Student?where=\(urlString)"
        DatabaseHelper.LCSearch(searchURL: url) { response, error in
            if error == nil {
                let DatabaseResults = response["results"] as! [[String:Any?]]
                let checkLog = DatabaseResults[0]
                ApplicationHelper.CurrentUser.Advertising = "0"
                ApplicationHelper.CurrentUser.BaiduFaceID = checkLog["BaiduFaceID"] as! String
                ApplicationHelper.CurrentUser.LCObjectID = checkLog["objectId"] as! String
                ApplicationHelper.CurrentUser.ID = checkLog["ID"] as! Int
                ApplicationHelper.CurrentUser.SchoolID = checkLog["SchoolID"] as! String
                ApplicationHelper.CurrentUser.Name = checkLog["Name"] as! String
                completionHandler(true)
            } else {
                completionHandler(false)
            }
        }
    }
}
