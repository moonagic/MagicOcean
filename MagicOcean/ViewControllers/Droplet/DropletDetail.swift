//
//  DropletDetail.swift
//  MagicOcean
//
//  Created by Wu Hengmin on 16/6/13.
//  Copyright © 2016年 Wu Hengmin. All rights reserved.
//

import UIKit
import Alamofire
import MBProgressHUD
import SwiftyJSON

@objc public protocol DropletDelegate {
    func didSeleteDroplet()
}

struct DropletTeplete {
    var name:String
    var imageSlug:String
    var regionSlug:String
    var price:Int
    var memory:Int
    var vcpus:Int
    var transfer:Int
    var disk:Int
    var status:String
}

class DropletDetail: UITableViewController {
    
    var dropletData:DropletTeplete?
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
        self.title = Droplet.sharedInstance.Name
        
//        if let result:NSData = UserDefaults().object(forKey: "droplet\(Droplet.sharedInstance.ID)") as? NSData {
//
//            self.droplet = NSKeyedUnarchiver.unarchiveObject(with: result as Data) as? NSDictionary
//
//            self.title = droplet.value(forKey: "name") as? String
//
//            self.imageLabel.text = (droplet.value(forKey: "image")? as AnyObject).value("slug") as? String
//
//            let price:Float = (droplet.value(forKey: "size")? as AnyObject).value("price_monthly") as! Float
//            self.priceLabel.text = String(format: "$%.2f", price);
//
//            let memory:Int = (droplet.value(forKey: "size")? as AnyObject).valueForKey("memory") as! Int
//            let cpu:Int = (droplet.value(forKey: "size")? as AnyObject).valueForKey("vcpus") as! Int
//            self.memAndCPULabel.text = "\(memory)MB / \(cpu)CPUs"
//
//            let transfer:Int = (droplet.valueForKey("size")? as AnyObject).valueForKey("transfer") as! Int
//            self.transferLabel.text = "Transfer \(transfer)TB"
//
//            let region:String = droplet.valueForKey("region")?.valueForKey("slug") as! String
//            self.regionLabel.text = region
//
//            let disk:Int = droplet.valueForKey("size")?.valueForKey("disk") as! Int
//            self.diskLabel.text = "\(disk)GB SSD"
//
//        }
        
        loadDropletDetail()
    }
    
    func loadDropletDetail() {
//        curl -X GET -H "Content-Type: application/json" -H "Authorization: Bearer b7d03a6947b217efb6f3ec3bd3504582" "https://api.digitalocean.com/v2/droplets/3164494"
        
        let Headers = [
            "Content-Type": "application/json",
            "Authorization": "Bearer "+Account.sharedInstance.Access_Token
        ]
        
        weak var weakSelf = self
        Alamofire.request(BASE_URL+URL_DROPLETS+"/\(Droplet.sharedInstance.ID)", method: .get, parameters: nil, encoding: URLEncoding.default, headers: Headers).responseJSON { response in
            
            if let strongSelf = weakSelf {
                if let JSONObj = response.result.value {
                    let dic = JSONObj as! NSDictionary
                    let jsonString = dictionary2JsonString(dic: dic as! Dictionary<String, Any>)
                    print(jsonString)
                    if let dataFromString = jsonString.data(using: .utf8, allowLossyConversion: false) {
                        if let json = try? JSON(data: dataFromString) {
                            strongSelf.dropletData = DropletTeplete(name: json["droplet"]["name"].string ?? "", imageSlug: json["droplet"]["image"]["slug"].string ?? "unknow image", regionSlug: json["droplet"]["region"]["slug"].string ?? "", price: json["droplet"]["size"]["price_monthly"].int ?? 0, memory: json["droplet"]["size"]["memory"].int ?? 0, vcpus: json["droplet"]["size"]["vcpus"].int ?? 0, transfer: json["droplet"]["size"]["transfer"].int ?? 0, disk: json["droplet"]["size"]["disk"].int ?? 0, status: json["droplet"]["status"].string ?? "")
                            DispatchQueue.main.async {
                                if let dd = strongSelf.dropletData {
                                    strongSelf.title = dd.name
                                    strongSelf.imageLabel.text = dd.imageSlug
                                    strongSelf.priceLabel.text = String(format: "$%.2f", Float(dd.price));
                                    strongSelf.memAndCPULabel.text = "\(dd.memory)MB / \(dd.vcpus)CPUs"
                                    strongSelf.transferLabel.text = "Transfer \(dd.transfer)TB"
                                    strongSelf.regionLabel.text = dd.regionSlug
                                    strongSelf.diskLabel.text = "\(dd.disk)GB SSD"
                                }
                            }
                        }
                    }
                }
            }
        }
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
        print(BASE_URL+URL_DROPLETS+"/\(Droplet.sharedInstance.ID)/"+URL_ACTIONS)
        Alamofire.request(BASE_URL+URL_DROPLETS+"/\(Droplet.sharedInstance.ID)/"+URL_ACTIONS, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: Headers).responseJSON { response in
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
        Alamofire.request(BASE_URL+URL_DROPLETS+"/\(Droplet.sharedInstance.ID)/", method: .delete, parameters: nil, encoding: URLEncoding.default, headers: Headers).responseJSON { response in
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
