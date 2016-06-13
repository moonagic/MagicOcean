//
//  Account.swift
//  MagicOcean
//
//  Created by Wu Hengmin on 16/6/12.
//  Copyright © 2016年 Wu Hengmin. All rights reserved.
//

import Foundation

class Account {
    static let sharedInstance = Account()
    private init() {}
    
    var Name = ""
    var Email = ""
    var UUID = ""
    var Access_Token = ""
    var Refresh_Token = ""
    var TokenType = ""
    
    var EmailVerfied = 0
    var LimitofDroplet = 0
    var LimitofFloatingIP = 0
    var AccountStatus = ""
    
    
    func saveUser() {
        NSUserDefaults().setObject(Name, forKey: "Name")
        NSUserDefaults().setObject(Access_Token, forKey: "Access_Token")
        NSUserDefaults().setObject(UUID, forKey: "UUID")
        NSUserDefaults().setObject(Email, forKey: "Email")
        NSUserDefaults().setObject(Refresh_Token, forKey: "Refresh_Token")
        NSUserDefaults().setObject(TokenType, forKey: "TokenType")
        
        NSUserDefaults().setInteger(EmailVerfied, forKey: "EmailVerfied")
        NSUserDefaults().setInteger(LimitofDroplet, forKey: "LimitofDroplet")
        NSUserDefaults().setInteger(LimitofFloatingIP, forKey: "LimitofFloatingIP")
        NSUserDefaults().setObject(AccountStatus, forKey: "AccountStatus")
    }
    
    func logoutUser() {
        NSUserDefaults().setObject("", forKey: "Name")
        NSUserDefaults().setObject("", forKey: "Access_Token")
        NSUserDefaults().setObject("", forKey: "UUID")
        NSUserDefaults().setObject("", forKey: "Email")
        NSUserDefaults().setObject("", forKey: "Refresh_Token")
        NSUserDefaults().setObject("", forKey: "TokenType")
        
        NSUserDefaults().setInteger(0, forKey: "EmailVerfied")
        NSUserDefaults().setInteger(0, forKey: "LimitofDroplet")
        NSUserDefaults().setInteger(0, forKey: "LimitofFloatingIP")
        NSUserDefaults().setObject("", forKey: "AccountStatus")
    }
    
    func loadUser() {
        if let result:String = NSUserDefaults().objectForKey("Name") as? String {
            Name = result
        }
        if let result:String = NSUserDefaults().objectForKey("Access_Token") as? String {
            Access_Token = result
        }
        if let result:String = NSUserDefaults().objectForKey("UUID") as? String {
            UUID = result
        }
        if let result:String = NSUserDefaults().objectForKey("Email") as? String {
            Email = result
        }
        if let result:String = NSUserDefaults().objectForKey("Refresh_Token") as? String {
            Refresh_Token = result
        }
        if let result:String = NSUserDefaults().objectForKey("TokenType") as? String {
            TokenType = result
        }
        if let result:String = NSUserDefaults().objectForKey("AccountStatus") as? String {
            AccountStatus = result
        }
        if let result:Int = NSUserDefaults().integerForKey("EmailVerfied") {
            EmailVerfied = result
        }
        if let result:Int = NSUserDefaults().integerForKey("LimitofDroplet") {
            LimitofDroplet = result
        }
        if let result:Int = NSUserDefaults().integerForKey("LimitofFloatingIP") {
            LimitofFloatingIP = result
        }
    }
    
    
}