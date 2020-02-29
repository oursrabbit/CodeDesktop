//
//  RoomListViewController.swift
//  Qin-ios
//
//  Created by 杨璨 on 2020/1/6.
//  Copyright © 2020 canyang. All rights reserved.
//

import UIKit
import RealmSwift

class RoomListViewController: StaticViewController {

    var building: Building!
    
    @IBOutlet weak var roomList: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        // self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true;
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

extension RoomListViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        ApplicationHelper.CheckInRoomID = building.Rooms[indexPath.row].ID;
        let alert = UIAlertController(title: "准备签到", message: "是否已经到达房间？\n\n\(building.Name) \(building.Rooms[indexPath.row].Name)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "立刻签到", style: .default, handler: { _ in
            self.performSegue(withIdentifier: "facedetect", sender: self)
        }))
        alert.addAction(UIAlertAction(title: "稍等一下", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)

    }
}

extension RoomListViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return building.Rooms.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "room") as! RoomTableViewCell
        cell.initCellInterface()
        cell.roomName.text = building.Rooms[indexPath.row].Name
        return cell
    }
}
