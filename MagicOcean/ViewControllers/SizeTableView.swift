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

@objc public protocol SelectSizeDelegate {
    func didSelectSize(size: NSDictionary)
}

class SizeTableView: UITableViewController {
    
    var data:NSMutableArray = []
    weak var delegate: SelectSizeDelegate?
    
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
        self.tableView.mj_header.beginRefreshing()
    }
    
    func setupMJRefresh() {
        let header = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction:#selector(mjRefreshData))
        header.automaticallyChangeAlpha = true;
        
        header.lastUpdatedTimeLabel.hidden = true;
        self.tableView.mj_header = header;
        
    }
    
    func mjRefreshData() {
        self.loadSizes(1, per_page: 10)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 91
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.data.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let identifier:String = "sizecell"
        let cell:SizeCell = tableView.dequeueReusableCellWithIdentifier(identifier) as! SizeCell
        
        let dic = self.data.objectAtIndex(indexPath.row)
        
        let memory:Int = dic.valueForKey("memory") as! Int
        let price:Float = dic.valueForKey("price_monthly") as! Float
        let disk:Int = dic.valueForKey("disk") as! Int
        let transfer:Int = dic.valueForKey("transfer") as! Int
        let vcpus:Int = dic.valueForKey("vcpus") as! Int
        
        
        cell.priceLabel.text = "$\(String(format: "%.2f", price))"
        cell.memoryAndCPUsLabel.text = "\(memory)MB / \(vcpus)CPUs"
        cell.diskLabel.text = "\(disk)GB SSD"
        cell.transferLabel.text = "Transfer \(transfer)TB"
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let size:NSDictionary = self.data.objectAtIndex(indexPath.row) as! NSDictionary
        self.delegate?.didSelectSize(size)
        self.dismissViewControllerAnimated(true) { 
            
        }
    }
    
    @IBAction func cancellPressed(sender: AnyObject) {
        self.dismissViewControllerAnimated(true) {
            
        }
    }
    
    func loadSizes(page: Int, per_page: Int) {
        //        curl -X GET -H "Content-Type: application/json" -H "Authorization: Bearer b7d03a6947b217efb6f3ec3bd3504582" "https://api.digitalocean.com/v2/images?page=1&per_page=1"
        let Headers = [
            "Content-Type": "application/json",
            "Authorization": "Bearer "+Account.sharedInstance.Access_Token
        ]
        
        weak var weakSelf = self
        
        Alamofire.request(.GET, BASE_URL+URL_SIZES+"?page=\(page)&per_page=\(per_page)", parameters: nil, encoding: .JSON, headers: Headers).responseJSON { response in
            if let strongSelf = weakSelf {
                let dic = response.result.value as! NSDictionary
                print("response=\(dic)")
                if page == 0 {
                    strongSelf.data.removeAllObjects()
                }
                let arr:NSArray = dic.valueForKey("sizes") as! NSArray
                if let localArr:NSArray = arr {
                    
                    for index in 1...localArr.count {
                        strongSelf.data.addObject(localArr.objectAtIndex(index-1))
                    }
                }
                dispatch_async(dispatch_get_main_queue(), {
                    strongSelf.tableView.reloadData()
                    strongSelf.tableView.mj_header.endRefreshing()
                })
            }
        }
    }
}
