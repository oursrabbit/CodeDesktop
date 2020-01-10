//
//  BuildingListViewController.swift
//  Qin-ios
//
//  Created by 杨璨 on 2020/1/8.
//  Copyright © 2020 canyang. All rights reserved.
//

import UIKit
import RealmSwift

class BuildingListViewController: StaticViewController {

    var buildings = [Building]()
    var selectedBuilding: Building!
    
    @IBOutlet weak var buildingList: UITableView!
    @IBOutlet weak var studentNameLabel: UILabel!

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        studentNameLabel.text = "你好，\(ApplicationHelper.CurrentUser.Name)"
        
        autoreleasepool {
            let realm = try! Realm()
            buildings = realm.objects(Building.self).sorted(by: { $0.ID > $1.ID })
        }
    }    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        switch segue.identifier {
        case "roomlist":
            let des = segue.destination as! RoomListViewController
            des.building = selectedBuilding
        default:
            break
        }
    }
}

extension BuildingListViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return buildings.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "building") as! BuildingTableViewCell
        cell.buildingName.text = buildings[indexPath.row].Name
        return cell
    }
}

extension BuildingListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedBuilding = buildings[indexPath.row]
        self.performSegue(withIdentifier: "roomlist", sender: self)
    }
}
