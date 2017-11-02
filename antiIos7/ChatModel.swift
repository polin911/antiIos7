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
    
    //var type:MessageType
    var username: String
    var text    : String
    var time    : String
    var image   : String
    var imgSticker: String
}

//////////////////////////////////
enum MessageType: String {
    case sticker = "sticker"
    case text    = "text"
    case image   = "image"
}

protocol MessageToJSQ {
    var type:MessageType {get}
    var idMes:String     {get}
    var jsqMessage:JSQMessage {get}
    func toDictionaryMessage()->[String:Any]
    var date: Date{get}
}

struct MesJSQMedia: MessageToJSQ {
    var jsqMessage: JSQMessage {
    let media = JSQPhotoMediaItem(image: UIImage(named:avatar))
    var message = JSQMessage(senderId: username, displayName: username, media: media, idMes: idMes, avatar: avatar)
    return message!
    }
    func toDictionaryMessage() -> [String : Any] {
        return [
            "idMes"   : NSString(string:self.idMes),
            "type"    : self.type.rawValue,
            "nick": NSString(string: self.username),
            "image"   : NSString(string: self.avatar),
            "avatar": NSString(string: self.imgSticker)
        ]
    }
    var date: Date
    var idMes: String
    var username: String
    var avatar  : String
    var imgSticker :String
    let type: MessageType = .sticker
}


struct MesJSQText:MessageToJSQ {
    var date: Date
    
    var jsqMessage: JSQMessage  {
        let message = JSQMessage(senderId: username, displayName: username, text: textMes, idMes: idMes, avatar: avatar)
        //guard
        return message!
    }
    
func toDictionaryMessage() -> [String : Any] {
        return [
            "idMes"   : NSString(string:self.idMes),
            "type"    : self.type.rawValue,
            "nick"    : NSString(string: self.username),
            "text"    : NSString(string: self.textMes),
            "avatar"  : NSString(string: self.avatar)
        ]
    }
    let type:MessageType = .text
    var idMes   : String
    var username: String
    var textMes : String
    var avatar  : String

}

