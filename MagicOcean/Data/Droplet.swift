//
//  Droplet.swift
//  MagicOcean
//
//  Created by Wu Hengmin on 16/6/13.
//  Copyright © 2016年 Wu Hengmin. All rights reserved.
//

import Foundation

class Droplet {
    
    static let sharedInstance = Droplet()
    private init() {}
    
    var ID:Int = 0
    var Name:String = ""
    
}