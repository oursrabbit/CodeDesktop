import UIKit
import Flutter
import AVFoundation
import CoreBluetooth
import CoreLocation

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
        let cameraChannel = FlutterMethodChannel(name: "edu.bfa.sa.ios/camera",
                                                 binaryMessenger: controller.binaryMessenger)
        cameraChannel.setMethodCallHandler({
            [weak self] (call: FlutterMethodCall, result: FlutterResult) -> Void in
            // Note: this method is invoked on the UI thread.
            if(call.method == "checkCameraPermission"){
                CrossCamera.checkCameraPermission(result: result)
                return
            } else {
                result(FlutterMethodNotImplemented)
                return
            }
        })
        let bleChannel = FlutterMethodChannel(name: "edu.bfa.sa.ios/ble",
                                                 binaryMessenger: controller.binaryMessenger)
        bleChannel.setMethodCallHandler({
            [weak self] (call: FlutterMethodCall, result: FlutterResult) -> Void in
            // Note: this method is invoked on the UI thread.
            if(call.method == "checkBLEPermission"){
                CrossBLE.checkBLEPermission(result: result)
                return
            } else if(call.method == "startAdvertising"){
                if let args = call.arguments as? [String : Int] {
                    CrossBLE.studentBLE = args["studentble"]!
                    CrossBLE.roomBLE = args["roomble"]!
                }
                CrossBLE.startAdvertising(result: result)
                return
            } else if(call.method == "stopAdvertising"){
                CrossBLE.stopAdvertising(result: result)
                return
            } else {
                result(FlutterMethodNotImplemented)
                return
            }
        })
        
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}

class CrossCamera: NSObject {
    static func checkCameraPermission(result: FlutterResult) {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            result(true);
            return
        case .denied:
            result(false);
            return
        case .notDetermined:
            let sem = DispatchSemaphore(value: 0)
            var hasPermission = false
            AVCaptureDevice.requestAccess(for: .video){access in
                hasPermission = access;
                sem.signal();
            }
            sem.wait()
            result(hasPermission);
            return
        case .restricted:
            result(false);
            return
        default:
            result(false);
            return
        }
    }
}

class CrossBLE: NSObject, CBPeripheralManagerDelegate {
    static var peripheral:CBPeripheralManager!
    static var peripheralData: CLBeaconRegion!
    static var studentBLE = 0;
    static var roomBLE = 0;
    static var bleDelegate = CrossBLE()
    
    static func checkBLEPermission(result: FlutterResult) {
        if checkBLEPermission() == true && checkLocationPermission() == true {
            result(true)
        } else {
            result(false)
        }
    }
    
    static func checkBLEPermission() -> Bool{
        if #available(iOS 13.1, *) {
            switch CBManager.authorization {
            case .allowedAlways:
                return true
            case .notDetermined:
                return true;
            case .restricted, .denied:
                return false
            @unknown default:
                return false
            }
        } else {
            return true
        }
    }
    
    static func checkLocationPermission() -> Bool{
        switch CLLocationManager.authorizationStatus() {
        case .authorizedAlways, .authorizedWhenInUse:
            return true
        case .notDetermined:
            CLLocationManager().requestWhenInUseAuthorization()
            return checkLocationPermission();
        case .restricted, .denied:
            return false
        @unknown default:
            return false
        }
    }
    
    static func startAdvertising(result: FlutterResult) {
        peripheral = CBPeripheralManager(delegate: bleDelegate, queue: nil)
        result(true)
    }
    
    static func stopAdvertising(result: FlutterResult) {
        if peripheral != nil {
            peripheral.stopAdvertising()
        }
        result(true)
    }
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        if peripheral.state == .poweredOn {
            let proximityUUID = UUID(uuidString: "0a66e898-2d31-11ea-978f-2e728ce88125")!
            let major : CLBeaconMajorValue = CLBeaconMajorValue(CrossBLE.roomBLE & 0x0000FFFF)
            let minor : CLBeaconMinorValue = CLBeaconMinorValue(CrossBLE.studentBLE & 0x0000FFFF)
            let beaconID = "bfass"
            if #available(iOS 13.0, *) {
                CrossBLE.peripheralData =  CLBeaconRegion(uuid: proximityUUID, major: major, minor: minor, identifier: beaconID)
            } else {
                // Fallback on earlier versions
                CrossBLE.peripheralData = CLBeaconRegion(proximityUUID: proximityUUID, major: major, minor: minor, identifier: beaconID)
            }
                
            peripheral.startAdvertising(((CrossBLE.peripheralData.peripheralData(withMeasuredPower: 68) as NSDictionary) as! [String : Any]))
        }
    }
}
