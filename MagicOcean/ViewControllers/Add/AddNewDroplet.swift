//
//  AddNewDroplet.swift
//  MagicOcean
//
//  Created by Wu Hengmin on 16/6/19.
//  Copyright © 2016年 Wu Hengmin. All rights reserved.
//

import UIKit
import Alamofire
import MBProgressHUD
import UnsplashPhotoPicker

@objc public protocol AddDropletDelegate {
    func didAddDroplet()
}

class AddNewDroplet: UITableViewController, UITextFieldDelegate, SelectImageDelegate, SelectSizeDelegate, SelectRegionDelegate, SelectSSHKeyDelegate {

    @IBOutlet weak var hostnameField: UITextField!
    @IBOutlet weak var imageField: UITextField!
    
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var memoryAndCPULabel: UILabel!
    @IBOutlet weak var diskLabel: UILabel!
    @IBOutlet weak var transferLabel: UILabel!
    
    @IBOutlet weak var regionField: UITextField!
    
    @IBOutlet weak var SSHKeyField: UITextField!
    
    @IBOutlet weak var privateNetworkingSwitch: UISwitch!
    @IBOutlet weak var backupsSwitch: UISwitch!
    @IBOutlet weak var ipv6Switch: UISwitch!
    @IBOutlet weak var coverImage: UIImageView!
    @IBOutlet weak var coverImageTag: UILabel!
    var sizeDic:SizeTeplete!
    var imageDic:ImageTeplete!
    var regionDic:RegionTeplete!
    var sshkeyDic:SSHKeyTeplete!
    
    
    weak var delegate: AddDropletDelegate?
    
