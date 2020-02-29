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
    @IBOutlet weak var buildingCollection: UICollectionView!
    @IBOutlet weak var studentNameLabel: UILabel!
    @IBOutlet weak var menuView: UIView!

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        if ApplicationHelper.CurrentUser.Groups.count == 0 {
            studentNameLabel.text = "你好，\(ApplicationHelper.CurrentUser.Name)"
        } else {
            studentNameLabel.text = "你好，\(ApplicationHelper.CurrentUser.Groups[0].Name) 的 \(ApplicationHelper.CurrentUser.Name)"
        }
        
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
        self.menuView.isHidden = true
    }
    
    @IBAction func showMenu(_ sender: Any) {
        UIView.animate(withDuration: 1, animations: {
            self.menuView.isHidden = !self.menuView.isHidden
        })
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        self.menuView.isHidden = true
    }
    
}

extension BuildingListViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return buildings.count;
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "building", for: indexPath) as! BuildingCollectionViewCell
        cell.initCellInterface()
        if let image = UIImage(named: "\(buildings[indexPath.row].ID)") {
            cell.buildingImage.image = image
        } else {
            cell.buildingImage.image = UIImage(named: "0")
        }
        cell.buildingNameLabel.text = buildings[indexPath.row].Name
        cell.buildingRoomsLabel.text = "\(buildings[indexPath.row].Rooms.count) 间教室"
        return cell
    }
}

extension BuildingListViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        //let screenWidth = collectionView.bounds.size.width;
        //let cellWidth = (screenWidth - 32) / 2
        return CGSize(width: 147, height: 147)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 32
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 32
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedBuilding = buildings[indexPath.row]
        self.performSegue(withIdentifier: "roomlist", sender: self)
    }
}
