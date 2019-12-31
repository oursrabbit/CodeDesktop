//
//  ViewController.swift
//  HelloCB
//
//  Created by 杨璨 on 2019/12/31.
//  Copyright © 2019 canyang. All rights reserved.
//

import UIKit
import CoreBluetooth

class ViewController: UIViewController, CBCentralManagerDelegate {
    
    var manager:CBCentralManager?
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            central.scanForPeripherals(withServices: nil, options: nil)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        //print(peripheral.name)
        //print(peripheral.identifier)
        if let data = advertisementData[CBAdvertisementDataManufacturerDataKey] as? NSData {
            print(peripheral.identifier)
            let bytes = [UInt8](data).reduce("") { $0 + " " + String(format: "%02x", $1) }
            print(bytes)
        }
        
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        manager = CBCentralManager(delegate: self, queue: nil, options: nil)
    }


}
