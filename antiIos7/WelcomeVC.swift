//
//  WelcomeVC.swift
//  antiIos7
//
//  Created by Polina on 02.10.17.
//  Copyright © 2017 Polina. All rights reserved.
//

import UIKit

class WelcomeVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet var lblName: UILabel!
    
    @IBOutlet var userWelcomeImg: UIImageView!
    var menuItems = ["Имя", "Чат"]
    var imgNameArray = ["1", "2","3","4", "5", "6","7", "8","9", "10","11", "12", "13","14", "15", "16","17", "18","19", "20", "21", "22", "23","24", "25", "26","27", "28","29", "30","31", "32", "33","34", "35", "36","37", "38","39", "40","41", "42", "43","44", "45"]
    
    let defaults = UserDefaults.standard
    
    @IBOutlet var viewCollectionImg: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        uploadView()
        checkUser()
        // Do any additional setup after loading the view.
    }
    func uploadView() {
        viewCollectionImg.dataSource = self
        viewCollectionImg.delegate   = self
    }
    
    ///DefaultsUser
    func checkUser() {
        userName = defaults.string(forKey: "userName") ?? ""
        imgName = defaults.string(forKey: "imgName") ?? "1"
        if userName.isEmpty == false {
            lblName.text = userName
        }
        if imgName.isEmpty == false {
            userWelcomeImg.image = UIImage(named: defaults.string(forKey: "imgName")!)
        }
    }
    /////////////////MARK: AlertFunction
    
    func changeNameModal() {
        
        if #available(iOS 8.0, *) {
            let loginAlert:UIAlertController = UIAlertController(title: "Имя", message: "Введите свое имя или ник", preferredStyle: .alert)
            
            loginAlert.addTextField(configurationHandler: {
                textfield in
                textfield.placeholder = "What is your name?"
            })
            
            
            loginAlert.addAction(UIAlertAction(title: "Go", style: .default, handler: {alertAction in
                let textFields:NSArray = loginAlert.textFields! as NSArray
                let usernameTextField:UITextField = textFields.object(at: 0) as! UITextField
                self.lblName.text = usernameTextField.text
                userName = usernameTextField.text!
                userName = userName.replacingOccurrences(of: " ", with: "_", options: NSString.CompareOptions.literal, range: nil)
                
                
                self.defaults.set(userName, forKey: "userName")
                
                
                if(userName == ""){
                    self.changeNameModal()
                }
                else{
                    print("******changing UUID to \(userName)")
                    nameChanged = true
                }
            }))
            
            self.present(loginAlert, animated: true, completion: nil)
        } else {
            // Fallback on earlier versions
        }
        
        
    }
    
    func showUserImg() {
        //let appDel = UIApplication.shared.delegate! as! AppDelegate
        
    }
    
    
    @IBAction func createNameBtnPressed(_ sender: AnyObject) {
        changeNameModal()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        imgName = ("\(imgNameArray[indexPath.row])")
        self.defaults.set(imgName, forKey: "imgName")
        userWelcomeImg.image = UIImage(named: imgNameArray[indexPath.row])
    }
    
    
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imgNameArray.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        let cell = viewCollectionImg.dequeueReusableCell(withReuseIdentifier: "CollectionCell", for: indexPath as IndexPath) as! imgCollectionCell
        cell.imgCollection.image = UIImage(named: imgNameArray[indexPath.row])
        
        
        return cell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    //    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    //        if let vcJSQ = segue.destination as? JSQMesVC {
    //            vcJSQ.senderDisplayName = userName
    //        }
    //    }
}
