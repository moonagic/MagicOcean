//
//  AppDelegate.swift
//  MagicOcean
//
//  Created by Wu Hengmin on 16/6/8.
//  Copyright © 2016年 Wu Hengmin. All rights reserved.
//

import UIKit
import Alamofire
import SafariServices

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    private func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        var code = url.absoluteString
//        magicocean://callback?code=b86d4698ca831a35473e1b730671234e0dbc02d33ea7534as6835e006b9b61ef&state=0807edf72d85e5d
        
        code = String(code[code.index(code.startIndex, offsetBy: 27)...])
        code = String(code[..<code.index(code.startIndex, offsetBy: 64)])
        
        weak var weakSelf = self
    Alamofire.request(OAUTH_URL+URL_OAUTHTOKEN+"?grant_type=authorization_code&code=\(code)&client_id=\(ClientID)&client_secret=\(ClientSecret)&redirect_uri=\(redirect_uri)", method: .post, parameters: nil, encoding: URLEncoding.default, headers: nil).responseJSON { response in
            if let _ = weakSelf {
                let dic = response.result.value as! NSDictionary
                print("response=\(dic)")
                Account.sharedInstance.Access_Token = dic.value(forKey: "access_token") as! String
                Account.sharedInstance.Refresh_Token = dic.value(forKey: "refresh_token") as! String
                Account.sharedInstance.TokenType = dic.value(forKey: "token_type") as! String
                
                if let info:NSDictionary = dic.value(forKey: "info") as? NSDictionary {
                    Account.sharedInstance.Name = info.value(forKey: "name") as! String
                    Account.sharedInstance.Email = info.value(forKey: "email") as! String
                    Account.sharedInstance.UUID = info.value(forKey: "uuid") as! String
                }
                
                Account.sharedInstance.saveUser()
                
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: kSafariViewControllerCloseNotification), object: url)
                
                NotificationCenter.default.post(name: Notification.Name(kSafariViewControllerCloseNotification), object: url)
                
                self.getAccountDetial()
            }
        }

        return true
    }
    
    func getAccountDetial() {
        let Headers = [
            "Content-Type": "application/json",
            "Authorization": "Bearer "+Account.sharedInstance.Access_Token
        ]
        
        weak var weakSelf = self
        Alamofire.request(BASE_URL+URL_ACCOUNT, method: .get, parameters: nil, encoding: URLEncoding.default, headers: Headers).responseJSON { response in
            if let _ = weakSelf {
                let dic = response.result.value as! NSDictionary
                print("response=\(dic)")
                let account:NSDictionary = dic.value(forKey: "account") as! NSDictionary
                
                Account.sharedInstance.LimitofDroplet = account.value(forKey: "droplet_limit") as! Int
                Account.sharedInstance.LimitofFloatingIP = account.value(forKey: "floating_ip_limit") as! Int
                Account.sharedInstance.EmailVerfied = account.value(forKey: "email_verified") as! Int
                Account.sharedInstance.AccountStatus = account.value(forKey: "status") as! String
                Account.sharedInstance.saveUser()
            }
        }
    }

}

