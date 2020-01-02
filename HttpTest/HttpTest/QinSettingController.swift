//
//  IndexViewController.swift
//  HttpTest
//
//  Created by 杨璨 on 2019/11/27.
//  Copyright © 2019 canyang. All rights reserved.
//

import UIKit

var StudentID = "";

class QinSettingController: UIViewController {

    @IBOutlet weak var idtextView: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        self.navigationController?.navigationBar.isHidden = false
        idtextView.text = StudentID
    }
        
    @IBAction func UpdateStudentID(_ sender: Any?) {
        StudentID = idtextView.text!
        let localStore = UserDefaults.standard
        localStore.set(StudentID, forKey: "StudentID")
        navigationController?.popViewController(animated: true)
    }
}
