//
//  ImageTableView.swift
//  MagicOcean
//
//  Created by Wu Hengmin on 16/6/19.
//  Copyright © 2016年 Wu Hengmin. All rights reserved.
//

import UIKit
import Alamofire
import MJRefresh
import SwiftyJSON



struct ImageTeplete {
    var name:String
    var slug:String
    var distribution:String
}

struct FormatImageTeplete {
    var section:String
    var images:[ImageTeplete]
}

protocol SelectImageDelegate {
    func didSelectImage(image: ImageTeplete)
}

class ImageTableView: UITableViewController {
    
    var imagesData:[ImageTeplete] = Array<ImageTeplete>()
    var imagesDataWithFormat:[FormatImageTeplete] = Array<FormatImageTeplete>()
    var delegate: SelectImageDelegate?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setStatusBarAndNavigationBar(navigation: self.navigationController!)
        
        tableView.tableFooterView = UIView.init(frame: CGRect.zero)
        
        setupMJRefresh()
    }
    
    func setupMJRefresh() {
        let header = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction:#selector(mjRefreshData))
        header?.isAutomaticallyChangeAlpha = true;
        
        header?.lastUpdatedTimeLabel.isHidden = true;
        self.tableView.mj_header = header;
        
    }
    
    @objc func mjRefreshData() {
        self.loadImages(page: 1, per_page: 100);
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        if let result:NSData = UserDefaults().object(forKey: "images") as? NSData {
        
//            self.data = NSKeyedUnarchiver.unarchiveObject(with: result as Data) as! NSMutableArray
//        } else {
            self.tableView.mj_header.beginRefreshing()
//        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return imagesDataWithFormat.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return imagesDataWithFormat[section].images.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return imagesDataWithFormat[section].section
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier:String = "imagecell"
        let cell:ImageCell = tableView.dequeueReusableCell(withIdentifier: identifier) as! ImageCell
        
        let data = imagesDataWithFormat[indexPath.section].images[indexPath.row]
        cell.titleLabel.text = "\(data.distribution) \(data.name)"
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let image = self.imagesDataWithFormat[indexPath.section].images[indexPath.row]
        self.delegate?.didSelectImage(image: image)
        self.dismiss(animated: true) {
            
        }
    }
    
    @IBAction func cancellPressed(sender: AnyObject) {
        self.dismiss(animated: true) {
            
        }
    }
    
    func loadImages(page: Int, per_page: Int) {
        //        curl -X GET -H "Content-Type: application/json" -H "Authorization: Bearer b7d03a6947b217efb6f3ec3bd3504582" "https://api.digitalocean.com/v2/images?page=1&per_page=1"
        let Headers = [
            "Content-Type": "application/json",
            "Authorization": "Bearer "+Account.sharedInstance.Access_Token
        ]
        
        weak var weakSelf = self
        
        Alamofire.request(BASE_URL+URL_IMAGES+"?type=distribution&page=\(page)&per_page=\(per_page)", method: .get, parameters: nil, encoding: URLEncoding.default, headers: Headers).responseJSON { response in
            if let strongSelf = weakSelf {
                
                if let JSONObj = response.result.value {
                    let dic = JSONObj as! NSDictionary
                    let jsonString = dictionary2JsonString(dic: dic as! Dictionary<String, Any>)
                    print(jsonString)
                    if let dataFromString = jsonString.data(using: .utf8, allowLossyConversion: false) {
                        if let json = try? JSON(data: dataFromString) {
                            if let images = json["images"].array {
                                for i in images {
                                    strongSelf.imagesData.append(ImageTeplete(name: i["name"].string ?? "-", slug: i["slug"].string ?? "-", distribution: i["distribution"].string ?? "-"))
                                }
                            }
                        }
                    }
                }
                self.formatImage()
                DispatchQueue.main.async {
                    strongSelf.tableView.reloadData()
                    strongSelf.tableView.mj_header.endRefreshing()
                }
            }
        }
    }
    
    private func formatImage() {
        for image in imagesData {
            var index = -1
            for i in 0..<imagesDataWithFormat.count {
                if imagesDataWithFormat[i].section == image.distribution {
                    index = i
                    break
                }
            }
            if index > -1 {
                imagesDataWithFormat[index].images.append(image)
            } else {
                imagesDataWithFormat.append(FormatImageTeplete(section: image.distribution, images: [image]))
            }
        }
    }
    
}
