//
//  Login.swift
//  MagicOcean
//
//  Created by Wu Hengmin on 16/6/13.
//  Copyright © 2016年 Wu Hengmin. All rights reserved.
//

import UIKit
import SafariServices

let kSafariViewControllerCloseNotification = "kSafariViewControllerCloseNotification"

class Login: UIViewController, SFSafariViewControllerDelegate {
    
    var safariViewController: SFSafariViewController?
    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController!.isNavigationBarHidden = true
        self.view.backgroundColor = UIColor(red: 0.19, green: 0.56, blue: 0.91, alpha: 1)
        
        loginButton.layer.masksToBounds = true
        loginButton.layer.cornerRadius = 6
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(dismissLoginController(notification:)), name: NSNotification.Name(rawValue: kSafariViewControllerCloseNotification), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func dismissLoginController(notification: NSNotification) {
        DispatchQueue.main.async {
            self.safariViewController!.dismiss(animated: true, completion: nil)
            self.dismiss(animated: true, completion: {
                
            })
        }
    }
    
    @IBAction func pressed(sender: AnyObject) {
        let authPath:String = OAUTH_URL+URL_OAUTH+"/authorize?response_type=code&client_id=\(ClientID)&redirect_uri=\(redirect_uri)&scope=read write&state=\(getRandomStringOfLength(length: 12))"
        
//        let escapedAddress:String = authPath.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
        let escapedAddress = authPath.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        safariViewController = SFSafariViewController(url: NSURL(string: escapedAddress!)! as URL)
        safariViewController!.delegate = self
        
        self.present(safariViewController!, animated: true, completion: nil)
        
        
    }
    
    // MARK: - SFSafariViewControllerDelegate
    
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        controller.dismiss(animated: true) { () -> Void in
            
        }
    }
    
    func safariViewController(_ controller: SFSafariViewController, didCompleteInitialLoad didLoadSuccessfully: Bool) {
        print("didLoadSuccessfully: \(didLoadSuccessfully)")
    }
    
//    override func preferredStatusBarStyle() -> UIStatusBarStyle {
//        return UIStatusBarStyle.lightContent
//    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
}

