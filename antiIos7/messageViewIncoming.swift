//
//  messageViewIncoming.swift
//  antiIos7
//
//  Created by Polina on 06.10.17.
//  Copyright © 2017 Polina. All rights reserved.
//

import UIKit
import JSQMessagesViewController

class messageViewIncoming: JSQMessagesCollectionViewCellIncoming {

    
     @IBOutlet weak var timeLabel: UILabel!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
