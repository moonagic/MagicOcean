//
//  AddNewSSHKey.swift
//  MagicOcean
//
//  Created by Wu Hengmin on 16/6/19.
//  Copyright © 2016年 Wu Hengmin. All rights reserved.
//

import UIKit
import Alamofire
import MBProgressHUD
import SwiftyJSON
import UITextView_Placeholder

class AddNewSSHKey: UITableViewController, UITextFieldDelegate {
    
    @IBOutlet weak var nameLabel: UITextField!
    @IBOutlet weak var SSHKeyText: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setStatusBarAndNavigationBar(navigation: self.navigationController!)
        
        self.nameLabel.delegate = self
        self.nameLabel.becomeFirstResponder()
        self.SSHKeyText.placeholder = "INPUT PUBLIC KEY"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func cancellPressed(sender: AnyObject) {
        self.dismiss(animated: true) {
            
        }
    }
    
    @IBAction func savePressed(sender: AnyObject) {
//        curl -X POST -H "Content-Type: application/json" -H "Authorization: Bearer b7d03a6947b217efb6f3ec3bd3504582" -d '{"name":"My SSH Public Key","public_key":"ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAAAQQDDHr/jh2Jy4yALcK4JyWbVkPRaWmhck3IgCoeOO3z1e2dBowLh64QAM+Qb72pxekALga2oi4GvT+TlWNhzPH4V example"}' "https://api.digitalocean.com/v2/account/keys"
        
        let Headers = [
            "Content-Type": "application/json",
            "Authorization": "Bearer "+Account.sharedInstance.Access_Token
        ]
        
        let parameters:Parameters = [
            "name": self.nameLabel.text!,
            "public_key": self.SSHKeyText.text!
        ]
        
        
        
        let hud:MBProgressHUD = MBProgressHUD.init(view: self.view.window!)
        self.view.window?.addSubview(hud)
        hud.mode = MBProgressHUDMode.indeterminate
        hud.show(animated: true)
        hud.removeFromSuperViewOnHide = true
        
        weak var weakSelf = self
        Alamofire.request(BASE_URL+URL_ACCOUNT+"/"+URL_KEYS, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: Headers).responseJSON { response in
            DispatchQueue.main.async {
                hud.hide(animated: true)
            }
            
            if let strongSelf = weakSelf {
                if let JSONObj = response.result.value {
                    let dic = JSONObj as! NSDictionary
                    let jsonString = dictionary2JsonString(dic: dic as! Dictionary<String, Any>)
                    print("jsonString", jsonString)
                    if let dataFromString = jsonString.data(using: .utf8, allowLossyConversion: false) {
                        if let json = try? JSON(data: dataFromString) {
                            if let message = json["message"].string {
                                makeTextToast(message: message, view: self.view)
                            } else {
                                DispatchQueue.main.async {
                                    strongSelf.dismiss(animated: true, completion: {
                                        
                                    })
                                }
                            }
                        }
                    }
                }
            }
        }
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.isEqual(self.nameLabel) {
            textField.resignFirstResponder()
            self.SSHKeyText.becomeFirstResponder()
        }
        
        return true
    }
    
}
