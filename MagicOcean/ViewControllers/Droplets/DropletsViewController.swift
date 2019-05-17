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
import SwiftyJSON


class DropletsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, DropletDelegate, AddDropletDelegate, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
   
    
    
    @IBOutlet weak var tableView: UITableView!
    var dropletsData: [DropletTemplate] = Array<DropletTemplate>()
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
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dropletsData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier:String = "dropletscell"
        let cell:DropletsCell = tableView.dequeueReusableCell(withIdentifier: identifier) as! DropletsCell
        
        let d = dropletsData[indexPath.row]
        cell.titleLabel.text = d.name
        cell.infoLabel.text = "\(d.image.distribution) - \(d.size.vcpus)vCPU - \(d.size.memory)MB - \(d.size.disk)GB"
        cell.locationLabel.text = d.region.slug
        cell.IPLabel.text = "Public IP: \(d.ip)"
        if d.status == "active" {
            cell.statusView.backgroundColor = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)
        } else {
            cell.statusView.backgroundColor = #colorLiteral(red: 0.3333333433, green: 0.3333333433, blue: 0.3333333433, alpha: 1)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let viewController:DropletDetail = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "dropletdetail") as! DropletDetail
        viewController.dropletData = dropletsData[indexPath.row]
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "adddroplet" {
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
            
            guard let strongSelf = weakSelf else {
                return
            }
            guard let JSONObj = response.result.value else {
                makeTextToast(message: "JSON ERROR", view: strongSelf.view)
                return
            }
            let dic = JSONObj as! NSDictionary
            let jsonString = dictionary2JsonString(dic: dic as! Dictionary<String, Any>)
            print(jsonString)
            guard let dataFromString = jsonString.data(using: .utf8, allowLossyConversion: false) else {
                makeTextToast(message: "JSON ERROR", view: strongSelf.view)
                return
            }
            guard let json = try? JSON(data: dataFromString) else {
                makeTextToast(message: "JSON ERROR", view: strongSelf.view)
                return
            }
            guard let droplets = json["droplets"].array else {
                DispatchQueue.main.async {
                    strongSelf.tableView.mj_header.endRefreshing()
                    strongSelf.tableView.reloadData()
                }
                return
            }
            
            strongSelf.dropletsData.removeAll()
            
            for d in droplets {
                let image = ImageTeplete(name: d["image"]["distribution"].string ?? "-", slug: d["image"]["slug"].string ?? "", distribution: d["image"]["distribution"].string ?? "")
                let region = RegionTeplete(name: d["region"]["name"].string ?? "", slug: d["region"]["slug"].string ?? "")
                let size = SizeTeplete(memory: d["size"]["memory"].int ?? 0, price: d["size"]["price_monthly"].int ?? 0, disk: d["size"]["disk"].int ?? 0, transfer: d["size"]["transfer"].int ?? 0, vcpus: d["size"]["vcpus"].int ?? 0, slug: d["size"]["slug"].string ?? "-")
                strongSelf.dropletsData.append(DropletTemplate(id: d["id"].int ?? 0, name: d["name"].string ?? "-", ip: d["networks"]["v4"][0]["ip_address"].string ?? "-", status: d["status"].string ?? "", image: image, region: region, size: size))
            }
            
            DispatchQueue.main.async {
                strongSelf.tableView.mj_header.endRefreshing()
                strongSelf.tableView.reloadData()
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

