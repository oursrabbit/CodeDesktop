//
//  OrgViewController.swift
//  HttpTest
//
//  Created by 杨璨 on 2019/11/26.
//  Copyright © 2019 canyang. All rights reserved.
//

import UIKit
import CoreNFC
import AVFoundation

class OrgViewController: UIViewController , AVCaptureMetadataOutputObjectsDelegate {
    
    var captureSession = AVCaptureSession()
    var isDetectFace = false;
    var accessToken = "";
    
    @IBOutlet weak var cameraPreview: PreviewView!
    @IBOutlet weak var infoLabel: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
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
                self.infoLabel.text += stringValue + "\n"
            }
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
        let faceUrl = URL(string: "https://aip.baidubce.com/rest/2.0/face/v3/detect?access_token=" + accessToken)!;
        let facesession = URLSession.shared;
        var faceReq = URLRequest(url: faceUrl);
        faceReq.httpMethod = "POST"
        faceReq.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let faceJSON = ["image": imageInBASE64,
                        "image_type":"BASE64",
                        "face_field":""]
        let faceJSONData = try? JSONSerialization.data(withJSONObject: faceJSON, options: [])
        let facem = DispatchSemaphore(value: 0)
        let facetask = facesession.uploadTask(with: faceReq, from: faceJSONData) { data, response, error in
            // Do something...
            do{
                let json = try JSONSerialization.jsonObject(with: data!, options: []) as! [String:Any]
                print(json)
                if(json["error_msg"] as! String == "SUCCESS")
                {
                    self.isDetectFace = true
                } else
                {
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
