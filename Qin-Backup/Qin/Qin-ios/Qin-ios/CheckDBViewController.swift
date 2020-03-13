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
    var leanlogs = [CheckLog]()
    
    @IBOutlet weak var idlabel: UILabel!
    @IBOutlet weak var logstableview: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        //self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true;
        
        idlabel.text = "正在加载数据..."
        DispatchQueue.global().async {
            self.LoadingDatabase()
        }
    }
    
    func LoadingDatabase() {
        self.leanlogs = CheckLog.GetAll()
        self.logs = self.leanlogs
        DispatchQueue.main.async {
            self.logs.sort(by: {$0.CheckDate > $1.CheckDate})
            self.idlabel.text = "\(ApplicationHelper.CurrentUser.Name)·签到记录"
            self.logstableview.reloadData()
        }
    }
    
    func LoadingLocalDatabase(keyword: String) {
        self.logs =  self.leanlogs.filter{ (item) -> Bool in
            let room = (try! Realm()).objects(Room.self).first(where: {$0.ID == item.RoomID})!
            let building = room.Location!
            let checkDate = item.CheckDate.longString
            return room.Name.contains(keyword) || building.Name.contains(keyword) || checkDate.contains(keyword)
        }
        self.logs.sort(by: {$0.CheckDate > $1.CheckDate})
        self.idlabel.text = "\(ApplicationHelper.CurrentUser.Name)·签到记录"
        self.logstableview.reloadData()
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
        let room = (try! Realm()).objects(Room.self).first(where: {$0.ID == logs[indexPath.row].RoomID})!
        let cell = tableView.dequeueReusableCell(withIdentifier: "checkdb") as! CheckDBTableViewCell
        cell.initCellInterface()
        cell.roomidlabel.text = "\(room.Location!.Name) \(room.Name)"
        cell.checkdatelabel.text = "\(logs[indexPath.row].CheckDate.longString)"
        let timespan = -logs[indexPath.row].CheckDate.timeIntervalSinceNow
        let ti = Int(timespan)
        let sec = ti % 60
        let min = (ti / 60) % 60
        let hours = (ti / 3600)
        let days = (hours / 24)
        let months = (days / 30)
        let years = (months / 12)
        if years != 0 {
            cell.checktimelabel.text = "\(years) 年前"
        } else if months != 0 {
            cell.checktimelabel.text = "\(months) 个月前"
        } else if days != 0 {
            cell.checktimelabel.text = "\(days) 天前"
        } else if hours != 0 {
            cell.checktimelabel.text = "\(hours) 小时前"
        } else if min != 0 {
            cell.checktimelabel.text = "\(min) 分钟前"
        } else if sec != 0 {
            cell.checktimelabel.text = "\(sec) 秒前"
        } else {
            cell.checktimelabel.text = "刚刚"
        }
        if let image = UIImage(named: "\(room.Location!.ID)") {
            cell.buildingImage.image = image
        } else {
            cell.buildingImage.image = UIImage(named: "0")
        }
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
}

extension CheckDBViewController: UITableViewDelegate {
    
}

extension CheckDBViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        if let keyword = searchBar.text {
            idlabel.text = "正在加载数据..."
            self.LoadingLocalDatabase(keyword: keyword)
        } else {
            idlabel.text = "正在加载数据..."
            DispatchQueue.global().async {
                self.LoadingDatabase()
            }
        }
    }
}
