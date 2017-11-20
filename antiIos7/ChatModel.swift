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
            "idMes" : NSString(string:self.idMes),
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
struct MesJSQMediaImage: MessageToJSQ {
    var jsqMessage: JSQMessage {
        var media : JSQPhotoMediaItem!

        
//        let imageFile = parseAntiIos["image"]  as? PFFile
//        imageFile?.getDataInBackground(block: { (imageData, error) in
//            if error == nil {
//                if let imageData = imageData {
//                    let image = UIImage(data: imageData)
//                    imageJson = "6"
//
//                }
//            }
//        })
        
//        print("ID Mes^^^^^^^^^^\(idMes)")
//       // if parseObject.objectId == idMes {
//            parseObject.objectId = idMes
//        let imageFile = parseObject["image"] as! PFFile
//        imageFile.getDataInBackground { (imageData, error) in
//            if error == nil {
//                let image = UIImage(data: imageData!)
//                 media = JSQPhotoMediaItem(image: image)
//            }
//        }
//        } else {
//
//         media = JSQPhotoMediaItem(image: #imageLiteral(resourceName: "s3"))
//        }
            //(data: dataImg!))
        print("\(img)")
        if img == "photo0" {
        
        parseQuery.findObjectsInBackground { (objects, error) in
            if error ==  nil {
                print("!!!!!!!!Successfully retrive \(objects?.count)")
                if let objects = objects {
                    for object in objects {
                        if object.objectId == self.idMes {
                        let imageFile = object["image"] as! PFFile
                        imageFile.getDataInBackground(block: { (imageData, error) in
                            if error == nil {
                                let image = UIImage(data: imageData!)
                                media = JSQPhotoMediaItem(image: image)
                            }
                        })
                    }
                        else {
                            media = JSQPhotoMediaItem(image: #imageLiteral(resourceName: "s5"))
                        }
                    }
                  
                }
            }
            else {
                print("Errrrrrror \(error.debugDescription)")
            }
        }
        } else {
            media = JSQPhotoMediaItem(image: #imageLiteral(resourceName: "s6"))
        }
        let message = JSQMessage(senderId: username, displayName: username, media: media, idMes: idMes)
        return message!
    }
    func toDictionaryMessage() -> [String : Any] {
        return [
            "idMes" : NSString(string:self.idMes),
            "type"  : self.type.rawValue,
            "nick"  : NSString(string: self.username),
            "photo" : NSString(string: self.img),
            "avatar": NSString(string: self.avatar)
        ]
    }
    var date: Date
    var idMes: String
    var username: String
    var avatar  : String
    var img : String
    let type: MessageType = .image
   // var imgString : String
}

