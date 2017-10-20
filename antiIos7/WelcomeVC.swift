//
//  WelcomeVC.swift
//  antiIos7
//
//  Created by Polina on 02.10.17.
//  Copyright © 2017 Polina. All rights reserved.
//

import UIKit

class WelcomeVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet var userWelcomeImg: UIImageView!
    var menuItems = ["Имя", "Чат"]
    var imgNameArray = ["1.png", "2.png", "3.png","4.png", "5.png", "6.png","7.png", "8.png","9.png", "10.png","11.png", "12.png", "13.png","14.png", "15.png", "16.png","17.png", "18.png","19.png", "20.png", "21.png", "22.png", "23.png","24.png", "25.png", "26.png","27.png", "28.png","29.png", "30.png","31.png", "32.png", "33.png","34.png", "35.png", "36.png","37.png", "38.png","39.png", "40.png","41.png", "42.png", "43.png","44.png", "45.png"]
    
    
    
    @IBOutlet var viewCollectionImg: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        uploadView()
        // Do any additional setup after loading the view.
    }
    func uploadView() {
        viewCollectionImg.dataSource = self
        viewCollectionImg.delegate   = self
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
                                                userName = usernameTextField.text!
                                                userName = userName.replacingOccurrences(of: " ", with: "_", options: NSString.CompareOptions.literal, range: nil)
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
    
//
//    func changeChatModal() {
//        let appDel = UIApplication.shared.delegate! as! AppDelegate
//        appDel.client?.unsubscribeFromChannels([chan], withPresence: true)
//
//
//        if #available(iOS 8.0, *) {
//            let loginAlert:UIAlertController = UIAlertController(title: "Телепортироваться в другой чат", message: "Введите название чатп", preferredStyle: UIAlertControllerStyle.alert)
//            loginAlert.addTextField(configurationHandler: {
//                textfield in
//                textfield.placeholder = "подписать меня на чат: _____"
//            })
//
//            loginAlert.addAction(UIAlertAction(title: "Go", style: UIAlertActionStyle.default, handler: {alertAction in
//                let textFields:NSArray = loginAlert.textFields! as NSArray
//                let usernameTextField:UITextField = textFields.adding(0) as! UITextField
//                chan = usernameTextField.text!
//                if(chan == ""){
//                    self.changeChatModal()
//                }
//                else{
//                    chatMesArray = []
//                    usersArray = []
//                    appDel.client?.subscribeToChannels([chan], withPresence: true)
//                }
//            }))
//
//            self.present(loginAlert, animated: true, completion: nil)
//        } else {
//            // Fallback on earlier versions
//        }
//
//
//    }
    
    func showUserImg() {
        //let appDel = UIApplication.shared.delegate! as! AppDelegate
        
    }
    
    
    @IBAction func createNameBtnPressed(_ sender: AnyObject) {
        changeNameModal()
    }
    
    
    
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        imgName = ("\(imgNameArray[indexPath.row])")
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
}
