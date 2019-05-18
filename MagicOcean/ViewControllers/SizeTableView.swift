//
//  SizeTableView.swift
//  MagicOcean
//
//  Created by Wu Hengmin on 16/6/19.
//  Copyright © 2016年 Wu Hengmin. All rights reserved.
//

import UIKit
import MJRefresh
import Alamofire
import SwiftyJSON

struct SizeTeplete {
    var memory:Int
    var price:Int
    var disk:Int
    var transfer:Int
    var vcpus:Int
    var slug:String
}


protocol SelectSizeDelegate {
    func didSelectSize(size: SizeTeplete)
}

class SizeTableView: UITableViewController {
    
    var data:NSMutableArray = []
    var sizeData:[SizeTeplete] = Array<SizeTeplete>()
    var delegate: SelectSizeDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setStatusBarAndNavigationBar(navigation: self.navigationController!)
        
        tableView.tableFooterView = UIView.init(frame: CGRect.zero)
        
        setupMJRefresh()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let result:NSData = UserDefaults().object(forKey: "sizes") as? NSData {
            
            self.data = NSKeyedUnarchiver.unarchiveObject(with: result as Data) as! NSMutableArray
        } else {
            self.tableView.mj_header.beginRefreshing()
        }
    }
    
    func setupMJRefresh() {
        let header = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction:#selector(mjRefreshData))
        header?.isAutomaticallyChangeAlpha = true;
        
        header?.lastUpdatedTimeLabel.isHidden = true;
        self.tableView.mj_header = header;
        
    }
    
    @objc func mjRefreshData() {
        self.loadSizes(page: 1, per_page: 100)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 91
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sizeData.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier:String = "sizecell"
        let cell:SizeCell = tableView.dequeueReusableCell(withIdentifier: identifier) as! SizeCell
        
        let size = sizeData[indexPath.row]
//        cell.priceLabel.text = "$\(String(format: "%.2f", Float(size.price)))"
        cell.memoryAndCPUsLabel.text = "\(size.memory)MB / \(size.vcpus)CPUs"
        cell.diskLabel.text = "\(size.disk)GB SSD"
        cell.transferLabel.text = "Transfer \(size.transfer)TB"
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let size = sizeData[indexPath.row]
        self.delegate?.didSelectSize(size: size)
        self.dismiss(animated: true) {
            
        }
    }
    
    @IBAction func cancellPressed(sender: AnyObject) {
        self.dismiss(animated: true) {
            
        }
    }
    
    func loadSizes(page: Int, per_page: Int) {
        //        curl -X GET -H "Content-Type: application/json" -H "Authorization: Bearer b7d03a6947b217efb6f3ec3bd3504582" "https://api.digitalocean.com/v2/images?page=1&per_page=1"
        let Headers = [
            "Content-Type": "application/json",
            "Authorization": "Bearer "+Account.sharedInstance.Access_Token
        ]
        
        weak var weakSelf = self
        
        Alamofire.request(BASE_URL+URL_SIZES+"?page=\(page)&per_page=\(per_page)", method: .get
            , parameters: nil, encoding: URLEncoding.default, headers: Headers).responseJSON { response in
            if let strongSelf = weakSelf {
                
                if let JSONObj = response.result.value {
                    let dic = JSONObj as! NSDictionary
                    let jsonString = dictionary2JsonString(dic: dic as! Dictionary<String, Any>)
                    print(jsonString)
                    if let dataFromString = jsonString.data(using: .utf8, allowLossyConversion: false) {
                        if let json = try? JSON(data: dataFromString) {
                            if let sizes = json["sizes"].array {
                                for s in sizes {
                                    strongSelf.sizeData.append(SizeTeplete(memory: s["memory"].int!, price: s["price_monthly"].int!, disk: s["disk"].int!, transfer: s["transfer"].int!, vcpus: s["vcpus"].int!, slug: s["slug"].string!))
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
}
