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
    
    @IBOutlet weak var infoLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        infoLabel.text = ""
        initApplication()
    }
    
    func updateInfomation(message: String) {
        updateWaitingDialog(message: message)
    }
    
    func updateWaitingDialog(message: String) {
        DispatchQueue.main.async {
            self.infoLabel.text = message
        }
    }

    func initApplication() {
        //Init DB
        let config = Realm.Configuration(schemaVersion: 0, deleteRealmIfMigrationNeeded: true)
        Realm.Configuration.defaultConfiguration = config
        //Init LocalDB
        let localStore = UserDefaults.standard
        if let sid = localStore.string(forKey: "StudentID") {
            StaticData.CurrentUser.StudentID = sid
        } else {
            StaticData.CurrentUser.StudentID = ""
        }
        DispatchQueue.global().async {
            //Check Version
            StaticData.checkVersion(listener: self) { versionErrorCode in
                switch versionErrorCode {
                case 0:
                    //Check DBVersion
                    StaticData.checkLocalDatabaseVersion(listener: self) { databaseErrorCode in
                        switch databaseErrorCode {
                        //DBVersion Error
                        case 2:
                            self.showNetError()
                            break
                        default:
                            //Start Application
                            self.startQin()
                            break
                        }
                    }
                    break
                //Version Error
                case 1:
                    self.openDownLoadLink()
                    break
                case 2:
                    self.showNetError()
                    break
                default:
                    return
                }
            }
        }
    }
    
    func showNetError() {
        DispatchQueue.main.async {
            self.infoLabel.text = "请重启程序"
            let alert = UIAlertController(title: "启动失败", message: "网络错误", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "确定", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
        }
    }
    
    func openSystemSetting() {
        DispatchQueue.main.async {
            self.infoLabel.text = "请重启程序"
            let alert = UIAlertController(title: "启动失败", message: "未开启硬件权限，请前往应用设置开启", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "前往", style: .default, handler: { _ in
                if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                    if UIApplication.shared.canOpenURL(settingsUrl) {
                        UIApplication.shared.open(settingsUrl, completionHandler: nil)
                    }
                }
            }))
            self.present(alert, animated: true)
        }
    }
    
    func openDownLoadLink() {
        DispatchQueue.main.async {
            self.infoLabel.text = "请重启程序"
            let alert = UIAlertController(title: "启动失败", message: "请更新\n\n本机：\(StaticData.localVersion.VersionString)\n\n最新版：\(StaticData.serverVersion.VersionString)", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "前往", style: .default, handler: { _ in
                let url = URL(string: "https://www.baidu.com")!
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url, completionHandler: nil)
                }
            }))
            self.present(alert, animated: true)
        }
    }
    
    func startQin() {
        DispatchQueue.main.async {
            self.infoLabel.text = "程序启动中..."
            self.performSegue(withIdentifier: "startQin", sender: self)
        }
    }
}

