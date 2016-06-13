//
//  ViewController.swift
//  MagicOcean
//
//  Created by Wu Hengmin on 16/6/8.
//  Copyright © 2016年 Wu Hengmin. All rights reserved.
//

import UIKit
import Alamofire
import SafariServices

let kSafariViewControllerCloseNotification = "kSafariViewControllerCloseNotification"

class ViewController: UIViewController, SFSafariViewControllerDelegate {
    
    var safariVC: SFSafariViewController?
    
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
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.safariLogin(_:)), name: kSafariViewControllerCloseNotification, object: nil)
        
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func safariLogin(notification: NSNotification) {
//        let notifUrl = notification.object as! NSURL
//        print("\nnotifUrl: \(notifUrl)")
//        let urlString = String(notifUrl)
//        let code = extractCode(urlString)
//        print("code: \(code)")
//        self.loginWithInstagram(code!)
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.safariVC!.dismissViewControllerAnimated(true, completion: nil)
        })
    }
    
    @IBAction func pressed(sender: AnyObject) {
        let authPath:String = OAUTH_URL+URL_OAUTH+"/authorize?response_type=code&client_id=\(ClientID)&redirect_uri=\(redirect_uri)&scope=read write&state=0807edf72d85e5d"
        
        let escapedAddress:String = authPath.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
        safariVC = SFSafariViewController(URL: NSURL(string: escapedAddress)!)
        safariVC!.delegate = self
        self.presentViewController(safariVC!, animated: true, completion: nil)
        
        
//        if let authURL:NSURL = NSURL(string: escapedAddress) {
//            if UIApplication.sharedApplication().openURL(authURL) {
//            }
//        }
        
    }
    
    // MARK: - SFSafariViewControllerDelegate
    
    func safariViewControllerDidFinish(controller: SFSafariViewController) {
        controller.dismissViewControllerAnimated(true) { () -> Void in
//            self.label.text = NSLocalizedString("You just dismissed the login view.", comment: "")
        }
    }
    
    func safariViewController(controller: SFSafariViewController, didCompleteInitialLoad didLoadSuccessfully: Bool) {
        print("didLoadSuccessfully: \(didLoadSuccessfully)")
    }


}

