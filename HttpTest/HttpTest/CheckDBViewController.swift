//
//  CheckDBViewController.swift
//  HttpTest
//
//  Created by 杨璨 on 2019/12/4.
//  Copyright © 2019 canyang. All rights reserved.
//

import UIKit

class CheckDBViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var logsTable: UITableView!
    @IBOutlet weak var idLabel: UILabel!
    
    var logs = [[String : Any]]()
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return logs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        //let studentid = logs[indexPath.row]["StudentID"] as! String
        let date = ((logs[indexPath.row]["CheckDate"] as! [String : String])["iso"])!.iso8601!.shortString
        let roomid = logs[indexPath.row]["RoomID"] as! String
        
        //let idLabel = cell.viewWithTag(1000) as! UILabel
        let roomLabel = cell.viewWithTag(1000) as! UILabel
        let timeLabel = cell.viewWithTag(3000) as! UILabel
        
        //idLabel.text = studentid
        roomLabel.text = roomid
        timeLabel.text = date
        
        return cell
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        self.navigationController?.navigationBar.isHidden = false
        self.idLabel.text = StudentID
        let checkJson = ["StudentID": StudentID]
        let checkJSONData = try? JSONSerialization.data(withJSONObject: checkJson, options: [])
        let jsonString = String(data: checkJSONData!, encoding: .utf8)
        var urlString = jsonString!.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
        urlString = "https://yhwfdae1.lc-cn-n1-shared.com/1.1/classes/CheckRecording?where=\(urlString!)"
        let createCheckItemURL = URL(string: urlString!)
        let leancloudSession = URLSession.shared;
        var leancloudRequest = URLRequest(url: createCheckItemURL!);
        leancloudRequest.httpMethod = "GET"
        leancloudRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        leancloudRequest.setValue("YHwFdAE1qj1OcWfJ5xoayLKr-gzGzoHsz", forHTTPHeaderField: "X-LC-Id")
        leancloudRequest.setValue("UbnM6uOP2mxah3nFMzurEDQL", forHTTPHeaderField: "X-LC-Key")
        let uploadDatatask = leancloudSession.dataTask(with: leancloudRequest) { data, response, error in
            // Do something...
            do{
                let json = try JSONSerialization.jsonObject(with: data!, options: []) as! [String:Any]
                self.logs = json["results"] as! [[String : Any]]
                DispatchQueue.main.async {
                    self.logsTable.reloadData()
                }
            }catch{
                print("JSON error: \(error.localizedDescription)")
            }
        }
        uploadDatatask.resume()
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
