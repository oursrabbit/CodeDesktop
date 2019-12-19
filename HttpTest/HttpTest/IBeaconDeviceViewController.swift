//
//  IBeaconDeviceViewController.swift
//  HttpTest
//
//  Created by 杨璨 on 2019/11/29.
//  Copyright © 2019 canyang. All rights reserved.
//

import UIKit
import CoreBluetooth
import CoreLocation

class IBeaconDeviceViewController: UIViewController, CBPeripheralManagerDelegate {

    @IBOutlet weak var infoButton: UIButton!
    var peripheral:CBPeripheralManager? = nil
    var region: CLBeaconRegion? = nil
    var uuidss = 0;
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        peripheral = CBPeripheralManager(delegate: self, queue: nil)
    }
    
    @objc func updateCounting(){
        peripheral?.stopAdvertising()
        let newuuidss = String(format: "%.12d", uuidss)
        let proximityUUID = UUID(uuidString: "39ED98FF-2900-441A-8000-\(newuuidss)")
        uuidss += 1
        DispatchQueue.main.async {
            self.infoButton.setTitle("\(proximityUUID)", for: .normal)
        }
        let major : CLBeaconMajorValue = 0
        let minor : CLBeaconMinorValue = 0
        let beaconID = "com.example.myDeviceRegion"
            
        let region = CLBeaconRegion(uuid: proximityUUID!, major: major, minor: minor, identifier: beaconID)
        let peripheralData = region.peripheralData(withMeasuredPower: nil)
        
        peripheral?.startAdvertising(((peripheralData as NSDictionary) as! [String : Any]))
    }
    
    @IBAction func Emmit(_ sender: Any?) {
        print(Date())
        //region = createBeaconRegion()!
        //advertiseDevice()
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    func createBeaconRegion() -> CLBeaconRegion? {
        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "ss"
        let ss = dateFormatterPrint.string(from: Date())
        let proximityUUID = UUID(uuidString: "39ED98FF-2900-441A-80\(ss)-9C398FC199D2")
        let major : CLBeaconMajorValue = UInt16.random(in: 0..<4)
        let minor : CLBeaconMinorValue = UInt16.random(in: 0..<4)
        let beaconID = "com.example.myDeviceRegion"
            
        return CLBeaconRegion(uuid: proximityUUID!, major: major, minor: minor, identifier: beaconID)
    }
    
    func advertiseDevice() {
        peripheral = CBPeripheralManager(delegate: self, queue: nil)
        
    }
    
    func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: Error?) {
        DispatchQueue.main.async {
            self.infoButton.setTitle(self.infoButton.title(for: .normal)! + " \(error)", for: .normal)
        }
        print("error: \(error)")
    }
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        updateCounting()
        //_ = Timer.scheduledTimer(timeInterval: 30, target: self, selector: Selector(("updateCounting")), userInfo: nil, repeats: true)
    }
}
