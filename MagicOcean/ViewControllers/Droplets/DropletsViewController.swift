//
//  ViewController.swift
//  MagicOcean
//
//  Created by Wu Hengmin on 16/6/8.
//  Copyright © 2016年 Wu Hengmin. All rights reserved.
//

import UIKit
import Alamofire
import MJRefresh
import DZNEmptyDataSet


class DropletsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, DropletDelegate, AddDropletDelegate, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    var data:NSMutableArray = []
    var needReload:Bool = true
    var page:Int = 1
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setStatusBarAndNavigationBar(self.navigationController!)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
        
        tableView.tableFooterView = UIView.init(frame: CGRectZero)
        tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        
        
        setupMJRefresh()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        Account.sharedInstance.loadUser()
        if Account.sharedInstance.Access_Token != "" {
            if needReload {
                self.tableView.mj_header.beginRefreshing()
                needReload = false
            }
        } else {
            self.performSegueWithIdentifier("gotologin", sender: nil)
        }
    }
    
    func setupMJRefresh() {
        let header = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction:#selector(mjRefreshData))
        header.automaticallyChangeAlpha = true;
        
        header.lastUpdatedTimeLabel.hidden = true;
        self.tableView.mj_header = header;
//        weak var weakSelf = self
//        self.tableView.mj_footer = MJRefreshBackNormalFooter(refreshingBlock: {
//            if let strongSelf = weakSelf {
//                strongSelf.loadDroplets(strongSelf.page+1, per_page: 10)
//            }
//        })
    }
    
    func mjRefreshData() {
        self.loadDroplets(1, per_page:100)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let identifier:String = "dropletscell"
        let cell:DropletsCell = tableView.dequeueReusableCellWithIdentifier(identifier) as! DropletsCell
        
        let dic:NSDictionary = data.objectAtIndex(indexPath.row) as! NSDictionary
        cell.titleLabel.text = dic.valueForKey("name") as? String
        let imageDic:NSDictionary = dic.valueForKey("image") as! NSDictionary
        let regionDic:NSDictionary = dic.valueForKey("region") as! NSDictionary
        let sizeDic:NSDictionary = dic.valueForKey("size") as! NSDictionary
        
        let imageSlug:String = imageDic.valueForKey("slug") as! String
        let regionSlug:String = regionDic.valueForKey("slug") as! String
        let sizeSlug:String = sizeDic.valueForKey("slug") as! String
        let disksizeSlug:Int = sizeDic.valueForKey("disk") as! Int
        
        cell.infoLabel.text = "\(imageSlug) - \(sizeSlug) - \(disksizeSlug)G"
        
        cell.locationLabel.text = "\(regionSlug)"
        
        let networks:NSDictionary = dic.valueForKey("networks") as! NSDictionary
        let v4:NSArray = networks.valueForKey("v4") as! NSArray
        let publicIP:String = v4[0].valueForKey("ip_address") as! String
        
        cell.IPLabel.text = "Public IP: \(publicIP)"
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let dic:NSDictionary = data.objectAtIndex(indexPath.row) as! NSDictionary
        Droplet.sharedInstance.ID = dic.valueForKey("id") as! Int
        Droplet.sharedInstance.Name = dic.valueForKey("name") as! String
        self.performSegueWithIdentifier("showdropletdetail", sender: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showdropletdetail" {
            let dropletDetail:DropletDetail = segue.destinationViewController as! DropletDetail
            dropletDetail.delegate = self
        } else if segue.identifier == "adddroplet" {
            let nv:UINavigationController = segue.destinationViewController as! UINavigationController
            let and:AddNewDroplet = nv.topViewController as! AddNewDroplet
            and.delegate = self
        }
    }
    
    // MARK: DropletDelegate
    func didSeleteDroplet() {
        self.tableView.mj_header.beginRefreshing()
    }
    
    // MARK: AddDropletDelegate
    func didAddDroplet() {
        self.tableView.mj_header.beginRefreshing()
    }
    
    func loadDroplets(page: Int, per_page: Int) {
        let Headers = [
            "Content-Type": "application/json",
            "Authorization": "Bearer "+Account.sharedInstance.Access_Token
        ]
        
        weak var weakSelf = self
        Alamofire.request(.GET, BASE_URL+URL_DROPLETS+"?page=\(page)&per_page=\(per_page)", parameters: nil, encoding: .URL, headers: Headers).responseJSON { response in
            if let strongSelf = weakSelf {
                let dic = response.result.value as! NSDictionary
                print("response=\(dic)")
                if page == 1 {
                    strongSelf.data.removeAllObjects()
                }
                strongSelf.page = page;
                if let droplets:NSArray = (dic.valueForKey("droplets") as? NSArray)! {
                    strongSelf.data = droplets.mutableCopy() as! NSMutableArray
                }
                dispatch_async(dispatch_get_main_queue(), {
                    strongSelf.tableView.mj_header.endRefreshing()
//                    strongSelf.tableView.mj_footer.endRefreshing()
                    strongSelf.tableView.reloadData()
                })
            }
        }
    }
    
    // MARK: DZNEmptyDataSetSource
    func titleForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        let attributes = [
            NSForegroundColorAttributeName: UIColor.darkGrayColor()
        ]
        
        let attrString:NSAttributedString = NSAttributedString(string: "You have no droplets.", attributes: attributes)
        return attrString
    }
    
    func descriptionForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        let attributes = [
            NSForegroundColorAttributeName: UIColor.grayColor()
        ]
        
        let attrString:NSAttributedString = NSAttributedString(string: "You can create your first droplet.", attributes: attributes)
        return attrString
    }
    
    func buttonTitleForEmptyDataSet(scrollView: UIScrollView!, forState state: UIControlState) -> NSAttributedString! {
        let attributes = [
            NSForegroundColorAttributeName: UIColor(red: 0.19, green: 0.56, blue: 0.91, alpha: 1)
        ]
        
        let attrString:NSAttributedString = NSAttributedString(string: "Create Droplet", attributes: attributes)
        return attrString
    }
    
    func backgroundColorForEmptyDataSet(scrollView: UIScrollView!) -> UIColor! {
        return UIColor.whiteColor()
    }
    
    func emptyDataSetDidTapButton(scrollView: UIScrollView!) {
        self.performSegueWithIdentifier("adddroplet", sender: nil)
    }
    
    // MARK: DZNEmptyDataSetDelegate
    func emptyDataSetShouldAllowScroll(scrollView: UIScrollView!) -> Bool {
        return true
    }
    
    
    @IBAction func addPressed(sender: AnyObject) {
        // pressed the add button
    }
}

