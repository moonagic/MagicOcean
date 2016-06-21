//
//  AddNewDroplet.swift
//  MagicOcean
//
//  Created by Wu Hengmin on 16/6/19.
//  Copyright © 2016年 Wu Hengmin. All rights reserved.
//

import UIKit
import Alamofire
import MBProgressHUD

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
        setStatusBarAndNavigationBar(self.navigationController!)
        
        self.hostnameField.delegate = self
        
        if let result:NSData = NSUserDefaults().objectForKey("sizes") as? NSData {
            let sizes:NSMutableArray = NSKeyedUnarchiver.unarchiveObjectWithData(result) as! NSMutableArray
            self.sizeDic = sizes[0] as! NSDictionary
            let memory:Int = self.sizeDic.valueForKey("memory") as! Int
            let price:Float = self.sizeDic.valueForKey("price_monthly") as! Float
            let disk:Int = self.sizeDic.valueForKey("disk") as! Int
            let transfer:Int = self.sizeDic.valueForKey("transfer") as! Int
            let vcpus:Int = self.sizeDic.valueForKey("vcpus") as! Int
            
            self.priceLabel.text = "$\(String(format: "%.2f", price))"
            self.memoryAndCPULabel.text = "\(memory)MB / \(vcpus)CPUs"
            self.diskLabel.text = "\(disk)GB SSD"
            self.transferLabel.text = "Transfer \(transfer)TB"
        } else {
            self.priceLabel.text = "$ 0.00"
            self.memoryAndCPULabel.text = "0MB / 0CPUs"
            self.diskLabel.text = "0GB SSD"
            self.transferLabel.text = "Transfer 0TB"
        }
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
        
        if self.hostnameField.text == "" {
            makeTextToast("Hostname can not be blank!", view: self.view.window!)
            return
        }
        if self.sizeDic == nil {
            makeTextToast("You must select size!", view: self.view.window!)
            return
        }
        if self.imageDic == nil {
            makeTextToast("You must select image!", view: self.view.window!)
            return
        }
        if self.regionDic == nil {
            makeTextToast("You must select region!", view: self.view.window!)
            return
        }
        
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
            if let strongSelf = weakSelf {
                let dic = response.result.value as! NSDictionary
                print("response=\(dic)")
                dispatch_async(dispatch_get_main_queue(), { 
                    if let message = dic.valueForKey("message") {
                        print(message)
                        makeTextToast(message as! String, view: strongSelf.view.window!)
                    } else {
                        strongSelf.dismissViewControllerAnimated(true, completion: {
                            
                        })
                    }
                })
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
    
    // MARK: - delegate of SSHKeyTableView
    func didSelectSSHKey(key: NSDictionary) {
        self.sshkeyDic = key
        weak var weakSelf = self
        dispatch_async(dispatch_get_main_queue()) { 
            if let strongSelf = weakSelf {
                strongSelf.SSHKeyField.text = key.valueForKey("name") as? String
            }
        }
    }
    
    // MARK: - delegate of UITextField
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if string.characters.count == 0 {
            return true
        }
        let nStr:NSString = NSString(format: "\(string)")
        
        let uchar:unichar = nStr.characterAtIndex(0)
        
        if uchar >= NSString(format: "a").characterAtIndex(0) && uchar <= NSString(format: "z").characterAtIndex(0) {
            return true
        }
        if uchar >= NSString(format: "A").characterAtIndex(0) && uchar <= NSString(format: "Z").characterAtIndex(0) {
            return true
        }
        if uchar >= NSString(format: "1").characterAtIndex(0) && uchar <= NSString(format: "0").characterAtIndex(0) {
            return true
        }
        if uchar == NSString(format: "-").characterAtIndex(0) {
            return true
        }
        
        return false
    }
    
}
