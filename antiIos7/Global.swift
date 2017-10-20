//
//  Global.swift
//  antiIos7
//
//  Created by Polina on 02.10.17.
//  Copyright © 2017 Polina. All rights reserved.
//

import Foundation
import JSQMessagesViewController
var chatMesArray :[ChatMessage]  = []
var usersArray   :[String]       = []




var userName    = ""
var nameChanged = false
var chan        = "antichat_hackathon"
var imgName     = "1.png"
var imageSticker  = ""


func chatMessageToDictionary(_ chatmessage: ChatMessage) -> [String: NSString]{
    return [
        "username": NSString(string: chatmessage.username),
        "text"    : NSString(string: chatmessage.text),
        "time"    : NSString(string: chatmessage.time),
        "image"   : NSString(string: chatmessage.image),
        "stickers": NSString(string: chatmessage.imgSticker)
    ]
}
func chatMesToDicJSQ(_ chatmessage: MesJSQ) -> [String: NSString]{
    return [
        "username": NSString(string: chatmessage.username),
        "text"    : NSString(string: chatmessage.textMes),
        "time"    : NSString(string: chatmessage.time),
        "image"   : NSString(string: chatmessage.image),
        "stickers": NSString(string: chatmessage.imgSticker)
    ]
    
}
