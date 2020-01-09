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
        DatabaseHelper.LCUpdateAdvertising() { success in
            if success {
                self.startAdvertising()
                self.checkingStartTime = Date()
                self.timeout = 30
                while Int(Date().timeIntervalSince(self.checkingStartTime)) < self.timeout {
                    DatabaseHelper.LCCheckAdvertising(value: "0") { couldCheckin in
                        if couldCheckin {
                            self.timeout = 60
                            self.peripheral.stopAdvertising()
                            DatabaseHelper.LCUpdateAdvertising() { checked in
                                if checked {
                                    self.updateInfoLabel(message: "签到成功")
                                    return
                                }
                            }
                        }
                    }
                    sleep(1)
                }
                self.updateInfoLabel(message: "签到失败：超时")
            } else {
                self.updateInfoLabel(message: "签到失败：无法连接数据库")
            }
        }
    }
    
    func startAdvertising() {
        self.peripheral = CBPeripheralManager(delegate: self, queue: nil)
        //self.peripheralData = region.peripheralData(withMeasuredPower: nil)
            
        //peripheral.startAdvertising(((peripheralData as NSDictionary) as! [String : Any]))
    }
}

extension CheckResultViewController: CBPeripheralManagerDelegate {
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        if peripheral.state == .poweredOn {
            
        } else {
            self.updateInfoLabel(message: "签到失败：无法启动蓝牙")
        }
    }
}
