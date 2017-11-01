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
enum MessageType {
    case sticker
    case text
    case image
}

protocol MessageToJSQ {
    var type:MessageType {get}
    var idMes:String     {get}
    var jsqMessage:JSQMessage {get}
    func toDictionaryMessage()->[String:Any]
}

struct MesJSQMedia:MessageToJSQ {
    var idMes: String
    var jsqMessage: JSQMessage
    func toDictionaryMessage() -> [String : Any] {
        return [
            "idMes"   : NSString(string:self.idMes),
            "type"    : self.type as AnyObject,
            "username": NSString(string: self.username),
            "image"   : NSString(string: self.avatar),
            "stickers": NSString(string: self.imgSticker)
        ]
    }
    var username: String
    var avatar  : String
    var imgSticker :String
    let type: MessageType = .sticker
    
    lazy var jsqMes:JSQMessage = {
        let media = JSQPhotoMediaItem(image: UIImage(named:avatar))
        var message = JSQMessage(senderId: username, displayName: username, media: media, idMes: idMes, avatar: avatar)
        return message!
    }()
    
}


struct MesJSQText:MessageToJSQ {
    var jsqMessage: JSQMessage
    
    func toDictionaryMessage() -> [String : Any] {
        return [
            "idMes"   : NSString(string:self.idMes),
            "type"    : self.type,
            "username": NSString(string: self.username),
            "text"    : NSString(string: self.textMes),
            "image"   : NSString(string: self.avatar)
        ]
    }
    let type:MessageType = .text
    var idMes   : String
    var username: String
    var textMes : String
    var avatar  : String
    lazy var jsqMes:JSQMessage = {
        let message = JSQMessage(senderId: userName, displayName: userName, text: textMes, idMes: idMes, avatar: avatar)
       //guard
        return message!
    }()
}

func chatMessageToDictionaryMessage(_ chatmessage: MesJSQText) -> [String: AnyObject]{
   return [
        "id"      : NSString(string:chatmessage.idMes),
        "type"    : chatmessage.type as AnyObject,
        "username": NSString(string: chatmessage.username),
        "text"    : NSString(string: chatmessage.textMes),
        "image"   : NSString(string: chatmessage.avatar)
        
    ]
}
//func chatMessageToDictionary(_ chatmessage: MesJSQ) -> [String: AnyObject]{
//    return [
//        "username": NSString(string: chatmessage.username),
//        "text"    : NSString(string: chatmessage.textMes),
//        "image"   : NSString(string: chatmessage.image),
//        "stickers": NSString(string: chatmessage.stick)
//    ]
//}
func chatMessageToDictionarMedia(_ chatmessage: MesJSQMedia) -> [String: AnyObject]{
    return [
        "id"      : NSString(string:chatmessage.idMes),
        "type"    : chatmessage.type as AnyObject,
        "username": NSString(string: chatmessage.username),
        "image"   : NSString(string: chatmessage.avatar),
        "stickers": NSString(string: chatmessage.imgSticker)
        
    ]
}

//struct MesJSQ:MessageToJSQ {
//    var username: String
//    var textMes : String
//    var image   : String
//    var stick   : String
//
//}
//var chatMesArray2 : [MesJSQ]  = []

