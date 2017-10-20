//
//  ChatModel.swift
//  antiIos7
//
//  Created by Polina on 02.10.17.
//  Copyright © 2017 Polina. All rights reserved.
//

import Foundation
import JSQMessagesViewController

struct ChatMessage {
    
    var username: String
    var text    : String
    var time    : String
    var image   : String
    var imgSticker: String
}

struct MesJSQ {
    var username: String
    var textMes : String
    var time    : String
    var image   : String
    var imgSticker :String
    
//    init(userN: String, textMes: String, time: String, image: String ) {
//        self.username = userN
//        self.textMes  = textMes
//        self.time     = time
//        self.image    = image
//    }
//
//    func senderId() -> String! {
//        let appDel = UIApplication.shared.delegate as! AppDelegate!
//        let str = appDel?.client?.uuid()
//        return str
//    }
//    func senderDisplayName() -> String! {
//        return username
//    }
//    func date() -> Date! {
//        let currentDate = Date()  // -  get the current dateb
//        return currentDate
//    }
//
//    func isMediaMessage() -> Bool {
//       return false
//    }
//    func messageHash() -> UInt {
//       return 0
//    }
//
    
}


func chatMessageToDictionary(_ chatmessage: MesJSQ) -> [String: AnyObject]{
    return [
        "username": NSString(string: chatmessage.username),
        "text"    : NSString(string: chatmessage.textMes),
        "time"    : NSString(string: chatmessage.time),
        "image"   : NSString(string: chatmessage.image),
        "stickers": NSString(string: chatmessage.imgSticker)
        
    ]
}

var chatMesArray2 : [MesJSQ]  = []
