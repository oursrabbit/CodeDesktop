//
//  ViewController.swift
//  Qin-ios
//
//  Created by 杨璨 on 2020/1/3.
//  Copyright © 2020 canyang. All rights reserved.
//

import UIKit
import RealmSwift

class InitializationViewController: StaticViewController, StaticDataUpdateInfoDelegate {
    
    var waitingDialog = UIAlertController();
    @IBOutlet weak var infoLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        waitingDialog = UIAlertController(title: "", message: "", preferredStyle: .alert)
        self.present(waitingDialog, animated: true)
        initApplication()
    }
    
    func updateInfomation(message: String) {
        updateWaitingDialog(message: message)
    }
    
    func updateWaitingDialog(message: String) {
        DispatchQueue.main.async {
            self.waitingDialog.message = message
        }
    }

    func initApplication() {
        //Init DB
        let config = Realm.Configuration(schemaVersion: 0, deleteRealmIfMigrationNeeded: true)
        Realm.Configuration.defaultConfiguration = config
        DatabaseHelper.realm = try! Realm()
        //Init LocalDB
        let localStore = UserDefaults.standard
        if let sid = localStore.string(forKey: "StudentID") {
            StaticData.CurrentUser.StudentID = sid
        } else {
            StaticData.CurrentUser.StudentID = ""
        }
        DispatchQueue.global().async {
            if (StaticData.checkPermission(listener: self) == false) {
                //openSystemSetting();
                return;
            }
        }
    }
}

