//
//  FileFORNibView.swift
//  antiIos7
//
//  Created by Polina on 09.11.17.
//  Copyright © 2017 Polina. All rights reserved.
//

import Foundation
import UIKit
import JSQMessagesViewController

class NewViewWithButton : UIView {
    
    @IBAction func LogOutBtn(_ sender: Any) {
        infoClick()
     print("Hello!!!!!!!!!!!!!!!!!")
    }

        
        var vc2: UIViewController!
        var welcomeVC =  WelcomeVC()
        
//        @IBOutlet var btnLogOutOutlet: UIButton!
    
        
        
        func infoClick()  {
            
            let storyboard: UIStoryboard = UIStoryboard (name: "Main", bundle: nil)
            let vc: UIViewController = storyboard.instantiateViewController(withIdentifier: "WelcomeVC")
            let currentController = self.getCurrentViewController()
            currentController?.present(vc, animated: true, completion: nil)
            
            
        }
        
        func getCurrentViewController() -> UIViewController? {
            if let rootController = UIApplication.shared.keyWindow?.rootViewController {
                var currentController: UIViewController! = rootController
                while( currentController.presentedViewController != nil ) {
                    currentController = currentController.presentedViewController
                }
                return currentController
            }
            return nil
            
        }
        

    

}