    private var imageDataTask: URLSessionDataTask?
    override func viewDidLoad() {
        super.viewDidLoad()
        setStatusBarAndNavigationBar(navigation: self.navigationController!)
        
        self.hostnameField.delegate = self
        
//        self.priceLabel.text = "$ 0.00"
        self.memoryAndCPULabel.text = "0MB / 0CPUs"
        self.diskLabel.text = "0GB SSD"
        self.transferLabel.text = "Transfer 0TB"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    @IBAction func cancellPressed(sender: AnyObject) {
        self.dismiss(animated: true) {

        }
    }
    
    @IBAction func selectCoverImageButtonPressed(_ sender: Any) {
        
        
        
        
        let alertController:UIAlertController=UIAlertController(title: "Select cover image", message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        alertController.addAction(UIAlertAction(title: "Photo Libray", style: UIAlertAction.Style.default){
            (alertAction)->Void in
            let imagePicker: UIImagePickerController = UIImagePickerController()
            imagePicker.modalPresentationStyle = .overFullScreen
            imagePicker.delegate = self
            imagePicker.allowsEditing = false
            imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
            self.present(imagePicker, animated: true, completion: nil)

        })
        alertController.addAction(UIAlertAction(title: "Camera", style: UIAlertAction.Style.default){
            (alertAction)->Void in
            let imagePicker: UIImagePickerController = UIImagePickerController()
            imagePicker.modalPresentationStyle = .overFullScreen
            imagePicker.delegate = self
            imagePicker.allowsEditing = false
            imagePicker.sourceType = UIImagePickerController.SourceType.camera
            self.present(imagePicker, animated: true, completion: nil)

        })
        alertController.addAction(UIAlertAction(title: "form Unsplash", style: UIAlertAction.Style.default){
            (alertAction)->Void in
            let configuration = UnsplashPhotoPickerConfiguration(
                accessKey: "7c3f947507aefaa8c5008400d78288fd13d62f32c999f4a743478b41a54f35a1",
                secretKey: "66a8e97f1f6315fefaf73df0897019801f7ded66bf6aed2739be95fb26c0a8de",
                allowsMultipleSelection: false
            )
            let unsplashPhotoPicker = UnsplashPhotoPicker(configuration: configuration)
            unsplashPhotoPicker.photoPickerDelegate = self
            
            self.present(unsplashPhotoPicker, animated: true, completion: nil)
        })
        alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel,handler:nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func savePressed(sender: AnyObject) {
        
        if self.hostnameField.text == "" {
            makeTextToast(message: "Hostname can not be blank!", view: self.view.window!)
            return
        }
        if self.sizeDic == nil {
            makeTextToast(message: "You must select size!", view: self.view.window!)
            return
        }
        if self.imageDic == nil {
            makeTextToast(message: "You must select image!", view: self.view.window!)
            return
        }
        if self.regionDic == nil {
            makeTextToast(message: "You must select region!", view: self.view.window!)
            return
        }
        
        //        curl -X POST -H "Content-Type: application/json" -H "Authorization: Bearer b7d03a6947b217efb6f3ec3bd3504582" -d '{"name":"example.com","region":"nyc3","size":"512mb","image":"ubuntu-14-04-x64","ssh_keys":null,"backups":false,"ipv6":true,"user_data":null,"private_networking":null}' "https://api.digitalocean.com/v2/droplets"
        
        let Headers = [
            "Content-Type": "application/json",
            "Authorization": "Bearer "+Account.sharedInstance.Access_Token
        ]
        
        let name:String = self.hostnameField.text!
        let size:String = self.sizeDic.slug
        let image:String = self.imageDic.slug
        let region:String = self.regionDic.slug
        var keyarr:[Int] = Array<Int>()
        if sshkeyDic != nil {
            keyarr = [sshkeyDic.id]
        }
        
        
        
        let parameters:Parameters = [
            "name":name,
            "region":region,
            "size":size,
            "image":image,
            "ssh_keys":keyarr,
            "backups":self.backupsSwitch.isOn,
            "ipv6":self.ipv6Switch.isOn,
//            "user_data": nil,
            "private_networking":self.privateNetworkingSwitch.isOn
        ]
        
        print(dictionary2JsonString(dic: parameters))
    
        
        let hud:MBProgressHUD = MBProgressHUD.init(view: self.view.window!)
        self.view.window?.addSubview(hud)
        hud.mode = MBProgressHUDMode.indeterminate
        hud.show(animated: true)
        hud.removeFromSuperViewOnHide = true
        
        weak var weakSelf = self
        Alamofire.request(BASE_URL+URL_DROPLETS, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: Headers).responseJSON { response in
            if let strongSelf = weakSelf {
                
                let dic = response.result.value as! NSDictionary
                print("response=\(dic)")
                DispatchQueue.main.async {
                    hud.hide(animated: true)
                    if let message = dic.value(forKey: "message") {
                        print(message)
                        makeTextToast(message: message as! String, view: strongSelf.view.window!)
                    } else {
                        strongSelf.delegate?.didAddDroplet()
                        strongSelf.dismiss(animated: true, completion: {
                            
                        })
                    }
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "selectimage" {
            let nv:UINavigationController = segue.destination as! UINavigationController
            let vc:ImageTableView = nv.topViewController as! ImageTableView
            vc.delegate = self
        } else if segue.identifier == "selectsize" {
            let nv:UINavigationController = segue.destination as! UINavigationController
            let vc:SizeTableView = nv.topViewController as! SizeTableView
            vc.delegate = self
        } else if segue.identifier == "selectregion" {
            let nv:UINavigationController = segue.destination as! UINavigationController
            let vc:RegionTableView = nv.topViewController as! RegionTableView
            vc.delegate = self
        } else if segue.identifier == "selectkey" {
            let nv:UINavigationController = segue.destination as! UINavigationController
            let vc:SSHKeyTableView = nv.topViewController as! SSHKeyTableView
            vc.delegate = self
        }
    }
    
    // MARK: - delegate of ImageTableView
    func didSelectImage(image: ImageTeplete) {
        self.imageDic = image
        weak var weakSelf = self
        DispatchQueue.main.async {
            weakSelf!.imageField.text = self.imageDic.slug
        }
    }
    
    // MARK: - delegate of SizeTableView
    func didSelectSize(size: SizeTeplete) {
        self.sizeDic = size
        weak var weakSelf = self
        DispatchQueue.main.async {
            if let strongSelf = weakSelf {
                
                
//                strongSelf.priceLabel.text = "$\(String(format: "%.2f", Float(size.price)))"
                strongSelf.memoryAndCPULabel.text = "\(size.memory)MB / \(size.vcpus)CPUs"
                strongSelf.diskLabel.text = "\(size.disk)GB SSD"
                strongSelf.transferLabel.text = "Transfer \(size.transfer)TB"
                
            }
            
        }
    }
    
    // MARK: - delegate of RegionTableView
    func didSelectRegion(region: RegionTeplete) {
        self.regionDic = region
        weak var weakSelf = self
        DispatchQueue.main.async {
            if let strongSelf = weakSelf {
                strongSelf.regionField.text = region.slug
            }
        }
    }
    
    // MARK: - delegate of SSHKeyTableView
    func didSelectSSHKey(key: SSHKeyTeplete) {
        self.sshkeyDic = key
        weak var weakSelf = self
        DispatchQueue.main.async {
            if let strongSelf = weakSelf {
                strongSelf.SSHKeyField.text = key.name
            }
        }
    }
    
    // MARK: - delegate of UITextField
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string.count == 0 {
            return true
        }
        let nStr:NSString = NSString(format: "\(string)" as NSString)
        
        let uchar:unichar = nStr.character(at: 0)
        
        if uchar >= NSString(format: "a").character(at: 0) && uchar <= NSString(format: "z").character(at: 0) {
            return true
        }
        if uchar >= NSString(format: "A").character(at: 0) && uchar <= NSString(format: "Z").character(at: 0) {
            return true
        }
        if uchar >= NSString(format: "1").character(at: 0) && uchar <= NSString(format: "0").character(at: 0) {
            return true
        }
        if uchar == NSString(format: "-").character(at: 0) {
            return true
        }
        
        return false
    }
    
    
    
}

extension AddNewDroplet: UnsplashPhotoPickerDelegate {
    func unsplashPhotoPicker(_ photoPicker: UnsplashPhotoPicker, didSelectPhotos photos: [UnsplashPhoto]) {
        print("Unsplash photo picker did select \(photos.count) photo(s)")
        
        guard let url = photos[0].urls[.regular] else { return }
        
        imageDataTask = URLSession.shared.dataTask(with: url) { [weak self] (data, _, error) in
            guard let strongSelf = self else { return }
            
            strongSelf.imageDataTask = nil
            
            guard let data = data, let image = UIImage(data: data), error == nil else { return }
            
            DispatchQueue.main.async {
                UIView.transition(with: strongSelf.coverImage, duration: 0.25, options: [.transitionCrossDissolve], animations: {
                    strongSelf.coverImage.image = image
                }, completion: nil)
                strongSelf.coverImageTag.isHidden = true
            }
        }
        
        imageDataTask?.resume()
    }
    
    func unsplashPhotoPickerDidCancel(_ photoPicker: UnsplashPhotoPicker) {
        print("Unsplash photo picker did cancel")
    }
}

extension AddNewDroplet: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        var image : UIImage!
        image = (info[UIImagePickerController.InfoKey.originalImage] as! UIImage)
        self.coverImage.image = image
        coverImageTag.isHidden = true
        picker.dismiss(animated: true) {
            
        }
    }
}
