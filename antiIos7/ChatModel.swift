//
//  ChatModel.swift
//  antiIos7
//
//  Created by Polina on 02.10.17.
//  Copyright © 2017 Polina. All rights reserved.
//

var parseObject  = PFObject(className: "AntiIOS")
var parseQuery   = PFQuery(className: "AntiIOS")
import Foundation
import JSQMessagesViewController
import Parse


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
    var date: Date{get}
    var avatar : String {get}
    func toDictionaryMessage()->[String:Any]
}


struct MesJSQMedia: MessageToJSQ {
    var jsqMessage: JSQMessage {
        let media = JSQPhotoMediaItem(image: UIImage(named:imgSticker))
        var message = JSQMessage(senderId: username, displayName: username, media: media, idMes: idMes)
        return message!
    }
    func toDictionaryMessage() -> [String : Any] {
        return [
            "idMesPubNub" : NSString(string:self.idMes),
            "type"  : self.type.rawValue,
            "nick"  : NSString(string: self.username),
            "stickers" : NSString(string: self.imgSticker),
            "avatar": NSString(string: self.avatar)
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
        let message = JSQMessage(senderId: username, displayName: username, text: textMes, idMes: idMes)
        //guard
        return message!
    }
    
    func toDictionaryMessage() -> [String : Any] {
        return [
            "idMesPubNub"   : NSString(string:self.idMes),
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
struct MesJSQMediaImage: MessageToJSQ {
    
    private var loadImage = false
    
    init(date: Date, idMes: String,username: String, avatar: String, photoId : String) {
        self.date     = date
        self.idMes    = idMes
        self.username = username
        self.avatar   = avatar
        self.photoId  = photoId
    }
    
    func getImageWith(completion: @escaping(UIImage) -> Void) {
        if self.photoId.isEmpty == false {
            let query = PFQuery(className: "AntiIOS")
            query.whereKey("objectId", equalTo: self.photoId)
            query.getFirstObjectInBackground(block: { (object, error) in
                    guard let fileObject = object?["image"] as? PFFile else {return}
                    fileObject.getDataInBackground(block: { (data, error) in
                        guard error == nil else {return}
                        guard let data = data else {return}
                        guard let image = UIImage(data: data) else {return}
                        completion(image)
                    })
                
            })
        }
    }
    var jsqMessage: JSQMessage {
        let media = JSQPhotoMediaItem(image: #imageLiteral(resourceName: "s6"))
        let message = JSQMessage(senderId: username, displayName: username, media: media, idMes: idMes)
        return message!
    }
    func toDictionaryMessage() -> [String : Any] {
        return [
            "idMesPubNub" : NSString(string:self.idMes),
            "type"  : self.type.rawValue,
            "nick"  : NSString(string: self.username),
            "photo" : NSString(string: self.photoId),
            "avatar": NSString(string: self.avatar)
        ]
    }
    var date: Date
    var idMes: String
    var username: String
    var avatar  : String
    var photoId : String
    let type: MessageType = .image
    
}

