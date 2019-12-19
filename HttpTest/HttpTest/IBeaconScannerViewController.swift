//
//  IBeaconScannerViewController.swift
//  HttpTest
//
//  Created by 杨璨 on 2019/12/1.
//  Copyright © 2019 canyang. All rights reserved.
//

import UIKit
import CoreLocation

class IBeaconScannerViewController: UIViewController, CLLocationManagerDelegate, UITableViewDataSource{
    
    var timer: DispatchSource? = nil;
    @IBOutlet weak var roomListTable: UITableView!
    @IBOutlet weak var countDownLabel: UILabel!
    @IBOutlet weak var checkButton: UIButton!
    
    let locationManager = CLLocationManager()
    var region:CLBeaconRegion? = nil
    var roomList = [String]()
    var iniRoomList = true
    var checkMinor: UInt? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        self.navigationController?.navigationBar.isHidden = true
        
        self.roomListTable.dataSource = self
        self.roomListTable.allowsMultipleSelection = false
        
        locationManager.delegate = self
        let proximityUUID = UUID(uuidString: "FDA50693-A4E2-4FB1-AFCF-C6EB07647825")
        region = CLBeaconRegion(uuid: proximityUUID!, identifier: "bfass")
        locationManager.startMonitoring(for: region!)
        
        iniRoomList = true
        
        countDown(30)
    }
    
    @IBAction func refreshButtonClicked(_ sender: Any)
    {
        iniRoomList = true
    }
    
    @IBAction func checkButtonClicked(_ sender: Any)
    {
        if let indexpath = self.roomListTable.indexPathForSelectedRow{
            self.checkButton.isEnabled = false
            self.checkMinor = UInt(self.roomList[indexpath.row])
        }
    }
    
    func countDown(_ timeOut: Int){
        //倒计时时间
        var timeout = timeOut
        let queue:DispatchQueue = DispatchQueue.global(qos: DispatchQoS.QoSClass.default)
        timer = DispatchSource.makeTimerSource(flags: [], queue: queue) as! DispatchSource
        timer?.schedule(wallDeadline: DispatchWallTime.now(), repeating: .seconds(1))
        //每秒执行
        timer?.setEventHandler(handler: { () -> Void in
            if(timeout<=0){ //倒计时结束，关闭
                self.timer?.cancel();
                DispatchQueue.main.sync(execute: { () -> Void in
                    self.countDownLabel.text = "0"
                    self.iniRoomList = true
                    let alert = UIAlertController(title: "签到失败", message: "签到超时", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "签到失败", style: .default, handler: { _ in
                        self.cleanUp()
                        self.navigationController?.popToRootViewController(animated: true)
                    }))
                    self.present(alert, animated: true)
                })
            }else{//正在倒计时
                DispatchQueue.main.sync(execute: { () -> Void in
                    self.countDownLabel.text = "\(String.init(format: "%.2d", timeout))"
                })
                timeout -= 1;
            }
        })
        timer?.resume()
    }
    
    func cleanUp() {
        self.timer?.cancel()
        self.countDownLabel.text = "0"
        self.locationManager.stopMonitoring(for: self.region!)
        self.locationManager.stopRangingBeacons(satisfying: CLBeaconIdentityConstraint(uuid: region!.uuid))
    }
    
    func updateDB(roomID: String) {
        let createCheckItemURL = URL(string: "https://yhwfdae1.lc-cn-n1-shared.com/1.1/classes/CheckRecording")
        let leancloudSession = URLSession.shared;
        var leancloudRequest = URLRequest(url: createCheckItemURL!);
        leancloudRequest.httpMethod = "POST"
        leancloudRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        leancloudRequest.setValue("YHwFdAE1qj1OcWfJ5xoayLKr-gzGzoHsz", forHTTPHeaderField: "X-LC-Id")
        leancloudRequest.setValue("UbnM6uOP2mxah3nFMzurEDQL", forHTTPHeaderField: "X-LC-Key")
        let checkJson = ["StudentID": StudentID,
                         "RoomID": roomID,
            "CheckDate": ["__type": "Date",
                          "iso": Date().iso8601]] as [String : Any]
        let checkJSONData = try? JSONSerialization.data(withJSONObject: checkJson, options: [])
        let uploadDatatask = leancloudSession.uploadTask(with: leancloudRequest, from: checkJSONData) { data, response, error in
            // Do something...
            do{
                DispatchQueue.main.async {
                    self.checkButton.isEnabled = true
                }
                let json = try JSONSerialization.jsonObject(with: data!, options: []) as! [String:Any]
                if let _ = json["objectId"] as? String {
                    DispatchQueue.main.async(execute: { () -> Void in
                        self.cleanUp()
                        let alert = UIAlertController(title: "签到成功", message: "", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "再次签到", style: .default, handler: { _ in
                            self.navigationController?.popToRootViewController(animated: true)
                        }))
                        self.present(alert, animated: true)
                    })
                }
            }catch{
                print("JSON error: \(error.localizedDescription)")
            }
        }
        uploadDatatask.resume()
    }
}

//iBeacon
extension IBeaconScannerViewController{
    
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        if region == self.region {
            locationManager.startRangingBeacons(satisfying: CLBeaconIdentityConstraint(uuid: self.region!.uuid))
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didRange beacons: [CLBeacon], satisfying beaconConstraint: CLBeaconIdentityConstraint) {
        
        if iniRoomList {
            self.roomList = [String]()
            for item in beacons {
                self.roomList.append("\(item.minor)")
            }
            //self.roomList.append("708")
            self.roomList.sort()
            DispatchQueue.main.async {
                self.roomListTable.reloadData()
            }
            iniRoomList = false
        }
        
        if let minor = self.checkMinor {
            self.checkMinor = nil
            for item in beacons {
                if item.minor.uintValue == minor{
                    DispatchQueue.main.async {
                        self.updateDB(roomID: String(minor))
                    }
                    return
                }
            }
            DispatchQueue.main.async {
                self.checkButton.isEnabled = true
                let alert = UIAlertController(title: "签到失败", message: "未检测到教室区域", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "返回", style: .default, handler: nil))
                self.present(alert, animated: true)
                self.iniRoomList = true
            }
        }
    }
}

//TableView
extension IBeaconScannerViewController{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.roomList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        cell.textLabel?.text = self.roomList[indexPath.row]
        return cell
    }
}
