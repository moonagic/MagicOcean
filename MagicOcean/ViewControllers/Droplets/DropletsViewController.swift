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
        setStatusBarAndNavigationBar(navigation: self.navigationController!)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
        
        tableView.tableFooterView = UIView.init(frame: CGRect.zero)
        tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        
        
        setupMJRefresh()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Account.sharedInstance.loadUser()
        if Account.sharedInstance.Access_Token != "" {
            if needReload {
                self.tableView.mj_header.beginRefreshing()
                needReload = false
            }
        } else {
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "gotologin", sender: nil)
            }
        }
        
//        DispatchQueue.main.async { [weak self] in
//            guard let `self` = self else { return }
//            self.dismiss(animated: true, completion: {
//                
//            })
//        }
    }
    
    func setupMJRefresh() {
        
        let header = MJRefreshNormalHeader(refreshingBlock: {
            self.loadDroplets(page: 1, per_page:100)
        })
        header?.lastUpdatedTimeLabel.isHidden = true
        header?.isAutomaticallyChangeAlpha = true
        self.tableView.mj_header = header
        
//        self.tableView.mj_footer = MJRefreshBackNormalFooter(refreshingBlock: {
//            self.loadDroplets(page: self.page+1, per_page: 100)
//        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier:String = "dropletscell"
        let cell:DropletsCell = tableView.dequeueReusableCell(withIdentifier: identifier) as! DropletsCell
        
        let dic:NSDictionary = data.object(at: indexPath.row) as! NSDictionary
        cell.titleLabel.text = dic.value(forKey: "name") as? String
        let imageDic:NSDictionary = dic.value(forKey: "image") as! NSDictionary
        let regionDic:NSDictionary = dic.value(forKey: "region") as! NSDictionary
        let sizeDic:NSDictionary = dic.value(forKey: "size") as! NSDictionary
        
        let imageSlug:String = imageDic.value(forKey: "slug") as? String ?? "unknow image"
        let regionSlug:String = regionDic.value(forKey: "slug") as? String ?? "-"
        let sizeSlug:String = sizeDic.value(forKey: "slug") as? String ?? "-"
        let disksizeSlug:Int = sizeDic.value(forKey: "disk") as! Int
        
        cell.infoLabel.text = "\(imageSlug) - \(sizeSlug) - \(disksizeSlug)G"
        
        cell.locationLabel.text = "\(regionSlug)"
        
        let networks:NSDictionary = dic.value(forKey: "networks") as! NSDictionary
        let v4:NSArray = networks.value(forKey: "v4") as! NSArray
        if v4.count > 0 {
            let v41:NSDictionary = v4[0] as! NSDictionary
            let publicIP:String = v41.value(forKey: "ip_address") as! String
            
            cell.IPLabel.text = "Public IP: \(publicIP)"
        }
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let dic:NSDictionary = data.object(at: indexPath.row) as! NSDictionary
        Droplet.sharedInstance.ID = dic.value(forKey: "id") as! Int
        Droplet.sharedInstance.Name = dic.value(forKey: "name") as! String
        self.performSegue(withIdentifier: "showdropletdetail", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showdropletdetail" {
            let dropletDetail:DropletDetail = segue.destination as! DropletDetail
            dropletDetail.delegate = self
        } else if segue.identifier == "adddroplet" {
            let nv:UINavigationController = segue.destination as! UINavigationController
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
        Alamofire.request(BASE_URL+URL_DROPLETS+"?page=\(page)&per_page=\(per_page)", method: .get, parameters: nil, encoding: URLEncoding.default, headers: Headers).responseJSON { response in
            if let strongSelf = weakSelf {
                let dic = response.result.value as! NSDictionary
                print("response=\(dic)")
                if page == 1 {
                    strongSelf.data.removeAllObjects()
                }
                strongSelf.page = page;
                if let droplets:NSArray = dic.value(forKey: "droplets") as? NSArray {
                    strongSelf.data = droplets.mutableCopy() as! NSMutableArray
                }
                DispatchQueue.main.async {
                    strongSelf.tableView.mj_header.endRefreshing()
                    strongSelf.tableView.reloadData()
                }
            }
        }
    }
    
    // MARK: DZNEmptyDataSetSource
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let attributes = [
            NSAttributedString.Key.foregroundColor: UIColor.darkGray
        ]
        
        let attrString:NSAttributedString = NSAttributedString(string: "You have no droplets.", attributes: attributes)
        return attrString
    }
    
    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let attributes = [
            NSAttributedString.Key.foregroundColor: UIColor.gray
        ]
        
        let attrString:NSAttributedString = NSAttributedString(string: "You can create your first droplet.", attributes: attributes)
        return attrString
    }
    
    func buttonTitle(forEmptyDataSet scrollView: UIScrollView!, for state: UIControl.State) -> NSAttributedString! {
        let attributes = [
            NSAttributedString.Key.foregroundColor: #colorLiteral(red: 0.19, green: 0.56, blue: 0.91, alpha: 1)
        ]
        
        let attrString:NSAttributedString = NSAttributedString(string: "Create Droplet", attributes: attributes)
        return attrString
    }
    
    func backgroundColor(forEmptyDataSet scrollView: UIScrollView!) -> UIColor! {
        return UIColor.white
    }
    
    func emptyDataSetDidTapButton(_ scrollView: UIScrollView!) {
        self.performSegue(withIdentifier: "adddroplet", sender: nil)
    }
    
    // MARK: DZNEmptyDataSetDelegate
    func emptyDataSetShouldAllowScroll(_ scrollView: UIScrollView!) -> Bool {
        return true
    }
    
    
    @IBAction func addPressed(sender: AnyObject) {
        // pressed the add button
    }
}

