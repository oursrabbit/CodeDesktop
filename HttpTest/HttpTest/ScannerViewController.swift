//
//  ScannerViewController.swift
//  HttpTest
//
//  Created by 杨璨 on 2019/11/27.
//  Copyright © 2019 canyang. All rights reserved.
//

import UIKit
import CoreNFC

class ScannerViewController: UIViewController, NFCTagReaderSessionDelegate {

    var session: NFCTagReaderSession? = nil;
    var timer: DispatchSource? = nil;
    
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var scanButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        countDown(30)
        setupNFCScanner()
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
                    self.scanButton.isEnabled = false
                    self.session?.invalidate()
                    self.session = nil
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
    
    @IBAction func scanButtonOnClicked(_ sender: Any) {
        setupNFCScanner()
    }
    
    func setupNFCScanner()
    {
        session = NFCTagReaderSession(pollingOption: .iso14443, delegate: self)!
        session!.alertMessage = "将手机靠近标签进行签到"
        session!.begin()
    }
    
    func tagReaderSessionDidBecomeActive(_ session: NFCTagReaderSession) {
        
    }
    
    func tagReaderSession(_ session: NFCTagReaderSession, didInvalidateWithError error: Error) {
        session.invalidate()
    }
    
    func tagReaderSession(_ session: NFCTagReaderSession, didDetect tags: [NFCTag]) {
        DispatchQueue.main.async(execute: {
            self.timer?.cancel()
            self.infoLabel.text = "签到成功！"
            self.scanButton.isEnabled = false
        })
        session.invalidate()
    }
}
