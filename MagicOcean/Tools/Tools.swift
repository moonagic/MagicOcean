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

func setStatusBarAndNavigationBar(navigation: UINavigationController) {
    navigation.navigationBar.barTintColor = UIColor(red: 0.19, green: 0.56, blue: 0.91, alpha: 1)
    navigation.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
    navigation.navigationBar.barStyle = UIBarStyle.Black
    navigation.navigationBar.tintColor = UIColor.whiteColor()
    navigation.navigationBar.translucent = false
}

