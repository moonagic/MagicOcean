//
//  ViewController.swift
//  MagicOcean
//
//  Created by Wu Hengmin on 16/6/8.
//  Copyright © 2016年 Wu Hengmin. All rights reserved.
//

import UIKit
import Alamofire

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
//        weak var weakSelf = self
//        let headers = [
//            "Authorization": "Bearer "+Personal_Access_Tokens,
//            "Content-Type": "application/json"
//        ]
//        
//        Alamofire.request(.GET, BASE_URL+URL_ACCOUNT, parameters: nil, encoding: .URL, headers: headers).responseJSON { response in
//            if let strongSelf = weakSelf {
//                let str = response.result.value as! NSDictionary
//                print(str)
//            }
//        }
        
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func pressed(sender: AnyObject) {
        let authPath:String = "https://cloud.digitalocean.com/v1/oauth/authorize?response_type=code&client_id=\(ClientID)&redirect_uri=\(redirect_uri)&scope=read write&state=0807edf72d85e5d"
        print(authPath)
        let escapedAddress:String = authPath.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
        if let authURL:NSURL = NSURL(string: escapedAddress) {
            if UIApplication.sharedApplication().openURL(authURL) {
            }
        }
        
    }


}

