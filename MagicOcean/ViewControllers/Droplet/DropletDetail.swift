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
    @IBOutlet weak var imageLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var memAndCPULabel: UILabel!
    @IBOutlet weak var diskLabel: UILabel!
    @IBOutlet weak var transferLabel: UILabel!
    @IBOutlet weak var regionLabel: UILabel!
    
    
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
                    
                    self.imageLabel.text = droplet.valueForKey("image")?.valueForKey("slug") as? String
                    
                    let price:Float = droplet.valueForKey("size")?.valueForKey("price_monthly") as! Float
                    self.priceLabel.text = String(format: "$ %.2f", price);
                    
                    let memory:Int = droplet.valueForKey("size")?.valueForKey("memory") as! Int
                    let cpu:Int = droplet.valueForKey("size")?.valueForKey("vcpus") as! Int
                    self.memAndCPULabel.text = "\(memory)MB / \(cpu)CPUs"
                    
                    let transfer:Int = droplet.valueForKey("size")?.valueForKey("transfer") as! Int
                    self.transferLabel.text = "Transfer \(transfer)TB"
                    
                    let region:String = droplet.valueForKey("region")?.valueForKey("slug") as! String
                    self.regionLabel.text = region
                })
            }
        }
    }

    @IBAction func actionPressed(sender: AnyObject) {
        
        weak var weakSelf = self
        let alertController = UIAlertController(title: "Actions", message: "Choose the action you want.", preferredStyle: .Alert)
        
        // Reboot
        let dateAction = UIAlertAction(title: "Reboot", style: .Default) { (action:UIAlertAction!) in
            print("you have pressed the Reboot button");
            weakSelf!.dropletActions("reboot")
        }
        alertController.addAction(dateAction)
        // Power Off
        let status:String = droplet.valueForKey("status") as! String
        if status == "off" {
            let powerAction = UIAlertAction(title: "Power On", style: .Destructive) { (action:UIAlertAction!) in
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
            }
        }
        
    }
    
    @IBAction func powerCyclePressed(sender: AnyObject) {
        weak var weakSelf = self
        let alertController = UIAlertController(title: "Warnnig", message: "This action will not undo!", preferredStyle: .Alert)
        
        let dateAction = UIAlertAction(title: "Power Cycle", style: .Destructive) { (action:UIAlertAction!) in
            weakSelf!.dropletActions("power_cycle")
        }
        alertController.addAction(dateAction)
        
        let cancellAction = UIAlertAction(title: "Cancell", style: .Cancel) { (action:UIAlertAction!) in
            
        }
        alertController.addAction(cancellAction)
        
        self.presentViewController(alertController, animated: true, completion:nil)
    }
    
    @IBAction func deletePressed(sender: AnyObject) {
        weak var weakSelf = self
        let alertController = UIAlertController(title: "Warnnig", message: "This action will not undo!", preferredStyle: .Alert)
        
        // Reboot
        let dateAction = UIAlertAction(title: "Delete", style: .Destructive) { (action:UIAlertAction!) in
            weakSelf!.deleteDroplet()
        }
        alertController.addAction(dateAction)
        
        
        let cancellAction = UIAlertAction(title: "Cancell", style: .Cancel) { (action:UIAlertAction!) in
            
        }
        alertController.addAction(cancellAction)

        
        self.presentViewController(alertController, animated: true, completion:nil)
        
    }
    
    func deleteDroplet() {
//        curl -X DELETE -H "Content-Type: application/json" -H "Authorization: Bearer b7d03a6947b217efb6f3ec3bd3504582" "https://api.digitalocean.com/v2/droplets/3164494"
        let Headers = [
            "Content-Type": "application/json",
            "Authorization": "Bearer "+Account.sharedInstance.Access_Token
        ]
        
        weak var weakSelf = self
        print(BASE_URL+URL_DROPLETS+"/\(Droplet.sharedInstance.ID)/")
        Alamofire.request(.DELETE, BASE_URL+URL_DROPLETS+"/\(Droplet.sharedInstance.ID)/"+URL_ACTIONS, parameters: nil, encoding: .JSON, headers: Headers).responseJSON { response in
            if let _ = weakSelf {
                let dic = response.result.value as! NSDictionary
                print("response=\(dic)")
            }
        }
    }
    
}
