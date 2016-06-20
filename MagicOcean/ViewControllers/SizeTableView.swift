//
//  SizeTableView.swift
//  MagicOcean
//
//  Created by Wu Hengmin on 16/6/19.
//  Copyright © 2016年 Wu Hengmin. All rights reserved.
//

import UIKit

class SizeTableView: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController!.navigationBar.barTintColor = UIColor(red: 0.19, green: 0.56, blue: 0.91, alpha: 1)
        self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        self.navigationController!.navigationBar.barStyle = UIBarStyle.Black
        self.navigationController!.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController!.navigationBar.translucent = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let identifier:String = "sizecell"
        let cell:ImageCell = tableView.dequeueReusableCellWithIdentifier(identifier) as! ImageCell
        
        //        let dic = self.data.objectAtIndex(indexPath.row)
        //        cell.textLabel?.text = dic.valueForKey("slug") as? String
        
        return cell
    }
    
    @IBAction func cancellPressed(sender: AnyObject) {
        self.dismissViewControllerAnimated(true) {
            
        }
    }
}
