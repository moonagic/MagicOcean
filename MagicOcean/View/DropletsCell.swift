//
//  DropletsCell.swift
//  MagicOcean
//
//  Created by Wu Hengmin on 16/6/13.
//  Copyright © 2016年 Wu Hengmin. All rights reserved.
//

import UIKit

class DropletsCell: UITableViewCell {

    @IBOutlet weak var subView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var IPLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.subView.layer.masksToBounds = true
        self.subView.layer.cornerRadius = 6
        self.subView.backgroundColor = UIColor(red: 0.19, green: 0.56, blue: 0.91, alpha: 1)
    }
}
