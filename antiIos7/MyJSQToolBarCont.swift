//
//  MyJSQToolBarCont.swift
//  antiIos7
//
//  Created by Polina on 07.11.17.
//  Copyright © 2017 Polina. All rights reserved.
//

import UIKit
import JSQMessagesViewController

class MyJSQToolBarCont: UIView  {
    
    
//    override func loadContentView() -> JSQMessagesToolbarContentView! {
//        let nib = Bundle.main.loadNibNamed(String(describing: MyJSQInputToolBarContent.self ), owner: self, options: nil)
//        return nib?.first as? MyJSQInputToolBarContent
//    }
    @IBOutlet var myMessageToolbar: UIView!
    
    @IBOutlet var buttonPizza: UIButton!
    //    required init?(coder aDecoder: NSCoder) {
//    super.init(coder: aDecoder)
//        UINib(nibName: "MyJSQToolBarCont", bundle: nil).instantiate(withOwner: self, options: nil)
//        
//    }
}
