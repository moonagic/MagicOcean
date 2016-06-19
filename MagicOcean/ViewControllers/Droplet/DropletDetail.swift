//
//  DropletDetail.swift
//  MagicOcean
//
//  Created by Wu Hengmin on 16/6/13.
//  Copyright © 2016年 Wu Hengmin. All rights reserved.
//

import UIKit
import Alamofire
import Toast_Swift
import MBProgressHUD

class DropletDetail: UITableViewController {
    
    var droplet:NSDictionary!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.title = Droplet.sharedInstance.Name
        loadDropletDetail()
    }
    
    func loadDropletDetail() {
//        curl -X GET -H "Content-Type: application/json" -H "Authorization: Bearer b7d03a6947b217efb6f3ec3bd3504582" "https://api.digitalocean.com/v2/droplets/3164494"
        
        let Headers = [
            "Content-Type": "application/json",
            "Authorization": "Bearer "+Account.sharedInstance.Access_Token
        ]
        
        weak var weakSelf = self
        print(BASE_URL+URL_DROPLETS+"/\(Droplet.sharedInstance.ID)")
        Alamofire.request(.GET, BASE_URL+URL_DROPLETS+"/\(Droplet.sharedInstance.ID)", parameters: nil, encoding: .URL, headers: Headers).responseJSON { response in
            if let _ = weakSelf {
                let dic = response.result.value as! NSDictionary
                print("response=\(dic)")
                let droplet:NSDictionary = (dic.valueForKey("droplet") as? NSDictionary)!
                self.droplet = droplet
                dispatch_async(dispatch_get_main_queue(), {
                    self.title = droplet.valueForKey("name") as? String
                })
            }
        }
    }

    @IBAction func actionPressed(sender: AnyObject) {
//        self.view.window!.makeToast("test", duration: 0.5, position: .Center)
//        self.view.window!.makeToastActivity(.Center)
//        MBProgressHUD.showHUDAddedTo(self.view.window, animated: true)
        
        weak var weakSelf = self
        let alertController = UIAlertController(title: "", message: "", preferredStyle: .ActionSheet)
        
        // Reboot
        let dateAction = UIAlertAction(title: "Reboot", style: .Default) { (action:UIAlertAction!) in
            print("you have pressed the Reboot button");
            weakSelf!.dropletActions("reboot")
        }
        alertController.addAction(dateAction)
        // Power Off
        let status:String = droplet.valueForKey("status") as! String
        if status == "off" {
            let powerAction = UIAlertAction(title: "Power On", style: .Default) { (action:UIAlertAction!) in
                print("you have pressed the Power On button");
                weakSelf!.dropletActions("power_on")
            }
            alertController.addAction(powerAction)
        } else if status == "active" {
            let powerAction = UIAlertAction(title: "Power Off", style: .Default) { (action:UIAlertAction!) in
                print("you have pressed the Power Off button");
                weakSelf!.dropletActions("power_off")
            }
            alertController.addAction(powerAction)
        }
        
        // Power Cycle
        let androidAction = UIAlertAction(title: "Power Cycle", style: .Default) { (action:UIAlertAction!) in
            print("you have pressed the Power Cycle button");
            weakSelf!.dropletActions("power_cycle")
        }
        alertController.addAction(androidAction)
        
        let deleteAction = UIAlertAction(title: "Delete", style: .Destructive) { (action:UIAlertAction!) in
            print("you have pressed the Delete button");
        }
        alertController.addAction(deleteAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action:UIAlertAction!) in
            print("you have pressed the cancel button");
        }
        alertController.addAction(cancelAction)
        
        self.presentViewController(alertController, animated: true, completion:nil)
    }
    
    func dropletActions(type: String) {
        let Headers = [
            "Content-Type": "application/json",
            "Authorization": "Bearer "+Account.sharedInstance.Access_Token
        ]
        
        let parameters = [
            "type": type
        ]
        
        weak var weakSelf = self
        print(BASE_URL+URL_DROPLETS+"/\(Droplet.sharedInstance.ID)/"+URL_ACTIONS)
        Alamofire.request(.POST, BASE_URL+URL_DROPLETS+"/\(Droplet.sharedInstance.ID)/"+URL_ACTIONS, parameters: parameters, encoding: .JSON, headers: Headers).responseJSON { response in
            if let _ = weakSelf {
                let dic = response.result.value as! NSDictionary
                print("response=\(dic)")
//                let droplet:NSDictionary = (dic.valueForKey("droplet") as? NSDictionary)!
//                dispatch_async(dispatch_get_main_queue(), {
//                    self.title = droplet.valueForKey("name") as? String
//                })
            }
        }
        
    }
    
    func deleteDroplet() {
        
    }
    
    
}
