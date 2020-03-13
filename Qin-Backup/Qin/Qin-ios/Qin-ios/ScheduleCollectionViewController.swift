//
//  ScheduleCollectionViewController.swift
//  Qin-ios
//
//  Created by 杨璨 on 2020/2/15.
//  Copyright © 2020 canyang. All rights reserved.
//

import UIKit
import RealmSwift

class ScheduleCollectionViewController: UIViewController {

    @IBOutlet weak var ExampleImageView: UIImageView!
    @IBOutlet weak var MaskView: UIView!
    @IBOutlet weak var BackButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let localStore = UserDefaults.standard
        if let _ = localStore.string(forKey: "ShowOrientationAnimation") {
            self.MaskView.isHidden = true
        } else {
            UIView.animate(withDuration: 2, delay: 0, options: [.autoreverse], animations: {
                self.ExampleImageView.transform = CGAffineTransform.identity.rotated(by:CGFloat(-Double.pi/2))
            }, completion: {error in
                self.MaskView.isHidden = true
            })
            UserDefaults.standard.set("", forKey: "ShowOrientationAnimation")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        ApplicationHelper.Orientation = true
        NotificationCenter.default.addObserver(self, selector: #selector(receivedRotation), name: UIDevice.orientationDidChangeNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        ApplicationHelper.Orientation = false
        NotificationCenter.default.removeObserver(self, name: UIDevice.orientationDidChangeNotification, object: nil)
    }
        
    @objc func receivedRotation() {
        if UIDevice.current.orientation == .portrait {
            BackButton.isHidden = false
            self.tabBarController?.tabBar.isHidden = false
        } else if UIDevice.current.orientation == .landscapeLeft || UIDevice.current.orientation == .landscapeRight {
            BackButton.isHidden = true
            self.tabBarController?.tabBar.isHidden = true
        } else {
            
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

extension ScheduleCollectionViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return ApplicationHelper.CurrentUser.Schedules.count;
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "schedulecollectionview", for: indexPath) as! ScheduleCollectionViewCell/*
        let schedule = ApplicationHelper.CurrentUser.Schedules[indexPath.row]
        cell.NameLabel.text = (try! Realm()).objects(Course.self).filter("ID = \(schedule.WorkingCourseID)").first!.Name
        let room = (try! Realm()).objects(Room.self).filter("ID = \(schedule.WorkingRoomID)").first!
        let building = room.LocationOLD.first!
        cell.RoomLabel.text = "\(building.Name)\(room.Name)"
        cell.DateLabel.text = schedule.WorkingDate.dateString
        cell.SectionLabel.text = ""
        cell.TimeLabel.text = ""
        for sectionID in schedule.SectionsID {
            let section = (try! Realm()).objects(Section.self).filter("ID = \(sectionID)").first!
            cell.SectionLabel.text = cell.SectionLabel.text! + "\(section.Name) "
            cell.TimeLabel.text = cell.TimeLabel.text! + "\(section.StartTime.shortTimeString)-\(section.EndTime.shortTimeString) "
        }
        cell.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)*/
        return cell
    }
}

extension ScheduleCollectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var screenWidth = collectionView.bounds.size.width
        if collectionView.bounds.size.width > collectionView.bounds.size.height {
            screenWidth = collectionView.bounds.size.width
        } else {
            screenWidth = collectionView.bounds.size.height
        }
        screenWidth = screenWidth / 7
        return CGSize(width: 215, height: 215)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
    }
}

