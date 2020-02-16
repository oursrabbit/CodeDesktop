//
//  QinSettingViewController.swift
//  Qin-ios
//
//  Created by 杨璨 on 2020/1/6.
//  Copyright © 2020 canyang. All rights reserved.
//

import UIKit
import RealmSwift

class QinSettingViewController: StaticViewController {
    
    @IBOutlet weak var idtextfield: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var waitingView: WaitingView!
    
    public var autoLogin = false

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        idtextfield.text = "\(ApplicationHelper.CurrentUser.SchoolID)"
        
        if autoLogin && ApplicationHelper.CurrentUser.SchoolID != "" {
            updateSchoolID(self)
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    func updateWaitingView(message: String) {
        DispatchQueue.main.async {
            self.waitingView.messageLabel.text = message
        }
    }

    @IBAction func updateSchoolID (_ sender: Any) {
        if let schoolId = idtextfield.text {
            ApplicationHelper.CurrentUser.SchoolID = schoolId
            UserDefaults.standard.set(ApplicationHelper.CurrentUser.SchoolID, forKey: "SchoolID")
            waitingView.isHidden = false
            self.updateWaitingView(message: "正在获取用户信息...")
            DispatchQueue.global().async {
                self.getCurrentUserInfomation()
            }
        }
    }
    
    func getCurrentUserInfomation() {
        let checkJson = ["SchoolID": ApplicationHelper.CurrentUser.SchoolID]
        let checkJSONData = try? JSONSerialization.data(withJSONObject: checkJson, options: [])
        let jsonString = String(data: checkJSONData!, encoding: .utf8)
        let urlString = jsonString!.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        let url = "\(DatabaseHelper.LeancloudAPIBaseURL)/1.1/classes/Student?where=\(urlString)"
        DatabaseHelper.LCSearch(searchURL: url) { response, error in
            if error == nil {
                let DatabaseResults = response["results"] as! [[String:Any?]]
                self.updateWaitingView(message: "正在更新用户信息...")
                if DatabaseResults.count != 1 {
                    DispatchQueue.main.async {
                        self.waitingView.isHidden = true
                        let alert = UIAlertController(title: "登录失败", message: "未找到用户", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "确定", style: .default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                } else {
                    //Student Info
                    let checkLog = DatabaseResults[0]
                    ApplicationHelper.CurrentUser.Advertising = "0"
                    ApplicationHelper.CurrentUser.BaiduFaceID = checkLog["BaiduFaceID"] as! String
                    ApplicationHelper.CurrentUser.LCObjectID = checkLog["objectId"] as! String
                    ApplicationHelper.CurrentUser.ID = checkLog["ID"] as! Int
                    ApplicationHelper.CurrentUser.SchoolID = checkLog["SchoolID"] as! String
                    ApplicationHelper.CurrentUser.Name = checkLog["Name"] as! String
                    //Group Info
                    let checkJson = ["Students": ["$regex":",\(ApplicationHelper.CurrentUser.ID)"]]
                    let checkJSONData = try? JSONSerialization.data(withJSONObject: checkJson, options: [])
                    let jsonString = String(data: checkJSONData!, encoding: .utf8)
                    let urlString = jsonString!.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
                    let url = "\(DatabaseHelper.LeancloudAPIBaseURL)/1.1/classes/Group?where=\(urlString)"
                    DatabaseHelper.LCSearch(searchURL: url) { response, error in
                        if error == nil {
                            ApplicationHelper.CurrentUser.Groups.removeAll()
                            let DatabaseResults = response["results"] as! [[String:Any?]]
                            for checkLog in DatabaseResults {
                                let newGroup = Group()
                                newGroup.ID = checkLog["ID"] as! Int
                                newGroup.Name = checkLog["Name"] as! String
                                ApplicationHelper.CurrentUser.Groups.append(newGroup)
                            }
                            //Schedule Info
                            var checkJSONData: Data? = nil
                            if ApplicationHelper.CurrentUser.Groups.count == 0 {
                                let checkJson = ["StudentsID": ["$regex":",\(ApplicationHelper.CurrentUser.ID)"]]
                                checkJSONData = try? JSONSerialization.data(withJSONObject: checkJson, options: [])
                            } else {
                                let checkJson = ["$or":[["GroupsID": ["$regex":"\(ApplicationHelper.CurrentUser.getGroupsRegex())"]],
                                        ["StudentsID": ["$regex":",\(ApplicationHelper.CurrentUser.ID)"]]]]
                                checkJSONData = try? JSONSerialization.data(withJSONObject: checkJson, options: [])
                            }
                            let jsonString = String(data: checkJSONData!, encoding: .utf8)
                            let urlString = jsonString!.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
                            let url = "\(DatabaseHelper.LeancloudAPIBaseURL)/1.1/classes/Schedule?where=\(urlString)"
                            DatabaseHelper.LCSearch(searchURL: url) { response, error in
                                if error == nil {
                                    ApplicationHelper.CurrentUser.Schedules.removeAll()
                                    let DatabaseResults = response["results"] as! [[String:Any?]]
                                    for checkLog in DatabaseResults {
                                        let newSchedule = Schedule()
                                        newSchedule.ID = checkLog["ID"] as! Int
                                        newSchedule.WorkingDate = (checkLog["WorkingDate"] as! String).dateDate!
                                        newSchedule.WorkingCourseID = checkLog["CourseID"] as! Int
                                        newSchedule.WorkingRoomID = checkLog["RoomID"] as! Int
                                        newSchedule.setSections(sctionIDString: checkLog["SectionID"] as! String)
                                        ApplicationHelper.CurrentUser.Schedules.append(newSchedule)
                                    }
                                    DispatchQueue.main.async {
                                        self.performSegue(withIdentifier: "roomlist", sender: self)
                                    }
                                } else {
                                    self.waitingView.isHidden = true
                                    let alert = UIAlertController(title: "登录失败", message: "网络错误", preferredStyle: .alert)
                                    alert.addAction(UIAlertAction(title: "确定", style: .default, handler: nil))
                                    self.present(alert, animated: true, completion: nil)
                                }
                            }
                        } else {
                            self.waitingView.isHidden = true
                            let alert = UIAlertController(title: "登录失败", message: "网络错误", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "确定", style: .default, handler: nil))
                            self.present(alert, animated: true, completion: nil)
                        }
                    }
                }
            } else {
                self.waitingView.isHidden = true
                let alert = UIAlertController(title: "登录失败", message: "网络错误", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "确定", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
}
