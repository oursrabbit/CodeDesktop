//
//  ViewController.swift
//  QinDevice-Mac
//
//  Created by 杨璨 on 2020/2/10.
//  Copyright © 2020 杨璨. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    @IBOutlet weak var changeButton: NSButtonCell!
    @IBOutlet weak var schoolIDTextFiled: NSTextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    @IBAction func updateAdvertising(_ sender: Any) {
        self.changeButton.isEnabled = false
        ApplicationHelper.CurrentUser = Student()
        ApplicationHelper.CurrentUser.SchoolID = self.schoolIDTextFiled.stringValue
        DatabaseHelper.getCurrentUserInfomation() { finish in
            if finish {
                DatabaseHelper.LCUpdateAdvertising() { error in
                    DispatchQueue.main.async {
                        self.changeButton.isEnabled = true
                    }
                }
            }
        }
    }
}

