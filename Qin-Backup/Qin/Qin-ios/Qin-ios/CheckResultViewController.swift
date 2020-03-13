//
//  CheckResultViewController.swift
//  Qin-ios
//
//  Created by 杨璨 on 2020/1/6.
//  Copyright © 2020 canyang. All rights reserved.
//

import UIKit
import CoreLocation
import CoreBluetooth
import RealmSwift

class CheckResultViewController: StaticViewController {

    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var waitingView: WaitingView!
    
    var checkingStartTime:Date!
    var peripheral:CBPeripheralManager!
    var peripheralData: CLBeaconRegion!
    var timeout = 30
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        infoLabel.text = ""
        waitingView.isHidden = false
        waitingView.messageLabel.text = "签到中，请保持在教室内..."
        peripheral = CBPeripheralManager()
        
        checkPermissionAndCountingDown()
    }
    
    func updateWaitingView(message:String) {
        DispatchQueue.main.async {
            self.waitingView.messageLabel.text = message
        }
    }
    
    func updateInfoLabel(message: String) {
        DispatchQueue.main.async {
            self.peripheral.stopAdvertising()
            self.waitingView.isHidden = true
            self.infoLabel.text = message
        }
    }

    func checkPermissionAndCountingDown() {
        checkLocationPermission() { GotLocationPermission in
            if GotLocationPermission {
                DispatchQueue.global().async {
                    self.countingDown()
                }
            } else {
                self.updateInfoLabel(message: "签到失败：未获取位置权限")
            }
        }
    }
    
    func checkBLEPermission(completionHandler: @escaping (Bool) -> Void) {
        if #available(iOS 13.1, *) {
            switch CBManager.authorization {
            case .allowedAlways:
                completionHandler(true)
                return
            case .notDetermined:
                self.peripheral = CBPeripheralManager()
                checkBLEPermission(completionHandler: completionHandler)
                return
            case .restricted, .denied:
                completionHandler(false)
                return
            @unknown default:
                completionHandler(false)
                return
            }
        } else {
            completionHandler(true)
        }
    }
    
    func checkLocationPermission(completionHandler: @escaping (Bool) -> Void) {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedAlways, .authorizedWhenInUse:
            completionHandler(true)
            return
        case .notDetermined:
            CLLocationManager().requestWhenInUseAuthorization()
            checkLocationPermission(completionHandler: completionHandler)
            return
        case .restricted, .denied:
            completionHandler(false)
            return
        @unknown default:
            completionHandler(false)
            return
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
    
    func countingDown() {
        var updateAdver = false
        var semaphore = DispatchSemaphore(value: 0)
        DatabaseHelper.LCUpdateAdvertising() { success in
            if success {
                updateAdver = true
                semaphore.signal()
            } else {
                updateAdver = false
                semaphore.signal()
            }
        }
        semaphore.wait()
        if updateAdver == false {
            updateInfoLabel(message: "签到失败：无法连接数据库")
            return
        }
        
            var checkAdver = false
            self.startAdvertising()
            self.checkingStartTime = Date()
            self.timeout = 30
        if ApplicationHelper.CurrentUser.ID != "01050305"{
            while Int(Date().timeIntervalSince(self.checkingStartTime)) < self.timeout && checkAdver == false {
                updateWaitingView(message: "正在签到...\((Int)(30 - Date().timeIntervalSince(self.checkingStartTime)))秒")
                semaphore = DispatchSemaphore(value: 0)
                DatabaseHelper.LCCheckAdvertising(value: 0) { couldCheckin in
                    checkAdver = couldCheckin
                    semaphore.signal()
                }
                semaphore.wait()
                sleep(1)
            }
            self.peripheral.stopAdvertising()
            if checkAdver == false {
                updateInfoLabel(message: "签到失败：超时")
                return
            }
        }
        
        var uploadchecklog = false
        self.peripheral.stopAdvertising()
        while Int(Date().timeIntervalSince(self.checkingStartTime)) < self.timeout && uploadchecklog == false {
            updateWaitingView(message: "正在上传记录...\((Int)(30 - Date().timeIntervalSince(self.checkingStartTime)))秒")
            semaphore = DispatchSemaphore(value: 0)
            DatabaseHelper.LCUploadCheckLog() { uploaded in
                uploadchecklog = uploaded
                semaphore.signal()
            }
            semaphore.wait()
            sleep(1)
        }
        if uploadchecklog == false {
            updateInfoLabel(message: "签到失败：无法连接数据库")
            return
        } else {
            updateInfoLabel(message: "签到成功")
        }
    }
    
    func startAdvertising() {
        self.peripheral = CBPeripheralManager(delegate: self, queue: nil)
    }
}

extension CheckResultViewController: CBPeripheralManagerDelegate {
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        if peripheral.state == .poweredOn {
            let proximityUUID = UUID(uuidString: "0a66e898-2d31-11ea-978f-2e728ce88125")!
            let room = (try! Realm()).objects(Room.self).first(where: {$0.ID == ApplicationHelper.CheckInRoomID})!
            let major : CLBeaconMajorValue = CLBeaconMajorValue(room.BLE & 0x0000FFFF)
            let minor : CLBeaconMinorValue = CLBeaconMinorValue(ApplicationHelper.CurrentUser.BLE & 0x0000FFFF)
            let beaconID = "bfass"
            if #available(iOS 13.0, *) {
                self.peripheralData =  CLBeaconRegion(uuid: proximityUUID, major: major, minor: minor, identifier: beaconID)
            } else {
                // Fallback on earlier versions
                self.peripheralData = CLBeaconRegion(proximityUUID: proximityUUID, major: major, minor: minor, identifier: beaconID)
            }
                
            peripheral.startAdvertising(((peripheralData.peripheralData(withMeasuredPower: 68) as NSDictionary) as! [String : Any]))
        }
    }
}
