//
//  SSHKeyTableView.swift
//  MagicOcean
//
//  Created by Wu Hengmin on 16/6/19.
//  Copyright © 2016年 Wu Hengmin. All rights reserved.
//

import UIKit
import Alamofire
import MJRefresh

@objc public protocol SelectSSHKeyDelegate {
    func didSelectSSHKey(key: NSDictionary)
}

class SSHKeyTableView: UITableViewController {
    
    var data:NSMutableArray = []
    weak var delegate: SelectSSHKeyDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        setStatusBarAndNavigationBar(self.navigationController!)
        
        tableView.tableFooterView = UIView.init(frame: CGRectZero)
        
        setupMJRefresh()
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if let result:NSData = NSUserDefaults().objectForKey("keys") as? NSData {
            
            self.data = NSKeyedUnarchiver.unarchiveObjectWithData(result) as! NSMutableArray
        } else {
            self.tableView.mj_header.beginRefreshing()
        }
    }
    
    func setupMJRefresh() {
        let header = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction:#selector(mjRefreshData))
        header.automaticallyChangeAlpha = true;
        
        header.lastUpdatedTimeLabel.hidden = true;
        self.tableView.mj_header = header;
        
    }
    
    func mjRefreshData() {
        self.loadSSHKeys()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.data.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let identifier:String = "sshkeycell"
        let cell:SSHKeyCell = tableView.dequeueReusableCellWithIdentifier(identifier) as! SSHKeyCell
        
        let dic = self.data.objectAtIndex(indexPath.row)
        
        let name:String = dic.valueForKey("name") as! String
        
        cell.titleLabel.text = "\(name)"
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let key = self.data.objectAtIndex(indexPath.row)
        self.delegate?.didSelectSSHKey(key as! NSDictionary)
        self.dismissViewControllerAnimated(true) { 
            
        }
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            // delete key
            let dic = self.data.objectAtIndex(indexPath.row)
            self.deleteKey(dic.valueForKey("id") as! Int)
        }
    }
    
    @IBAction func cancellPressed(sender: AnyObject) {
        self.dismissViewControllerAnimated(true) {
            
        }
    }
    
    func loadSSHKeys() {
        //        curl -X GET -H "Content-Type: application/json" -H "Authorization: Bearer b7d03a6947b217efb6f3ec3bd3504582" "https://api.digitalocean.com/v2/account/keys"
        let Headers = [
            "Content-Type": "application/json",
            "Authorization": "Bearer "+Account.sharedInstance.Access_Token
        ]
        
        weak var weakSelf = self
        
        Alamofire.request(.GET, BASE_URL+URL_ACCOUNT+"/"+URL_KEYS, parameters: nil, encoding: .JSON, headers: Headers).responseJSON { response in
            if let strongSelf = weakSelf {
                let dic = response.result.value as! NSDictionary
                print("response=\(dic)")
                
                let arr:NSArray = dic.valueForKey("ssh_keys") as! NSArray
                strongSelf.data.removeAllObjects()
                if let localArr:NSArray = arr {
                    if localArr.count > 0 {
                        for index in 1...localArr.count {
                            strongSelf.data.addObject(localArr.objectAtIndex(index-1))
                        }
                    }
                    let nsData:NSData = NSKeyedArchiver.archivedDataWithRootObject(strongSelf.data)
                    NSUserDefaults().setObject(nsData, forKey: "keys")
                }
                dispatch_async(dispatch_get_main_queue(), {
                    strongSelf.tableView.reloadData()
                    strongSelf.tableView.mj_header.endRefreshing()
                })
            }
        }
    }
    
    func deleteKey(key: Int) {
//        curl -X DELETE -H "Content-Type: application/json" -H "Authorization: Bearer b7d03a6947b217efb6f3ec3bd3504582" "https://api.digitalocean.com/v2/account/keys/512190"
        let Headers = [
            "Content-Type": "application/json",
            "Authorization": "Bearer "+Account.sharedInstance.Access_Token
        ]
        
        weak var weakSelf = self
        
        Alamofire.request(.DELETE, BASE_URL+URL_ACCOUNT+"/"+URL_KEYS+"/\(key)", parameters: nil, encoding: .JSON, headers: Headers).responseJSON { response in
            if let strongSelf = weakSelf {
                if response.result.isSuccess {
                    strongSelf.loadSSHKeys()
                }
            }
        }
    }
    
}
