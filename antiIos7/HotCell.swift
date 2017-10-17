//
//  HotCell.swift
//  antiIos7
//
//  Created by Polina on 11.10.17.
//  Copyright © 2017 Polina. All rights reserved.
//

import UIKit

class HotCell: UITableViewCell {

    @IBOutlet var imgKindOfNews: UIImageView!
    
    @IBOutlet var TitleOfNews: UILabel!
    
    @IBOutlet var countOfPosts: UILabel!
    
    @IBOutlet var addChatRoom: UIButton!
    
    @IBOutlet var resursLbl: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    

}
