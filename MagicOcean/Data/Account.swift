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
    
    func saveUser() {
        NSUserDefaults().setObject(Name, forKey: "Name")
        NSUserDefaults().setObject(Access_Token, forKey: "Access_Token")
        NSUserDefaults().setObject(UUID, forKey: "UUID")
        NSUserDefaults().setObject(Email, forKey: "Email")
        NSUserDefaults().setObject(Refresh_Token, forKey: "Refresh_Token")
        NSUserDefaults().setObject(TokenType, forKey: "TokenType")
    }
    
    func logoutUser() {
        NSUserDefaults().setObject("", forKey: "Name")
        NSUserDefaults().setObject("", forKey: "Access_Token")
        NSUserDefaults().setObject("", forKey: "UUID")
        NSUserDefaults().setObject("", forKey: "Email")
        NSUserDefaults().setObject("", forKey: "Refresh_Token")
        NSUserDefaults().setObject("", forKey: "TokenType")
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
    }
    
    
}