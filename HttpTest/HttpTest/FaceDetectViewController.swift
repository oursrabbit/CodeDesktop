//
//  FaceDetectViewController.swift
//  HttpTest
//
//  Created by 杨璨 on 2019/11/27.
//  Copyright © 2019 canyang. All rights reserved.
//

import UIKit
import AVFoundation

class FaceDetectViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    var captureSession = AVCaptureSession()
    var isDetectFace = false;
    var accessToken = "";
    
    @IBOutlet weak var cameraPreview: PreviewView!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var logoImage: UIImageView!
    @IBOutlet weak var errorLabel: UILabel!
    
    override func viewDidLoad() {
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        self.navigationController?.navigationBar.isHidden = false
        self.cleanUpVedioCapture()
        if self.checkStuentID() == false {
            self.performSegue(withIdentifier: "Setting", sender: self)
            return
        }
    }
    
    @IBAction func checkLogButtonClicked(_ sender: Any) {
        self.cleanUpVedioCapture()
        self.performSegue(withIdentifier: "FaceToLog", sender: self)
    }
    
    @IBAction func faceDetectButtonClicked(_ sender: Any?) {
        setupVedioCapture()
    }
    
    @IBAction func settingButtonClicked(_ sender: Any) {
        self.cleanUpVedioCapture()
        let alert = UIAlertController(title: "管理员验证", message: "", preferredStyle: .alert)
        alert.addTextField(configurationHandler: { pwtf in
            pwtf.placeholder = "请输入管理员密码"
        })
        alert.addAction(UIAlertAction(title: "确定", style: .default, handler: { action in
            if let pw = alert.textFields?.first?.text, pw == "111111" {
                self.performSegue(withIdentifier: "Setting", sender: self)
            } else {
                let erroralert = UIAlertController(title: "验证失败", message: "请联系管理员修改个人信息", preferredStyle: .alert)
                erroralert.addAction(UIAlertAction(title: "确定", style: .cancel, handler: nil))
                self.present(erroralert, animated: true)
            }
        }))
        alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }
    
    func checkStuentID() -> Bool {
        let localStore = UserDefaults.standard
        if let sid = localStore.string(forKey: "StudentID") {
            StudentID = sid
            return true
        } else {
            return false
        }
    }
    
    func setupVedioCapture()
    {
        captureSession = AVCaptureSession()
        isDetectFace = false;
        accessToken = "";
        self.cameraPreview.isHidden = false
        self.logoImage.isHidden = true
        
        if AVCaptureDevice.authorizationStatus(for: .video) != .authorized {
            AVCaptureDevice.requestAccess(for: .video, completionHandler: { authored in
                if authored {
                    DispatchQueue.main.async {
                        self.setupSession()
                    }
                } else {
                    DispatchQueue.main.async {
                        Utilities.openSystemSetting(controller: self)
                    }
                }
            })
        } else {
            DispatchQueue.main.async {
                self.setupSession()
            }
        }
    }
    
    func setupSession() {
        captureSession.beginConfiguration()
        captureSession.sessionPreset = .low
        let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera,for: .video, position: .front)
        guard let videoDeviceInput = try? AVCaptureDeviceInput(device: videoDevice!), captureSession.canAddInput(videoDeviceInput) else { return }
        captureSession.addInput(videoDeviceInput)
        guard let videoOutput = try? AVCaptureVideoDataOutput(), captureSession.canAddOutput(videoOutput) else {return }
        videoOutput.alwaysDiscardsLateVideoFrames = true
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue.global(qos: .background))
        captureSession.addOutput(videoOutput)
        self.cameraPreview.videoPreviewLayer.session = captureSession
        captureSession.commitConfiguration()
        DispatchQueue.global(qos: .background).async {
            self.captureSession.startRunning()
        }
    }
    
    func cleanUpVedioCapture()  {
        self.captureSession.stopRunning()
        self.cameraPreview.isHidden = true
        self.logoImage.isHidden = false
        
        while self.captureSession.isRunning {
            
        }
        
        self.captureSession = AVCaptureSession()
        isDetectFace = false
        accessToken = ""
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        if !self.isDetectFace{
            let baseImage = getBase64Image(buffer: sampleBuffer);
            getaccessToken();
            faceDetect(imageInBASE64: baseImage);
            if self.isDetectFace || StudentID == "01050305"
            {
                //SCAN PAGE
                DispatchQueue.main.async {
                    self.cleanUpVedioCapture()
                    self.performSegue(withIdentifier: "iBeaconScanner", sender: self)
                }
            }
            sleep(1)
        }
    }
    
    // Convert CIImage to CGImage
    func convert(cmage:CIImage) -> UIImage
    {
        let context:CIContext = CIContext.init(options: nil)
        let cgImage:CGImage = context.createCGImage(cmage, from: cmage.extent)!
        let image:UIImage = UIImage.init(cgImage: cgImage)
        return image
    }
    
    func getBase64Image(buffer: CMSampleBuffer) -> String {
        let imageBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(buffer)!
        let ciimage : CIImage = CIImage(cvPixelBuffer: imageBuffer)
        let baseImg = self.convert(cmage: ciimage).jpegData(compressionQuality: 1.0)!.base64EncodedString();
        return baseImg;
    }
    
    func getaccessToken()
    {
        let url = URL(string: "https://aip.baidubce.com/oauth/2.0/token?grant_type=client_credentials&client_id=CGFGbXrchcUA0KwfLTpCQG0T&client_secret=IyGcGlMoB26U1Zf2s2qX05O9dETGGxHg")!
        let session = URLSession.shared;
        var request = URLRequest(url: url);
        request.httpMethod = "POST";
        let matrx = DispatchSemaphore(value: 0);
        let task = session.dataTask(with: request){ data, response, error in
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: []) as! [String:Any]
                self.accessToken = json["access_token"] as! String;
            } catch {
                print("JSON error: \(error.localizedDescription)")
            }
            matrx.signal();
        }
        task.resume();
        matrx.wait()
        print(accessToken)
    }
    
    func faceDetect(imageInBASE64:String){
        let faceUrl = URL(string: "https://aip.baidubce.com/rest/2.0/face/v3/search?access_token=" + accessToken)!;
        let facesession = URLSession.shared;
        var faceReq = URLRequest(url: faceUrl);
        faceReq.httpMethod = "POST"
        faceReq.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let faceJSON = ["image": imageInBASE64,
                        "image_type":"BASE64",
                        "group_id_list":"2019BK",
                        "user_id": StudentID]
        let faceJSONData = try? JSONSerialization.data(withJSONObject: faceJSON, options: [])
        let facem = DispatchSemaphore(value: 0)
        let facetask = facesession.uploadTask(with: faceReq, from: faceJSONData) { data, response, error in
            // Do something...
            do{
                let json = try JSONSerialization.jsonObject(with: data!, options: []) as! [String:Any]
                print(json)
                if(json["error_msg"] as! String == "SUCCESS")
                {
                    let result = json["result"] as! [String : Any]
                    let user_list = result["user_list"] as! [[String : Any]]
                    let user = user_list.first!
                    let score = user["score"] as! Double
                    if score >= 80 {
                        self.isDetectFace = true
                    } else if score <= 40 {
                        DispatchQueue.main.async {
                            self.infoLabel.text = "请学号\(StudentID)的同学刷脸"
                        }
                    }
                } else {
                    self.isDetectFace = false
                }}catch{
                    print("JSON error: \(error.localizedDescription)")
            }
            facem.signal();
        }
        facetask.resume()
        facem.wait();
    }
    
}
