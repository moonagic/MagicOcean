//
//  Account.swift
//  MagicOcean
//
//  Created by Wu Hengmin on 16/6/12.
//  Copyright © 2016年 Wu Hengmin. All rights reserved.
//

class Account {
    static let sharedInstance = Account()
    private init() {}
    
    var Name = ""
    var Email = ""
    var UUID = ""
    var Access_Token = ""
    var Refresh_Token = ""
    var TokenType = ""
    
    
}