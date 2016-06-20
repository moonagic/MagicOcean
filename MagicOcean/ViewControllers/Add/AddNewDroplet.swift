//
//  AddNewDroplet.swift
//  MagicOcean
//
//  Created by Wu Hengmin on 16/6/19.
//  Copyright © 2016年 Wu Hengmin. All rights reserved.
//

import UIKit
import Alamofire

class AddNewDroplet: UITableViewController, UITextFieldDelegate, SelectImageDelegate, SelectSizeDelegate, SelectRegionDelegate, SelectSSHKeyDelegate {

    @IBOutlet weak var hostnameField: UITextField!
    @IBOutlet weak var imageField: UITextField!
    
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var memoryAndCPULabel: UILabel!
    @IBOutlet weak var diskLabel: UILabel!
    @IBOutlet weak var transferLabel: UILabel!
    
    @IBOutlet weak var regionField: UITextField!
    
    @IBOutlet weak var SSHKeyField: UITextField!
    
    @IBOutlet weak var privateNetworkingSwitch: UISwitch!
    @IBOutlet weak var backupsSwitch: UISwitch!
    @IBOutlet weak var ipv6Switch: UISwitch!
    var sizeDic:NSDictionary!
    var imageDic:NSDictionary!
    var regionDic:NSDictionary!
    var sshkeyDic:NSDictionary!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController!.navigationBar.barTintColor = UIColor(red: 0.19, green: 0.56, blue: 0.91, alpha: 1)
        self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        self.navigationController!.navigationBar.barStyle = UIBarStyle.Black
        self.navigationController!.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController!.navigationBar.translucent = false
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    @IBAction func cancellPressed(sender: AnyObject) {
        self.dismissViewControllerAnimated(true) { 
            
        }
    }
    
    @IBAction func savePressed(sender: AnyObject) {
        // 前置判断
        
        
//        curl -X POST -H "Content-Type: application/json" -H "Authorization: Bearer b7d03a6947b217efb6f3ec3bd3504582" -d '{"name":"example.com","region":"nyc3","size":"512mb","image":"ubuntu-14-04-x64","ssh_keys":null,"backups":false,"ipv6":true,"user_data":null,"private_networking":null}' "https://api.digitalocean.com/v2/droplets"
        let Headers = [
            "Content-Type": "application/json",
            "Authorization": "Bearer "+Account.sharedInstance.Access_Token
        ]
        
        let name:String = self.hostnameField.text!
        let size:String = self.sizeDic.valueForKey("slug") as! String
        let image:String = self.imageDic.valueForKey("slug") as! String
        let region:String = self.regionDic.valueForKey("slug") as! String
        var key:Int!
        var keyarr:NSArray = []
        if let _ = self.sshkeyDic {
            key = self.sshkeyDic.valueForKey("id") as! Int
            keyarr = [key]
        }
        
        
        let parameters:[String: AnyObject]? = [
            "name":name,
            "region":region,
            "size":size,
            "image":image,
            "ssh_keys":keyarr,
            "backups":self.backupsSwitch.on,
            "ipv6":self.ipv6Switch.on,
            "user_data":"null",
            "private_networking":self.privateNetworkingSwitch.on
        ]
        
        weak var weakSelf = self
        print(BASE_URL+URL_ACCOUNT+URL_KEYS)
        Alamofire.request(.POST, BASE_URL+URL_DROPLETS, parameters: parameters, encoding: .JSON, headers: Headers).responseJSON { response in
            if let _ = weakSelf {
                let dic = response.result.value as! NSDictionary
                print("response=\(dic)")
                
                
                
//                let arr:NSArray = dic.valueForKey("ssh_keys") as! NSArray
//                if let localArr:NSArray = arr {
//                    
//                    for index in 1...localArr.count {
//                        strongSelf.data.addObject(localArr.objectAtIndex(index-1))
//                    }
//                }
//                dispatch_async(dispatch_get_main_queue(), {
//                    strongSelf.tableView.reloadData()
//                    strongSelf.tableView.mj_header.endRefreshing()
//                })
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "selectimage" {
            let nv:UINavigationController = segue.destinationViewController as! UINavigationController
            let vc:ImageTableView = nv.topViewController as! ImageTableView
            vc.delegate = self
        } else if segue.identifier == "selectsize" {
            let nv:UINavigationController = segue.destinationViewController as! UINavigationController
            let vc:SizeTableView = nv.topViewController as! SizeTableView
            vc.delegate = self
        } else if segue.identifier == "selectregion" {
            let nv:UINavigationController = segue.destinationViewController as! UINavigationController
            let vc:RegionTableView = nv.topViewController as! RegionTableView
            vc.delegate = self
        } else if segue.identifier == "selectkey" {
            let nv:UINavigationController = segue.destinationViewController as! UINavigationController
            let vc:SSHKeyTableView = nv.topViewController as! SSHKeyTableView
            vc.delegate = self
        }
    }
    
    // MARK: - delegate of ImageTableView
    func didSelectImage(slug: NSDictionary) {
        self.imageDic = slug
        weak var weakSelf = self
        dispatch_async(dispatch_get_main_queue()) { 
            weakSelf!.imageField.text = slug.valueForKey("slug") as? String
        }
    }
    
    // MARK: - delegate of SizeTableView
    func didSelectSize(size: NSDictionary) {
        self.sizeDic = size
        weak var weakSelf = self
        dispatch_async(dispatch_get_main_queue()) {
            if let strongSelf = weakSelf {
                
                let memory:Int = size.valueForKey("memory") as! Int
                let price:Float = size.valueForKey("price_monthly") as! Float
                let disk:Int = size.valueForKey("disk") as! Int
                let transfer:Int = size.valueForKey("transfer") as! Int
                let vcpus:Int = size.valueForKey("vcpus") as! Int
                
                strongSelf.priceLabel.text = "$\(String(format: "%.2f", price))"
                strongSelf.memoryAndCPULabel.text = "\(memory)MB / \(vcpus)CPUs"
                strongSelf.diskLabel.text = "\(disk)GB SSD"
                strongSelf.transferLabel.text = "Transfer \(transfer)TB"
                
            }
            
        }
    }
    
    // MARK: - delegate of RegionTableView
    func didSelectRegion(region: NSDictionary) {
        self.regionDic = region
        weak var weakSelf = self
        dispatch_async(dispatch_get_main_queue()) { 
            if let strongSelf = weakSelf {
                strongSelf.regionField.text = region.valueForKey("slug") as? String
            }
        }
    }
    
    // MARK: -delegate of SSHKeyTableView
    func didSelectSSHKey(key: NSDictionary) {
        self.sshkeyDic = key
        weak var weakSelf = self
        dispatch_async(dispatch_get_main_queue()) { 
            if let strongSelf = weakSelf {
                strongSelf.SSHKeyField.text = key.valueForKey("name") as? String
            }
        }
    }
    
}
