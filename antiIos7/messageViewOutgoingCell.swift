//
//  messageViewOutgoingCell.swift
//  antiIos7
//
//  Created by Polina on 06.10.17.
//  Copyright © 2017 Polina. All rights reserved.
//
import JSQMessagesViewController
import UIKit

class messageViewOutgoingCell: JSQMessagesCollectionViewCellOutgoing {
    @IBOutlet var timeLbl: UILabel!
    @IBOutlet var chatNameLbl: UILabel!
    @IBOutlet var chatTxtLbl: UILabel!
    @IBOutlet var chatImage: UIImageView!
    
    @IBOutlet var imgSticker: UIImageView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }


}
