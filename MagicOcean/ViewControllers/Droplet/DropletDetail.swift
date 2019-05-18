//
//  DropletDetail.swift
//  MagicOcean
//
//  Created by Wu Hengmin on 16/6/13.
//  Copyright © 2016年 Wu Hengmin. All rights reserved.
//

import UIKit
import MBProgressHUD
import SwiftyJSON
import Alamofire

@objc public protocol DropletDelegate {
    func didSeleteDroplet()
}

class DropletDetail: UITableViewController {
    
    var dropletData:DropletTemplate!
    @IBOutlet weak var imageLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var memAndCPULabel: UILabel!
    @IBOutlet weak var diskLabel: UILabel!
    @IBOutlet weak var transferLabel: UILabel!
    @IBOutlet weak var regionLabel: UILabel!
    weak var delegate: DropletDelegate?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        self.title = dropletData.name
        self.imageLabel.text = dropletData.image.distribution
//        self.priceLabel.text = String(format: "$%.2f", Float(dropletData.size.price));
        self.memAndCPULabel.text = "\(dropletData.size.memory)MB / \(dropletData.size.vcpus)vCPU"
        self.transferLabel.text = "Transfer \(dropletData.size.transfer)TB"
        self.regionLabel.text = dropletData.region.slug
        self.diskLabel.text = "\(dropletData.size.disk)GB SSD"

    }

    @IBAction func actionPressed(sender: AnyObject) {
        
        weak var weakSelf = self
        let alertController = UIAlertController(title: "Actions", message: "Choose the action you want.", preferredStyle: .actionSheet)

        // Reboot
        let dateAction = UIAlertAction(title: "Reboot", style: .default) { (action:UIAlertAction!) in
            print("you have pressed the Reboot button");
            weakSelf!.dropletActions(type: "reboot")
        }
        alertController.addAction(dateAction)
        // Power Off
        if dropletData?.status == "off" {
            let powerAction = UIAlertAction(title: "Power On", style: .destructive) { (action:UIAlertAction!) in
                print("you have pressed the Power On button");
                weakSelf!.dropletActions(type: "power_on")
            }
            alertController.addAction(powerAction)
        } else if dropletData?.status == "active" {
            let powerAction = UIAlertAction(title: "Power Off", style: .default) { (action:UIAlertAction!) in
                print("you have pressed the Power Off button");
                weakSelf!.dropletActions(type: "power_off")
            }
            alertController.addAction(powerAction)
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action:UIAlertAction!) in
            print("you have pressed the cancel button");
        }
        alertController.addAction(cancelAction)

        self.present(alertController, animated: true, completion:nil)
    }
    
    func dropletActions(type: String) {
        let Headers = [
            "Content-Type": "application/json",
            "Authorization": "Bearer "+Account.sharedInstance.Access_Token
        ]
        
        let parameters = [
            "type": type
        ]
        let hud:MBProgressHUD = MBProgressHUD.init(view: self.view.window!)
        
        self.view.window?.addSubview(hud)
        hud.mode = MBProgressHUDMode.indeterminate
        hud.show(animated: true)
        hud.removeFromSuperViewOnHide = true
        
        weak var weakSelf = self
        print(BASE_URL+URL_DROPLETS+"/\(dropletData.id)/"+URL_ACTIONS)
        Alamofire.request(BASE_URL+URL_DROPLETS+"/\(dropletData.id)/"+URL_ACTIONS, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: Headers).responseJSON { response in
            if let _ = weakSelf {
                DispatchQueue.main.async {
                    hud.hide(animated: true)
                }
                let dic = response.result.value as! NSDictionary
                print("response=\(dic)")
            }
        }
        
    }
    
    @IBAction func powerCyclePressed(sender: AnyObject) {
        weak var weakSelf = self
        let alertController = UIAlertController(title: "Warnnig", message: "This action will not undo!", preferredStyle: .actionSheet)
        
        let dateAction = UIAlertAction(title: "Power Cycle", style: .destructive) { (action:UIAlertAction!) in
            weakSelf!.dropletActions(type: "power_cycle")
        }
        alertController.addAction(dateAction)
        
        let cancellAction = UIAlertAction(title: "Cancell", style: .cancel) { (action:UIAlertAction!) in
            
        }
        alertController.addAction(cancellAction)
        
        self.present(alertController, animated: true, completion:nil)
    }
    
    @IBAction func deletePressed(sender: AnyObject) {
        weak var weakSelf = self
        let alertController = UIAlertController(title: "Warnnig", message: "This action will not undo!", preferredStyle: .actionSheet)
        
        // Reboot
        let dateAction = UIAlertAction(title: "Delete", style: .destructive) { (action:UIAlertAction!) in
            weakSelf!.deleteDroplet()
        }
        alertController.addAction(dateAction)
        
        
        let cancellAction = UIAlertAction(title: "Cancell", style: .cancel) { (action:UIAlertAction!) in
            
        }
        alertController.addAction(cancellAction)

        
        self.present(alertController, animated: true, completion:nil)
        
    }
    
    func deleteDroplet() {
//        curl -X DELETE -H "Content-Type: application/json" -H "Authorization: Bearer b7d03a6947b217efb6f3ec3bd3504582" "https://api.digitalocean.com/v2/droplets/3164494"
        let Headers = [
            "Content-Type": "application/json",
            "Authorization": "Bearer "+Account.sharedInstance.Access_Token
        ]
        
        let hud:MBProgressHUD = MBProgressHUD(view: self.view.window!)
        self.view.window?.addSubview(hud)
        hud.mode = MBProgressHUDMode.indeterminate
        hud.show(animated: true)
        hud.removeFromSuperViewOnHide = true
        
        weak var weakSelf = self
        Alamofire.request(BASE_URL+URL_DROPLETS+"/\(dropletData.id)/", method: .delete, parameters: nil, encoding: URLEncoding.default, headers: Headers).responseJSON { response in
            DispatchQueue.main.async {
                hud.hide(animated: true)
            }
            if let strongSelf = weakSelf {
                if response.response?.statusCode == 204 {
                    DispatchQueue.main.async {
                        strongSelf.delegate?.didSeleteDroplet()
                        strongSelf.navigationController?.popViewController(animated: true)
                    }
                } else if response.response?.statusCode == 442 {
                    let dic = response.result.value as! NSDictionary
                    print("response=\(dic)")
                    if let message = dic.value(forKey: "message") {
                        makeTextToast(message: message as! String, view: strongSelf.view.window!)
                    }
                }
            }
            
        }
    }
    
}
