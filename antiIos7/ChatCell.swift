//
//  ChatCell.swift
//  antiIos7
//
//  Created by Polina on 02.10.17.
//  Copyright © 2017 Polina. All rights reserved.
//

import UIKit

class ChatCell: UITableViewCell {
    
    @IBOutlet var timeLbl: UILabel!
    @IBOutlet var chatNameLbl: UILabel!
    @IBOutlet var chatTxtLbl: UILabel!
    @IBOutlet var chatImage: UIImageView!
    
    @IBOutlet var imgSticker: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
