//
//  Tools.swift
//  MagicOcean
//
//  Created by Wu Hengmin on 16/6/13.
//  Copyright © 2016年 Wu Hengmin. All rights reserved.
//

import Foundation


let characters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
/**
 获取随机字符串
 
 - parameter length: 字符串长度
 
 - returns:
 */
func getRandomStringOfLength(length: Int) -> String {
    var ranStr = ""
    for _ in 0..<length {
        let index = Int(arc4random_uniform(UInt32(characters.characters.count)))
        ranStr.append(characters[characters.startIndex.advancedBy(index)])
    }
    return ranStr
    
}