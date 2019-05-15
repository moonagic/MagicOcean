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
    @IBOutlet weak var dropletLimitLabel: UILabel!
    @IBOutlet weak var floatingIpLimitLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setStatusBarAndNavigationBar(navigation: self.navigationController!)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.emailLabel.text = Account.sharedInstance.Email
        self.dropletLimitLabel.text = "\(Account.sharedInstance.LimitofDroplet)"
        self.floatingIpLimitLabel.text = "\(Account.sharedInstance.LimitofFloatingIP)"
        self.statusLabel.text = "\(Account.sharedInstance.AccountStatus)"
        getAccountDetial()
    }
    
    @IBAction func LogoutPressed(sender: AnyObject) {
        Account.sharedInstance.logoutUser()
//        self.navigationController?.popViewControllerAnimated(true)
        self.dismiss(animated: true) {
            
        }
    }
    
    @IBAction func donePressed(sender: AnyObject) {
        self.dismiss(animated: true) {
            
        }
    }
    
    func getAccountDetial() {
        let Headers = [
            "Content-Type": "application/json",
            "Authorization": "Bearer "+Account.sharedInstance.Access_Token
        ]
        
        weak var weakSelf = self
        Alamofire.request(BASE_URL+URL_ACCOUNT, method: .get, parameters: nil, encoding: URLEncoding.default, headers: Headers).responseJSON { response in
            if let _ = weakSelf {
                let dic = response.result.value as! NSDictionary
                print("response=\(dic)")
                let account:NSDictionary = dic.value(forKey: "account") as! NSDictionary
                Account.sharedInstance.LimitofDroplet = account.value(forKey: "droplet_limit") as! Int
                Account.sharedInstance.LimitofFloatingIP = account.value(forKey: "floating_ip_limit") as! Int
                Account.sharedInstance.EmailVerfied = account.value(forKey: "email_verified") as! Int
                Account.sharedInstance.AccountStatus = account.value(forKey: "status") as! String
                Account.sharedInstance.saveUser()
                DispatchQueue.main.async {
                    self.emailLabel.text = Account.sharedInstance.Email
                    self.dropletLimitLabel.text = "\(Account.sharedInstance.LimitofDroplet)"
                    self.floatingIpLimitLabel.text = "\(Account.sharedInstance.LimitofFloatingIP)"
                    self.statusLabel.text = "\(Account.sharedInstance.AccountStatus)"
                }
                
            }
        }
    }
}
