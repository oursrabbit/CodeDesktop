//
//  QinSettingViewController.swift
//  Qin-ios
//
//  Created by 杨璨 on 2020/1/6.
//  Copyright © 2020 canyang. All rights reserved.
//

import UIKit
import RealmSwift

class QinSettingViewController: StaticViewController, UITextFieldDelegate {
    
    @IBOutlet weak var superViewBottom: NSLayoutConstraint!
    @IBOutlet weak var superViewTop: NSLayoutConstraint!
    @IBOutlet weak var idtextfield: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var waitingView: WaitingView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        idtextfield.text = "\(ApplicationHelper.CurrentUser.ID)"
        idtextfield.delegate = self
        
        if ApplicationHelper.CurrentUser.ID != "" {
            updateSchoolID(self)
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
    
    func updateWaitingView(message: String) {
        DispatchQueue.main.async {
            self.waitingView.messageLabel.text = message
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.superViewTop.constant = -200;
        self.superViewBottom.constant = 200;
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.superViewTop.constant = 0;
        self.superViewBottom.constant = 0;
    }

    @IBAction func updateSchoolID (_ sender: Any) {
        if let schoolId = idtextfield.text {
            ApplicationHelper.CurrentUser.ID = schoolId
            UserDefaults.standard.set(ApplicationHelper.CurrentUser.ID, forKey: "ID")
            waitingView.isHidden = false
            self.updateWaitingView(message: "正在获取用户信息...")
            DispatchQueue.global().async {
                self.getCurrentUserInfomation()
            }
        }
    }
    
    func getCurrentUserInfomation() {
        self.updateWaitingView(message: "正在更新用户信息...")
        if Student.SetupCurrentStudent() {
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "roomlist", sender: self)
            }
        } else {
            DispatchQueue.main.async {
                self.waitingView.isHidden = true
                let alert = UIAlertController(title: "登录失败", message: "未找到用户", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "确定", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
}
