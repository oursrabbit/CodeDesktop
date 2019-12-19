//
//  QRScannerViewController.swift
//  HttpTest
//
//  Created by 杨璨 on 2019/11/28.
//  Copyright © 2019 canyang. All rights reserved.
//

import UIKit
import AVFoundation

class QRScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {

    var captureSession = AVCaptureSession()
    var timer: DispatchSource? = nil;
    
    @IBOutlet weak var cameraPreview: PreviewView!
    @IBOutlet weak var infoLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        countDown(30)
        setupQRScanner()
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
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
                    self.infoLabel.text = "签到失败"
                })
            }else{//正在倒计时
                DispatchQueue.main.sync(execute: { () -> Void in
                    self.infoLabel.text = "签到剩余时间：\(String.init(format: "%.2d", timeout))秒"
                })
                timeout -= 1;
            }
        })
        timer?.resume()
    }
    
    func setupQRScanner()
    {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .notDetermined: // The user has not yet been asked for camera access.
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted {
                    DispatchQueue.main.async {
                        self.setupVedioCapture()
                    }
                } else {
                    self.infoLabel.text = "请打开摄像头权限"
                }
            }
        case .denied: // The user has previously denied access.
            self.infoLabel.text = "请打开摄像头权限"
        case .restricted: // The user can't grant access due to restrictions.
            self.infoLabel.text = "请打开摄像头权限"
        case .authorized:
            setupVedioCapture()
        @unknown default:
            print("Camera Unknow Error")
        }
    }

    
    func setupVedioCapture()
    {
        captureSession.beginConfiguration()
        
        captureSession.sessionPreset = .low
        
        let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera,for: .video, position: .back)
        guard let videoDeviceInput = try? AVCaptureDeviceInput(device: videoDevice!), captureSession.canAddInput(videoDeviceInput) else { return }
        captureSession.addInput(videoDeviceInput)
        
        guard let videoOutput = try? AVCaptureMetadataOutput(), captureSession.canAddOutput(videoOutput) else {return }
        
        captureSession.addOutput(videoOutput)
        videoOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        print(videoOutput.availableMetadataObjectTypes)
        videoOutput.metadataObjectTypes = [.qr]
                
        self.cameraPreview.videoPreviewLayer.session = captureSession
        captureSession.commitConfiguration()
        captureSession.startRunning()
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            print(stringValue)
            DispatchQueue.main.async {
                self.timer?.cancel()
                self.infoLabel.text = "签到成功," + self.createNewQR()
            }
            self.captureSession.stopRunning()
        }
    }
    
    func createNewQR() -> String
    {
        var result = ""
         let faceUrl = URL(string: "http://oursrabbit.gicp.net")!;
               let facesession = URLSession.shared;
               var faceReq = URLRequest(url: faceUrl);
               faceReq.httpMethod = "POST"
               faceReq.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let faceJSON = ["idnum" : StudentID]
               let faceJSONData = try? JSONSerialization.data(withJSONObject: faceJSON, options: [])
               let facem = DispatchSemaphore(value: 0)
               let facetask = facesession.uploadTask(with: faceReq, from: faceJSONData) { data, response, error in
               //result = String(data: data!, encoding: .utf16)!
                facem.signal();
        }
        facetask.resume();
        facem.wait()
        return result
    }
}
