//
//  QinSettingViewController.swift
//  Qin-ios
//
//  Created by 杨璨 on 2020/1/6.
//  Copyright © 2020 canyang. All rights reserved.
//

import UIKit

class QinSettingViewController: StaticViewController {
    
    @IBOutlet weak var idtextfield: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var waitingView: WaitingView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        idtextfield.text = StaticData.CurrentUser.StudentID
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

    @IBAction func updateStudentID (_ sender: Any) {
        if let studentid = idtextfield.text {
            StaticData.CurrentUser.StudentID = studentid
            UserDefaults.standard.set(StaticData.CurrentUser.StudentID, forKey: "StudentID")
            waitingView.isHidden = false
            self.updateWaitingView(message: "正在获取用户信息...")
            DispatchQueue.global().async {
                self.updateStudentObjectID()
            }
        }
    }
    
    func updateStudentObjectID() {
        let checkJson = ["StudentID": StaticData.CurrentUser.StudentID]
        let checkJSONData = try? JSONSerialization.data(withJSONObject: checkJson, options: [])
        let jsonString = String(data: checkJSONData!, encoding: .utf8)
        let urlString = jsonString!.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        let url = "\(DatabaseHelper.LeancloudAPIBaseURL)/1.1/classes/Students?where=\(urlString)"
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
                    let checkLog = DatabaseResults[0]
                    StaticData.CurrentUser.Advertising = "0"
                    StaticData.CurrentUser.BaiduFaceID = checkLog["BaiduFaceID"] as! String
                    StaticData.CurrentUser.ObjectID = checkLog["objectId"] as! String
                    StaticData.CurrentUser.StudentBeaconID = checkLog["StudentBeaconMinor"] as! Int
                    DispatchQueue.main.async {
                        self.performSegue(withIdentifier: "roomlist", sender: self)
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
