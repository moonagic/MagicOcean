//
//  Account.swift
//  MagicOcean
//
//  Created by Wu Hengmin on 16/6/13.
//  Copyright © 2016年 Wu Hengmin. All rights reserved.
//

import UIKit
import Alamofire

class AccountController: UITableViewController {

    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var emailVerifiedLabel: UILabel!
    @IBOutlet weak var dropletLimitLabel: UILabel!
    @IBOutlet weak var floatingIpLimitLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        getAccountDetial()
    }
    
    @IBAction func LogoutPressed(sender: AnyObject) {
        Account.sharedInstance.logoutUser()
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func getAccountDetial() {
        let Headers = [
            "Content-Type": "application/json",
            "Authorization": "Bearer "+Account.sharedInstance.Access_Token
        ]
        
        weak var weakSelf = self
        Alamofire.request(.GET, BASE_URL+URL_ACCOUNT, parameters: nil, encoding: .URL, headers: Headers).responseJSON { response in
            if let _ = weakSelf {
                let dic = response.result.value as! NSDictionary
                print("response=\(dic)")
                let account:NSDictionary = dic.valueForKey("account") as! NSDictionary
                let droplimit:Int = account.valueForKey("droplet_limit") as! Int
                let floating_ip_limit:Int = account.valueForKey("floating_ip_limit") as! Int
                let email_verified:Int = account.valueForKey("email_verified") as! Int
                let email:String = account.valueForKey("email") as! String
                let status:String = account.valueForKey("status") as! String
                dispatch_async(dispatch_get_main_queue(), { 
                    self.emailLabel.text = "Email: \(email)"
                    self.dropletLimitLabel.text = "Droplimit: \(droplimit)"
                    self.emailVerifiedLabel.text = "Email Verified: \(email_verified)"
                    self.floatingIpLimitLabel.text = "Floating IP Limit: \(floating_ip_limit)"
                    self.statusLabel.text = "Account Status: \(status)"
                })
            }
        }
    }
}
