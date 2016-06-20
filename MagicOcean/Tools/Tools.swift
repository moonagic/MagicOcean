//
//  Tools.swift
//  MagicOcean
//
//  Created by Wu Hengmin on 16/6/13.
//  Copyright © 2016年 Wu Hengmin. All rights reserved.
//

import Foundation
import MBProgressHUD


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

func makeTextToast(message: String, view: UIView) {
    let hud = MBProgressHUD.showHUDAddedTo(view, animated: true)
    hud.mode = MBProgressHUDMode.Text
    hud.labelText = message
    hud.margin = 10
    hud.removeFromSuperViewOnHide = true
    hud.hide(true, afterDelay: 1)
}