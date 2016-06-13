//
//  DropletDetail.swift
//  MagicOcean
//
//  Created by Wu Hengmin on 16/6/13.
//  Copyright © 2016年 Wu Hengmin. All rights reserved.
//

import UIKit
import Alamofire

class DropletDetail: UITableViewController {
    
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
                dispatch_async(dispatch_get_main_queue(), {
                    self.title = droplet.valueForKey("name") as? String
                })
            }
        }
    }

    @IBAction func actionPressed(sender: AnyObject) {
        let alertController = UIAlertController(title: "", message: "", preferredStyle: .ActionSheet)
        
        // Reboot
        let dateAction = UIAlertAction(title: "Reboot", style: .Default) { (action:UIAlertAction!) in
            print("you have pressed the Reboot button");
        }
        alertController.addAction(dateAction)
        // Power Off
        let iOSAction = UIAlertAction(title: "Power Off", style: .Default) { (action:UIAlertAction!) in
            print("you have pressed the Power Off button");
        }
        alertController.addAction(iOSAction)
        // Power Cycle
        let androidAction = UIAlertAction(title: "Power Cycle", style: .Default) { (action:UIAlertAction!) in
            print("you have pressed the Power Cycle button");
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
    
}
