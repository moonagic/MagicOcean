//
//  Login.swift
//  MagicOcean
//
//  Created by Wu Hengmin on 16/6/13.
//  Copyright © 2016年 Wu Hengmin. All rights reserved.
//

import UIKit
import Alamofire
import SafariServices

let kSafariViewControllerCloseNotification = "kSafariViewControllerCloseNotification"

class Login: UIViewController, SFSafariViewControllerDelegate {
    
    var safariViewController: SFSafariViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController!.navigationBarHidden = true
        self.view.backgroundColor = UIColor(red: 0.19, green: 0.56, blue: 0.91, alpha: 1)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(Login.dismissLoginController(_:)), name: kSafariViewControllerCloseNotification, object: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func dismissLoginController(notification: NSNotification) {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.safariViewController!.dismissViewControllerAnimated(true, completion: nil)
            self.dismissViewControllerAnimated(true, completion: { 
                
            })
        })
    }
    
    @IBAction func pressed(sender: AnyObject) {
        let authPath:String = OAUTH_URL+URL_OAUTH+"/authorize?response_type=code&client_id=\(ClientID)&redirect_uri=\(redirect_uri)&scope=read write&state=0807edf72d85e5d"
        
        let escapedAddress:String = authPath.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
        safariViewController = SFSafariViewController(URL: NSURL(string: escapedAddress)!)
        safariViewController!.delegate = self
        self.presentViewController(safariViewController!, animated: true, completion: nil)
        
        // Open Safari
        //        if let authURL:NSURL = NSURL(string: escapedAddress) {
        //            if UIApplication.sharedApplication().openURL(authURL) {
        //            }
        //        }
        
    }
    
    // MARK: - SFSafariViewControllerDelegate
    
    func safariViewControllerDidFinish(controller: SFSafariViewController) {
        controller.dismissViewControllerAnimated(true) { () -> Void in
            
        }
    }
    
    func safariViewController(controller: SFSafariViewController, didCompleteInitialLoad didLoadSuccessfully: Bool) {
        print("didLoadSuccessfully: \(didLoadSuccessfully)")
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    
}

