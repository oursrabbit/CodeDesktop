//
//  ViewController.swift
//  HttpTest
//
//  Created by 杨璨 on 2019/11/25.
//  Copyright © 2019 canyang. All rights reserved.
//

import UIKit
import AVFoundation
import CoreNFC

class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate, NFCNDEFReaderSessionDelegate , NFCTagReaderSessionDelegate{
    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
        for msg in messages {
            print(msg);
        }
    }
    
    func tagReaderSessionDidBecomeActive(_ session: NFCTagReaderSession) {
        
    }
    
    func tagReaderSession(_ session: NFCTagReaderSession, didInvalidateWithError error: Error) {
        
    }
    
    func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
        
    }
    
    @IBAction func ScanNFC(_ sender: Any) {
        guard NFCNDEFReaderSession.readingAvailable else {
            let alertController = UIAlertController(
                title: "Scanning Not Supported",
                message: "This device doesn't support tag scanning.",
                preferredStyle: .alert
            )
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alertController, animated: true, completion: nil)
            return
        }
        
        session = NFCTagReaderSession(pollingOption: .iso14443, delegate: self)!
        session!.alertMessage = "Hold your iPhone near the item to learn more about it."
        session!.begin()
    }
    
    @IBAction func FaceDec(_ sender: Any) {
        captureSession.beginConfiguration()
        captureSession.sessionPreset = .low
        let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera,
                                                  for: .video, position: .front)
        guard
            let videoDeviceInput = try? AVCaptureDeviceInput(device: videoDevice!),
            captureSession.canAddInput(videoDeviceInput)
            else { return }
        captureSession.addInput(videoDeviceInput)
        
        guard let videoOutput = try? AVCaptureVideoDataOutput(),
            captureSession.canAddOutput(videoOutput)
            else {return }
        videoOutput.alwaysDiscardsLateVideoFrames = true
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue.main)
        captureSession.addOutput(videoOutput)
        
        self.videopreview.videoPreviewLayer.session = captureSession
        captureSession.commitConfiguration()
        captureSession.startRunning()
    }
    
    @IBOutlet weak var jsonText: UILabel!
    @IBOutlet weak var videopreview: PreviewView!
    
    let captureSession = AVCaptureSession()
    
    var i=0;
    
    var session: NFCTagReaderSession? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        jsonText.text = "开始检测"
        
    }
    
    func tagReaderSession(_ session: NFCTagReaderSession, didDetect tags: [NFCTag]) {
        for tag in tags {
            print(tag)
            guard case let .miFare(mifareTag) = tag else {
                return
            }
            print(mifareTag)
            let data = mifareTag.identifier
            let id = [UInt8](data)
            var uid = ""
            for i in id {
                print(i)
                uid += String(format:"%02X", i) + " ";
            }
            DispatchQueue.main.async(execute: {
                self.jsonText.text = "uid: " + uid
            })
        }
        self.session?.invalidate()
        session.invalidate()
        self.session = nil;
    }
    
    func readerSession(_ session: NFCNDEFReaderSession, didDetect tags: [NFCNDEFTag]) {
        
        for tag in tags {
            print(tag)
            
            guard case let  NFCTag.miFare(mifareTag) = tag else {
                return
            }
            print(mifareTag)
            let data = mifareTag.identifier
            let id = [UInt8](data)
            for i in id {
                print(i)
            }
            
        }
    }
    
    var findout = false;
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        if findout == false {
            let imageBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)!
            let ciimage : CIImage = CIImage(cvPixelBuffer: imageBuffer)
            let baseImg = self.convert(cmage: ciimage).jpegData(compressionQuality: 1.0)!.base64EncodedString();
            
            
            
            let url = URL(string: "https://aip.baidubce.com/oauth/2.0/token?grant_type=client_credentials&client_id=CGFGbXrchcUA0KwfLTpCQG0T&client_secret=IyGcGlMoB26U1Zf2s2qX05O9dETGGxHg")!
            
            let session = URLSession.shared;
            
            var request = URLRequest(url: url);
            request.httpMethod = "POST";
            
            let matrx = DispatchSemaphore(value: 0);
            
            var access_token = "";
            
            let task = session.dataTask(with: request){ data, response, error in
                do {
                    let json = try JSONSerialization.jsonObject(with: data!, options: []) as! [String:Any]
                    //print(json["access_token"])
                    access_token = json["access_token"] as! String;
                } catch {
                    print("JSON error: \(error.localizedDescription)")
                }
                
                matrx.signal();
            }
            
            task.resume();
            matrx.wait()
            
            let faceUrl = URL(string: "https://aip.baidubce.com/rest/2.0/face/v3/detect?access_token=" + access_token)!;
            let facesession = URLSession.shared;
            var faceReq = URLRequest(url: faceUrl);
            faceReq.httpMethod = "POST"
            faceReq.setValue("application/json", forHTTPHeaderField: "Content-Type")
            let faceJSON = ["image": baseImg,
                            "image_type":"BASE64",
                            "face_field":"faceshape,facetype,beauty"]
            let faceJSONData = try? JSONSerialization.data(withJSONObject: faceJSON, options: [])
            let facem = DispatchSemaphore(value: 0)
            let facetask = facesession.uploadTask(with: faceReq, from: faceJSONData) { data, response, error in
                // Do something...
                let json = try? JSONSerialization.jsonObject(with: data!, options: []) as! [String:Any]
                if(json!["error_msg"] as! String == "SUCCESS")
                {
                    self.findout = true
                } else
                {
                    self.findout = false
                }
                facem.signal();
            }
            facetask.resume()
            //facem.wait();
            DispatchQueue.main.async(execute: {
                self.jsonText.text = access_token
                if self.findout {
                    //self.captureSession.stopRunning();
                    
                    self.jsonText.text = "检测到人脸"
                    
                } else
                {
                    self.jsonText.text = "请面对镜头"
                }
            })
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
}


