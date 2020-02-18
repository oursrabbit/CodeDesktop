//
//  FaceDetectSimpleViewController.swift
//  Qin-ios
//
//  Created by 杨璨 on 2020/1/6.
//  Copyright © 2020 canyang. All rights reserved.
//

import UIKit

class FaceDetectSimpleViewController: StaticViewController, CameraDelegate {

    var captureSession = Camera()
    
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var previewView: QinPreView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        infoLabel.text = ""
        captureSession = Camera()
        captureSession.delegate = self
        captureSession.previewView = previewView
        captureSession.startRunning() 
    }
    
    @IBAction func backBuildingListView(_ sender: Any) {
        self.captureSession.stopRunning()
        self.navigationController?.popViewController(animated: true)
    }
    
    func cameraOnFaceDetected() {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "checkresult", sender: self)
        }
    }
    
    func updateInfoLabel(message: String) {
        DispatchQueue.main.async {
            self.infoLabel.text = message
        }
    }
    
    func faceDetectFail(errorcode: CameraErrorCode, error: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "面部识别失败", message: error, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "重新签到", style: .default, handler: { _ in
                DispatchQueue.main.async {
                    self.navigationController?.popViewController(animated: true)
                }
            }))
            alert.addAction(UIAlertAction(title: "前往设置", style: .default, handler: { _ in
                if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                    if UIApplication.shared.canOpenURL(settingsUrl) {
                        DispatchQueue.main.async {
                            UIApplication.shared.open(settingsUrl, completionHandler: nil)
                        }
                    }
                }
            }))
            self.present(alert, animated: true, completion: nil)
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

}

