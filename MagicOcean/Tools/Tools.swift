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
    let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    return String((0..<length).map{ _ in letters.randomElement()! })
}

func makeTextToast(message: String, view: UIView) {
    let hud = MBProgressHUD.showAdded(to: view, animated: true)
    hud.mode = MBProgressHUDMode.text
    hud.label.text = message
    hud.margin = 10
    hud.removeFromSuperViewOnHide = true
    hud.hide(animated: true, afterDelay: 1)
}

func setStatusBarAndNavigationBar(navigation: UINavigationController) {
    navigation.navigationBar.barTintColor = #colorLiteral(red: 0.19, green: 0.56, blue: 0.91, alpha: 1)
    navigation.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
    navigation.navigationBar.barStyle = UIBarStyle.black
    navigation.navigationBar.tintColor = UIColor.white
    navigation.navigationBar.isTranslucent = false
}

func dictionary2JsonString(dic: Dictionary<String, Any>) -> String {
    do {
        let jsonData = try JSONSerialization.data(withJSONObject: dic, options: [])
        let data = String(data: jsonData, encoding: String.Encoding.utf8)!
        return data
    } catch {
        return ""
    }
}

