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


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(application: UIApplication, openURL url: NSURL, options: [String: AnyObject]) -> Bool {
        var code:NSString = url.absoluteString
//        magicocean://callback?code=b86d4698ca831a35473e1b730671234e0dbc02d33ea7534316835e006b9b61ef&state=0807edf72d85e5d
        let range = NSRange.init(location: 27, length: 64)
        code = code.substringWithRange(range)
        
        weak var weakSelf = self
        Alamofire.request(.POST, OAUTH_URL+URL_OAUTHTOKEN+"?grant_type=authorization_code&code=\(code)&client_id=\(ClientID)&client_secret=\(ClientSecret)&redirect_uri=\(redirect_uri)", parameters: nil, encoding: .URL, headers: nil).responseJSON { response in
            if let _ = weakSelf {
                let dic = response.result.value as! NSDictionary
                print("response=\(dic)")
                Account.sharedInstance.Access_Token = dic.valueForKey("access_token") as! String
                Account.sharedInstance.Refresh_Token = dic.valueForKey("refresh_token") as! String
                Account.sharedInstance.TokenType = dic.valueForKey("token_type") as! String
                
                let info = dic.valueForKey("info")
                Account.sharedInstance.Name = info!.valueForKey("name") as! String
                Account.sharedInstance.Email = info!.valueForKey("email") as! String
                Account.sharedInstance.UUID = info!.valueForKey("uuid") as! String
                
                Account.sharedInstance.saveUser()
                NSNotificationCenter.defaultCenter().postNotificationName(kSafariViewControllerCloseNotification, object: url)
            }
        }

        return true
    }

}

