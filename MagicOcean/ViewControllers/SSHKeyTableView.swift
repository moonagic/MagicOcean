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
import MBProgressHUD
import SwiftyJSON

struct SSHKeyTeplete {
    var name:String
    var id:Int
    var fingerprint:String
    var public_key:String
}
protocol SelectSSHKeyDelegate {
    func didSelectSSHKey(key: SSHKeyTeplete)
}

class SSHKeyTableView: UITableViewController {
    
    var SSHKeydata:[SSHKeyTeplete] = Array<SSHKeyTeplete>()
    var delegate: SelectSSHKeyDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        setStatusBarAndNavigationBar(navigation: self.navigationController!)
        
        tableView.tableFooterView = UIView.init(frame: CGRect.zero)
        
        setupMJRefresh()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        if let result:NSData = UserDefaults().object(forKey: "keys") as? NSData {
        
//            self.data = NSKeyedUnarchiver.unarchiveObject(with: result as Data) as! NSMutableArray
//        } else {
            self.tableView.mj_header.beginRefreshing()
//        }
    }
    
    func setupMJRefresh() {
        let header = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction:#selector(mjRefreshData))
        header?.isAutomaticallyChangeAlpha = true;
        
        header?.lastUpdatedTimeLabel.isHidden = true;
        self.tableView.mj_header = header;
        
    }
    
    @objc func mjRefreshData() {
        SSHKeydata.removeAll()
        self.loadSSHKeys()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return SSHKeydata.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier:String = "sshkeycell"
        let cell:SSHKeyCell = tableView.dequeueReusableCell(withIdentifier: identifier) as! SSHKeyCell
        
//        let dic = self.data.objectAtIndex(indexPath.row)
//
//        let name:String = dic.valueForKey("name") as! String
//
//        cell.titleLabel.text = "\(name)"
        
        let key = SSHKeydata[indexPath.row]
        cell.titleLabel.text = key.name
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let key = SSHKeydata[indexPath.row]
        self.delegate?.didSelectSSHKey(key: key)
        self.dismiss(animated: true) {
            
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
            if editingStyle == UITableViewCell.EditingStyle.delete {
                // delete key
                let key = SSHKeydata[indexPath.row]
                deleteKey(key: key.id)
            }
    }
    
    @IBAction func cancellPressed(sender: AnyObject) {
        self.dismiss(animated: true) {
            
        }
    }
    
    func loadSSHKeys() {
        //        curl -X GET -H "Content-Type: application/json" -H "Authorization: Bearer b7d03a6947b217efb6f3ec3bd3504582" "https://api.digitalocean.com/v2/account/keys"
        let Headers = [
            "Content-Type": "application/json",
            "Authorization": "Bearer "+Account.sharedInstance.Access_Token
        ]
        
//        let hud:MBProgressHUD = MBProgressHUD.init(view: self.view.window!)
//        self.view.window?.addSubview(hud)
//        hud.mode = MBProgressHUDMode.indeterminate
//        hud.show(animated: true)
//        hud.removeFromSuperViewOnHide = true
        weak var weakSelf = self
        Alamofire.request(BASE_URL+URL_ACCOUNT+"/"+URL_KEYS, method: .get, parameters: nil, encoding: URLEncoding.default, headers: Headers).responseJSON { response in
            
            if let strongSelf = weakSelf {
                
                if let JSONObj = response.result.value {
                    let dic = JSONObj as! NSDictionary
                    let jsonString = dictionary2JsonString(dic: dic as! Dictionary<String, Any>)
                    print(jsonString)
                    if let dataFromString = jsonString.data(using: .utf8, allowLossyConversion: false) {
                        if let json = try? JSON(data: dataFromString) {
                            if let keys = json["ssh_keys"].array {
                                for k in keys {
                                    self.SSHKeydata.append(SSHKeyTeplete(name: k["name"].string!, id: k["id"].int!, fingerprint: k["fingerprint"].string!, public_key: k["public_key"].string!))
                                }
                            }
                        }
                    }
                }
                DispatchQueue.main.async {
                    strongSelf.tableView.reloadData()
                    strongSelf.tableView.mj_header.endRefreshing()
                }
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
        
        Alamofire.request(BASE_URL+URL_ACCOUNT+"/"+URL_KEYS+"/\(key)", method: .delete, parameters: nil, encoding: URLEncoding.default, headers: Headers).responseJSON { response in
            if let strongSelf = weakSelf {
                if response.result.isSuccess {
                    strongSelf.SSHKeydata.removeAll()
                    strongSelf.loadSSHKeys()
                }
            }
        }
    }
    
}
