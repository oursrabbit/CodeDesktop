//
//  IBeaconReceiverViewController.swift
//  HttpTest
//
//  Created by 杨璨 on 2019/11/29.
//  Copyright © 2019 canyang. All rights reserved.
//

import UIKit
import CoreLocation
import CoreBluetooth

class IBeaconReceiverViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var infoTextView: UITextView!
    var uuidss = 0;
    
    let majors = ["A楼", "B楼", "C楼", "D楼"]
    
    let minors = [["601", "602", "603", "614"], //A楼
                  ["601", "602", "603", "614"], //B楼
                  ["601", "602", "603", "614"], //C楼
                  ["601", "602", "603", "614"]] //D楼
    
    let locationManager = CLLocationManager()
    //var region = CLBeaconRegion()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        monitorBeacons()
        //_ = Timer.scheduledTimer(timeInterval: 30, target: self, selector: Selector(("monitorBeacons")), userInfo: nil, repeats: true)
    }
    
    @IBAction func testInRegion(_ sender: Any) {
        for item in self.locationManager.monitoredRegions
        {
            if let bregion = item as? CLBeaconRegion {
                print(bregion.uuid)
                self.locationManager.startRangingBeacons(satisfying: CLBeaconIdentityConstraint(uuid: bregion.uuid))
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didRange beacons: [CLBeacon], satisfying beaconConstraint: CLBeaconIdentityConstraint) {
        for item in beacons {
            print(item.major)
            print(item.minor)
            print(item.uuid)
            print(Date())
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
        
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        print("enter")
        if let bregion = region as? CLBeaconRegion {
            print(bregion.uuid)
            print(bregion.identifier)
            print(bregion.major?.uint16Value)
            print(bregion.minor)
            DispatchQueue.main.async {
                self.infoTextView.text += "enter: \(bregion.uuid)"
            }
        } else {
            print(region.identifier)
        }
        //self.locationManager.startMonitoring(for: region)
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        print("exit")
        if let bregion = region as? CLBeaconRegion {
            print(bregion.uuid)
            print(bregion.identifier)
            print(bregion.minor?.uint16Value)
            print(bregion.minor)
            DispatchQueue.main.async {
                self.infoTextView.text += "exit: \(bregion.uuid)"
            }
        } else {
            print(region.identifier)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error: \(error)")
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    @objc func monitorBeacons() {
        if CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self) {
            //self.locationManager.stopMonitoring(for: region)
            
            // Match all beacons with the specified UUID
            let newuuidss = String(format: "%.12d", uuidss)
            let proximityUUID = UUID(uuidString: "FDA50693-A4E2-4FB1-AFCF-C6EB07647825")
            //uuidss += 1
            let beaconID = ""//com.example.myBeaconRegion"
            // Create the region and begin monitoring it.
            let region = CLBeaconRegion(uuid: proximityUUID!, identifier: beaconID)
            
            print("\(region.uuid)")
            self.locationManager.startMonitoring(for: region)
        }
    }
}
