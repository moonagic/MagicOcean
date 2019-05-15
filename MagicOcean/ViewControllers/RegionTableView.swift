//
//  RegionTableView.swift
//  MagicOcean
//
//  Created by Wu Hengmin on 16/6/19.
//  Copyright © 2016年 Wu Hengmin. All rights reserved.
//

import UIKit
import Alamofire
import MJRefresh
import SwiftyJSON

struct RegionTeplete {
    var name:String
    var slug:String
}


protocol SelectRegionDelegate {
    func didSelectRegion(region: RegionTeplete)
}

class RegionTableView: UITableViewController {
    
    var data:NSMutableArray = []
    var regionData:[RegionTeplete] = Array<RegionTeplete>()
    var delegate: SelectRegionDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        setStatusBarAndNavigationBar(navigation: self.navigationController!)
        
        tableView.tableFooterView = UIView.init(frame: CGRect.zero)
        
        setupMJRefresh()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let result:NSData = UserDefaults().object(forKey: "regions") as? NSData {
            
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
        self.loadRegions(page: 1, per_page: 10)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.regionData.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier:String = "regioncell"
        let cell:RegionCell = tableView.dequeueReusableCell(withIdentifier: identifier) as! RegionCell
        
        let region = regionData[indexPath.row]
//
//        let name:String = (dic as AnyObject).valueForKey("name") as! String
//
//        cell.titleLabel.text = "\(name)"
        cell.titleLabel.text = region.name
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let region = regionData[indexPath.row]
        self.delegate?.didSelectRegion(region: region)
        self.dismiss(animated: true) {
            
        }
    }
    
    @IBAction func cancellPressed(sender: AnyObject) {
        self.dismiss(animated: true) {
            
        }
    }
    
    func loadRegions(page: Int, per_page: Int) {
        //        curl -X GET -H "Content-Type: application/json" -H "Authorization: Bearer b7d03a6947b217efb6f3ec3bd3504582" "https://api.digitalocean.com/v2/images?page=1&per_page=1"
        let Headers = [
            "Content-Type": "application/json",
            "Authorization": "Bearer "+Account.sharedInstance.Access_Token
        ]
        
        weak var weakSelf = self
        
        Alamofire.request(BASE_URL+URL_REGIONS+"?page=\(page)&per_page=\(per_page)", method: .get, parameters: nil, encoding: URLEncoding.default, headers: Headers).responseJSON { response in
//            if let strongSelf = weakSelf {
//                let dic = response.result.value as! NSDictionary
//                print("response=\(dic)")
//                if page == 1 {
//                    strongSelf.data.removeAllObjects()
//                }
//                let arr:NSArray = dic.valueForKey("regions") as! NSArray
//                if let localArr:NSArray = arr {
//
//                    for index in 1...localArr.count {
//                        strongSelf.data.addObject(localArr.objectAtIndex(index-1))
//                    }
//                    let nsData:NSData = NSKeyedArchiver.archivedDataWithRootObject(strongSelf.data)
//                    NSUserDefaults().setObject(nsData, forKey: "regions")
//                }
//                dispatch_async(dispatch_get_main_queue(), {
//                    strongSelf.tableView.reloadData()
//                    strongSelf.tableView.mj_header.endRefreshing()
//                })
//            }
            if let strongSelf = weakSelf {
                
                if let JSONObj = response.result.value {
                    let dic = JSONObj as! NSDictionary
                    let jsonString = dictionary2JsonString(dic: dic as! Dictionary<String, Any>)
                    print(jsonString)
                    if let dataFromString = jsonString.data(using: .utf8, allowLossyConversion: false) {
                        if let json = try? JSON(data: dataFromString) {
                            if let region = json["regions"].array {
                                for r in region {
                                    self.regionData.append(RegionTeplete(name: r["name"].string!, slug: r["slug"].string!))
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
