//
//  LaunchViewController.swift
//  Qin-ios
//
//  Created by 杨璨 on 2020/2/15.
//  Copyright © 2020 canyang. All rights reserved.
//

import UIKit
import Foundation
import RealmSwift

class LaunchViewController: StaticViewController {

    var countdown = 3
    @IBOutlet weak var countdownButton:UIButton!
    @IBOutlet weak var launchImageView: UIImageView!
    @IBOutlet weak var launchImageBackgroundView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let launchImageCount = (try! Realm()).objects(LaunchImage.self).count
        if launchImageCount != 0 {
            let applicationData = (try! Realm()).objects(LaunchImage.self)[Int.random(in: 0..<launchImageCount)]
            let launchImageData = applicationData.LaunchImage!
            let launchImageBackgroundData = applicationData.LaunchImageBackground!
            let launchImage = UIImage(data: launchImageData)
            let launchImageBackground = UIImage(data: launchImageBackgroundData)
            launchImageView.image = launchImage
            launchImageBackgroundView.image = launchImageBackground
        }
        
        DispatchQueue.global().async {
            self.countingDown()
        }
    }
    

    
    func countingDown() {
        while self.countdown > 0 {
            DispatchQueue.main.async {
                self.countdownButton.setTitle("跳过 \(self.countdown)s >", for: .normal)
                self.countdown = self.countdown - 1
            }
            sleep(1)
        }
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "startapp", sender: self)
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

    @IBAction func jumpLaunch() {
        countdown = 0
    }
}
