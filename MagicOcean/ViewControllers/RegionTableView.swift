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

@objc public protocol SelectRegionDelegate {
    func didSelectRegion(region: NSDictionary)
}

class RegionTableView: UITableViewController {
    
    var data:NSMutableArray = []
    weak var delegate: SelectRegionDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController!.navigationBar.barTintColor = UIColor(red: 0.19, green: 0.56, blue: 0.91, alpha: 1)
        self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        self.navigationController!.navigationBar.barStyle = UIBarStyle.Black
        self.navigationController!.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController!.navigationBar.translucent = false
        
        tableView.tableFooterView = UIView.init(frame: CGRectZero)
        
        setupMJRefresh()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if let result:NSData = NSUserDefaults().objectForKey("regions") as? NSData {
            
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
        self.loadRegions(1, per_page: 10)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.data.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let identifier:String = "regioncell"
        let cell:RegionCell = tableView.dequeueReusableCellWithIdentifier(identifier) as! RegionCell
        
        let dic = self.data.objectAtIndex(indexPath.row)
        
        let name:String = dic.valueForKey("name") as! String
        
        cell.titleLabel.text = "\(name)"
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let dic = self.data.objectAtIndex(indexPath.row)
        self.delegate?.didSelectRegion(dic as! NSDictionary)
        self.dismissViewControllerAnimated(true) { 
            
        }
    }
    
    @IBAction func cancellPressed(sender: AnyObject) {
        self.dismissViewControllerAnimated(true) {
            
        }
    }
    
    func loadRegions(page: Int, per_page: Int) {
        //        curl -X GET -H "Content-Type: application/json" -H "Authorization: Bearer b7d03a6947b217efb6f3ec3bd3504582" "https://api.digitalocean.com/v2/images?page=1&per_page=1"
        let Headers = [
            "Content-Type": "application/json",
            "Authorization": "Bearer "+Account.sharedInstance.Access_Token
        ]
        
        weak var weakSelf = self
        
        Alamofire.request(.GET, BASE_URL+URL_REGIONS+"?page=\(page)&per_page=\(per_page)", parameters: nil, encoding: .JSON, headers: Headers).responseJSON { response in
            if let strongSelf = weakSelf {
                let dic = response.result.value as! NSDictionary
                print("response=\(dic)")
                if page == 0 {
                    strongSelf.data.removeAllObjects()
                }
                let arr:NSArray = dic.valueForKey("regions") as! NSArray
                if let localArr:NSArray = arr {
                    
                    for index in 1...localArr.count {
                        strongSelf.data.addObject(localArr.objectAtIndex(index-1))
                    }
                    let nsData:NSData = NSKeyedArchiver.archivedDataWithRootObject(strongSelf.data)
                    NSUserDefaults().setObject(nsData, forKey: "regions")
                }
                dispatch_async(dispatch_get_main_queue(), {
                    strongSelf.tableView.reloadData()
                    strongSelf.tableView.mj_header.endRefreshing()
                })
            }
        }
    }
}
