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
        UserDefaults().set(Name, forKey: "Name")
        UserDefaults().set(Access_Token, forKey: "Access_Token")
        UserDefaults().set(UUID, forKey: "UUID")
        UserDefaults().set(Email, forKey: "Email")
        UserDefaults().set(Refresh_Token, forKey: "Refresh_Token")
        UserDefaults().set(TokenType, forKey: "TokenType")
        
        UserDefaults().set(EmailVerfied, forKey: "EmailVerfied")
        UserDefaults().set(LimitofDroplet, forKey: "LimitofDroplet")
        UserDefaults().set(LimitofFloatingIP, forKey: "LimitofFloatingIP")
        UserDefaults().set(AccountStatus, forKey: "AccountStatus")
    }
    
    func logoutUser() {
        UserDefaults().set("", forKey: "Name")
        UserDefaults().set("", forKey: "Access_Token")
        UserDefaults().set("", forKey: "UUID")
        UserDefaults().set("", forKey: "Email")
        UserDefaults().set("", forKey: "Refresh_Token")
        UserDefaults().set("", forKey: "TokenType")
        
        UserDefaults().set(0, forKey: "EmailVerfied")
        UserDefaults().set(0, forKey: "LimitofDroplet")
        UserDefaults().set(0, forKey: "LimitofFloatingIP")
        UserDefaults().set("", forKey: "AccountStatus")
    }
    
    func loadUser() {
        if let result:String = UserDefaults().object(forKey: "Name") as? String {
            Name = result
        }
        if let result:String = UserDefaults().object(forKey: "Access_Token") as? String {
            Access_Token = result
        }
        if let result:String = UserDefaults().object(forKey: "UUID") as? String {
            UUID = result
        }
        if let result:String = UserDefaults().object(forKey: "Email") as? String {
            Email = result
        }
        if let result:String = UserDefaults().object(forKey: "Refresh_Token") as? String {
            Refresh_Token = result
        }
        if let result:String = UserDefaults().object(forKey: "TokenType") as? String {
            TokenType = result
        }
        if let result:String = UserDefaults().object(forKey: "AccountStatus") as? String {
            AccountStatus = result
        }
        EmailVerfied = UserDefaults().integer(forKey: "EmailVerfied")
        LimitofDroplet = UserDefaults().integer(forKey: "LimitofDroplet")
        LimitofFloatingIP = UserDefaults().integer(forKey: "LimitofFloatingIP")
    }
    
    
}
