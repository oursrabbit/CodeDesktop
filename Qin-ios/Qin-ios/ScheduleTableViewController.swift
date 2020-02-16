//
//  ScheduleTableViewController.swift
//  Qin-ios
//
//  Created by 杨璨 on 2020/2/15.
//  Copyright © 2020 canyang. All rights reserved.
//

import UIKit
import RealmSwift

class ScheduleTableViewController: StaticViewController {

    @IBOutlet weak var ScheduleTableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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

extension ScheduleTableViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ApplicationHelper.CurrentUser.Schedules.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "schedule") as! ScheduleTableViewCell
        let schedule = ApplicationHelper.CurrentUser.Schedules[indexPath.row]
        cell.NameLabel.text = (try! Realm()).objects(Course.self).filter("ID = \(schedule.WorkingCourseID)").first!.Name
        let room = (try! Realm()).objects(Room.self).filter("ID = \(schedule.WorkingRoomID)").first!
        let building = room.Location.first!
        cell.RoomLabel.text = "\(building.Name)\(room.Name)"
        cell.DateLabel.text = schedule.WorkingDate.dateString
        cell.SectionLabel.text = ""
        cell.TimeLabel.text = ""
        for sectionID in schedule.SectionsID {
            let section = (try! Realm()).objects(Section.self).filter("ID = \(sectionID)").first!
            cell.SectionLabel.text = cell.SectionLabel.text! + "\(section.Name) "
            cell.TimeLabel.text = cell.TimeLabel.text! + "\(section.StartTime.shortTimeString)-\(section.EndTime.shortTimeString) "
        }
        cell.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 215
    }
}

extension ScheduleTableViewController: UITableViewDelegate {
    
}
