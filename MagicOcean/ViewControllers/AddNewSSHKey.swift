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

class AddNewSSHKey: UITableViewController, UITextFieldDelegate {
    
    @IBOutlet weak var nameLabel: UITextField!
    @IBOutlet weak var SSHKeyText: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setStatusBarAndNavigationBar(self.navigationController!)
        
        self.nameLabel.delegate = self
        self.nameLabel.becomeFirstResponder()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func cancellPressed(sender: AnyObject) {
        self.dismissViewControllerAnimated(true) {
            
        }
    }
    
    @IBAction func savePressed(sender: AnyObject) {
//        curl -X POST -H "Content-Type: application/json" -H "Authorization: Bearer b7d03a6947b217efb6f3ec3bd3504582" -d '{"name":"My SSH Public Key","public_key":"ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAAAQQDDHr/jh2Jy4yALcK4JyWbVkPRaWmhck3IgCoeOO3z1e2dBowLh64QAM+Qb72pxekALga2oi4GvT+TlWNhzPH4V example"}' "https://api.digitalocean.com/v2/account/keys"
        
        let Headers = [
            "Content-Type": "application/json",
            "Authorization": "Bearer "+Account.sharedInstance.Access_Token
        ]
        
        let parameters = [
            "name":self.nameLabel.text,
            "public_key":self.SSHKeyText.text
        ]
        
        let hud:MBProgressHUD = MBProgressHUD(window: self.view.window)
        self.view.window?.addSubview(hud)
        hud.mode = MBProgressHUDMode.Indeterminate
        hud.show(true)
        hud.removeFromSuperViewOnHide = true
        
        weak var weakSelf = self
        Alamofire.request(.POST, BASE_URL+URL_ACCOUNT+"/"+URL_KEYS, parameters: parameters, encoding: .JSON, headers: Headers).responseJSON { response in
            dispatch_async(dispatch_get_main_queue(), { 
                hud.hide(true)
            })
            if let strongSelf = weakSelf {
                let dic = response.result.value as! NSDictionary
                print("response=\(dic)")
                
                if let message = dic.valueForKey("message") {
                    makeTextToast(message as! String, view: strongSelf.view)
                } else {
                    strongSelf.dismissViewControllerAnimated(true, completion: {
                        
                    })
                }
            }
        }
        
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField.isEqual(self.nameLabel) {
            textField.resignFirstResponder()
            self.SSHKeyText.becomeFirstResponder()
        }
        
        return true
    }
    
}
