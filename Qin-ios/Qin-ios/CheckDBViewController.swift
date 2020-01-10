//
//  CheckDBViewController.swift
//  Qin-ios
//
//  Created by 杨璨 on 2020/1/6.
//  Copyright © 2020 canyang. All rights reserved.
//

import UIKit
import RealmSwift

class CheckDBViewController: StaticViewController {

    var logs = [CheckLog]()
    
    @IBOutlet weak var idlabel: UILabel!
    @IBOutlet weak var logstableview: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true;
        
        idlabel.text = "正在加载数据..."
        DispatchQueue.global().async {
            self.LoadingDatabase()
        }
    }
    
    func LoadingDatabase() {
        let checkJson = ["StudentID": ApplicationHelper.CurrentUser.ID]
        let checkJSONData = try? JSONSerialization.data(withJSONObject: checkJson, options: [])
        let jsonString = String(data: checkJSONData!, encoding: .utf8)
        let urlString = jsonString!.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        let url = "\(DatabaseHelper.LeancloudAPIBaseURL)/1.1/classes/CheckRecording?where=\(urlString)"
        DatabaseHelper.LCSearch(searchURL: url) { response, error in
            if error == nil {
                let DatabaseResults = response["results"] as! [[String:Any?]]
                self.logs.removeAll()
                for checkLog in DatabaseResults {
                    let newLog = CheckLog()
                    newLog.StudentID = checkLog["StudentID"] as! Int
                    newLog.RoomID = checkLog["RoomID"] as! Int
                    newLog.CheckDate = (checkLog["createdAt"] as! String).iso8601!
                    self.logs.append(newLog)
                }
                DispatchQueue.main.async {
                    self.idlabel.text = ApplicationHelper.CurrentUser.Name
                    self.logstableview.reloadData()
                }
            } else {
                DispatchQueue.main.async {
                    self.idlabel.text = "网络错误，加载失败";
                }
            }
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
    
    @IBAction func backBuildingListView(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}

extension CheckDBViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return logs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let room = (try! Realm()).objects(Room.self).filter("ID = \(logs[indexPath.row].RoomID)").first!
        let cell = tableView.dequeueReusableCell(withIdentifier: "checkdb") as! CheckDBTableViewCell
        cell.roomidlabel.text = room.Name
        cell.checkdatelabel.text = logs[indexPath.row].CheckDate.dateString
        cell.checktimelabel.text = logs[indexPath.row].CheckDate.timeString
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
}

extension CheckDBViewController: UITableViewDelegate {
    
}
