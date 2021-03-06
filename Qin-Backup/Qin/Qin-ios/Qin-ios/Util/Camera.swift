//
//  Camera.swift
//  Qin-ios
//
//  Created by 杨璨 on 2020/1/6.
//  Copyright © 2020 canyang. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit

public enum CameraErrorCode {
    case deviceDenied
    case deviceInitFailed
    case unknowError
}

public enum FaceDetectStep {
    case stop
    case waitingImage
    case gettingAccessToken
    case detectingFace
}

public protocol CameraDelegate {
    func cameraOnFaceDetected()
    func faceDetectFail(errorcode: CameraErrorCode, error: String)
    func updateInfoLabel(message: String)
}

class Camera: NSObject {
    public var delegate: CameraDelegate?
    public var previewView: QinPreView?
    
    var captureSession = AVCaptureSession()
    var facedetectStep = FaceDetectStep.stop

    public func startRunning() {
        captureSession = AVCaptureSession()
        
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            setupSession()
            return
        case .denied:
            delegate?.faceDetectFail(errorcode: .deviceDenied, error: "未获取摄像头权限")
            return
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video){ access in
                if access {
                    self.setupSession()
                    return
                } else {
                    self.delegate?.faceDetectFail(errorcode: .deviceDenied, error: "未获取摄像头权限")
                }
            }
            return
        case .restricted:
            delegate?.faceDetectFail(errorcode: .deviceDenied, error: "未获取摄像头权限")
            return
        default:
            delegate?.faceDetectFail(errorcode: .unknowError, error: "未知错误")
            return
        }
    }
    
    public func stopRunning() {
        self.captureSession.stopRunning()
        //self.previewView?.isHidden = true
    }
    
    func setupSession() {
        do {
            //self.previewView?.isHidden = false
            delegate?.updateInfoLabel(message: "开始初始化摄像头")
            captureSession.beginConfiguration()
            captureSession.sessionPreset = .vga640x480
            let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera,for: .video, position: .front)
            let videoDeviceInput = try AVCaptureDeviceInput(device: videoDevice!)
            captureSession.canAddInput(videoDeviceInput)
            captureSession.addInput(videoDeviceInput)
            let videoOutput = AVCaptureVideoDataOutput()
            captureSession.canAddOutput(videoOutput)
            videoOutput.alwaysDiscardsLateVideoFrames = true
            videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue.global(qos: .background))
            captureSession.addOutput(videoOutput)
            DispatchQueue.main.async {
                self.previewView?.videoPreviewLayer.session = self.captureSession
                self.previewView?.videoPreviewLayer.videoGravity = .resize
                self.captureSession.commitConfiguration()
                DispatchQueue.global().async {
                    self.delegate?.updateInfoLabel(message: "初始化面部识别...")
                    self.facedetectStep = .waitingImage
                    self.captureSession.startRunning()
                }
            }
        } catch {
            //self.previewView?.isHidden = true
            delegate?.faceDetectFail(errorcode: .deviceInitFailed, error: "摄像头初始化失败")
            return
        }
    }
    
    func convert(cmage:CIImage) -> UIImage {
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

    
    func faceDetect(imageInBASE64: String, accessToken: String, completionHandler: @escaping (String?) -> Void) {
        let faceUrl = URL(string: "https://aip.baidubce.com/rest/2.0/face/v3/search?access_token=" + accessToken)!;
        let facesession = URLSession.shared;
        var faceReq = URLRequest(url: faceUrl);
        faceReq.httpMethod = "POST"
        faceReq.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let faceJSON = ["image": imageInBASE64,
                        "image_type":"BASE64",
                        "group_id_list":"2019BK",
                        "user_id":ApplicationHelper.CurrentUser.BaiduFaceID,
                        "liveness_control":"NORMAL"]
        let faceJSONData = try? JSONSerialization.data(withJSONObject: faceJSON, options: [])
        facesession.uploadTask(with: faceReq, from: faceJSONData) { data, response, error in
            do{
                let json = try JSONSerialization.jsonObject(with: data!, options: []) as! [String:Any]
                print(json)
                if(json["error_msg"] as! String == "SUCCESS"){
                    let result = json["result"] as! [String:Any?]
                    let userlist = result["user_list"] as! [[String:Any?]]
                    let score = userlist[0]["score"] as! NSNumber
                    if score.floatValue >= 80.0 {
                        completionHandler(nil)
                    } else {
                        completionHandler("请 \(ApplicationHelper.CurrentUser.Name) 同学面对摄像头")
                    }
                } else {
                    completionHandler("请 \(ApplicationHelper.CurrentUser.Name) 同学面对摄像头")
                }
            }catch{
                completionHandler("网络错误，正在重试...")
            }
        }.resume()
    }
}

extension Camera: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        if self.facedetectStep == .waitingImage {
            let baseImage = getBase64Image(buffer: sampleBuffer);
            self.facedetectStep = .gettingAccessToken
            ApplicationHelper.getaccessToken() { accessToken in
                if let baiduAT = accessToken {
                    if ApplicationHelper.CurrentUser.ID == "01050305"{
                        self.facedetectStep = .stop
                        self.captureSession.stopRunning()
                        self.delegate?.cameraOnFaceDetected()
                    } else {
                        self.facedetectStep = .detectingFace
                        self.faceDetect(imageInBASE64: baseImage, accessToken: baiduAT) { error in
                            if error == nil {
                                self.facedetectStep = .stop
                                self.captureSession.stopRunning()
                                self.delegate?.cameraOnFaceDetected()
                            } else {
                                self.delegate?.updateInfoLabel(message: error!)
                                self.facedetectStep = .waitingImage
                            }}
                    }
                } else {
                    self.delegate?.updateInfoLabel(message: "面部识别失败，正在重试...")
                    self.facedetectStep = .waitingImage
                }
            }
        }
    }
}

