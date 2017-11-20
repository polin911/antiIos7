//
//  JSQMesVC.swift
//  antiIos7
//
//  Created by Polina on 03.10.17.
//  Copyright © 2017 Polina. All rights reserved.
//

import Foundation
import JSQMessagesViewController
import PubNub
import UIKit
import AVKit
import MobileCoreServices
import Parse

class JSQMesVC: JSQMessagesViewController, PNObjectEventListener, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var parse        = Parse()
    var parseAntiIos = PFObject(className: "AntiIOS")
    var parseQuery   = PFQuery(className: "AntiIOS")
    
    var customToolBarView = NewViewWithButton()
    let picker = UIImagePickerController()
    
    var incomingJSQ = JSQMessagesCollectionViewCellIncoming()
    var outcominJSQ = JSQMessagesCollectionViewCellOutgoing()
    
    
    @IBOutlet var stickersCollection: UICollectionView!
    //Models:
    var messageModel = [MessageToJSQ]()
    
    //
    var appDel = UIApplication.shared.delegate as! AppDelegate
    var mediaAspect: JSQMessageMediaData!
    
    var stickBtn: JSQMessagesToolbarButtonFactory!
    ///
    var bubble = JSQMessagesBubbleImageFactory()
    let bubbleFactory = JSQMessagesBubbleImageFactory()
    ///////////////////////
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.backgroundColor = UIColor.black
        
        ////////
        view.addSubview(customToolBar!)
        
        //updateHistory()
        /////////
        
        self.title = chan
        self.senderId = userName
        self.senderDisplayName = userName
        automaticallyScrollsToMostRecentMessage = true
        
        print("!!!!!!!!!!!!!!!!!!SenderId!!!!!!!!!!!!!!!!!!:\(senderId)")
        print("!!!!!!!!!!!!!!!!!!SenderN!!!!!!!!!!!!!!!!!!:\(userName)")
        
        /////////////customCell
        self.collectionView.register(UINib(nibName: "messageViewIncoming", bundle: nil), forCellWithReuseIdentifier: "incomingCell")
        self.collectionView.register(UINib(nibName: "messageViewOutgoingCell", bundle: nil), forCellWithReuseIdentifier: "outgoingCell")
    }
    /// ButtonSticker
    
    func buttonStickerWork() {
        shouldPerformSegue(withIdentifier: "showStickersVC", sender: self)
    }
    func buttonStickApperiance() {
        let imageStick = UIImage(named:"smileStck" )
        //stickBtn.setImage(imageStick, for: .normal)
        //stickBtn
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //fetchParse()
        checkStickers()
        initPubNub()
        updateHistory()
        //fetchParse()
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.collectionView.collectionViewLayout.springinessEnabled = true
    }
    
    ////Collection
    func collectionUpload() {
        
        stickersCollection.delegate = self
        stickersCollection.dataSource = self
    }
    ///PubNub
    func initPubNub(){
        let appDel = UIApplication.shared.delegate! as! AppDelegate
        
        appDel.client?.unsubscribeFromChannels([chan], withPresence: true)
        appDel.client?.removeListener(self)
        
        let config = PNConfiguration( publishKey: "pub-c-8ecaf827-b81c-4d89-abf0-d669cf6da672", subscribeKey: "sub-c-a11d1bc0-ce50-11e5-bcee-0619f8945a4f")
        //config.uuid = userName
        appDel.client = PubNub.clientWithConfiguration(config)
        appDel.client?.addListener(self)
        self.joinChannel(chan)
    }
    
    deinit {
        let appDel = UIApplication.shared.delegate! as! AppDelegate
        
        appDel.client?.removeListener(self)
    }
    func joinChannel(_ channel: String){
        let appDel = UIApplication.shared.delegate! as! AppDelegate
        appDel.client?.subscribeToChannels([channel], withPresence: true)
        
        appDel.client?.hereNowForChannel(channel, withCompletion: { (result, status) in
            
            for ent in result?.data.uuids as! NSArray{
                let user = ((ent as! [String:String])["uuid"])!
                if !usersArray.contains(user){
                    usersArray.append(user)
                }
                
            }
            _ = result?.data.occupancy.stringValue
        })
        //updateHistory()
        
        guard let deviceToken   = UserDefaults.standard.object(forKey: "deviceToken") as? Data
            else {
                return
        }
        print("**********deviceToken is **** \(deviceToken)")
    }
    
    func updateHistory(){
        
        let appDel = UIApplication.shared.delegate! as! AppDelegate
        
        appDel.client?.historyForChannel(chan, start: nil, end: nil, includeTimeToken: true, withCompletion: { (result, status) in
            print("!!!!!!!!!Status: \(result)")
            guard let result = result else {
                return
            }
            self.messageModel = self.parseData(result.data.messages as! [NSDictionary] )
            self.collectionView.reloadData()
            //self.fetchParse()
            self.finishReceivingMessage()
            
            
            print("Stiiiiiiiiiiiiickkers \(imageSticker)")
            
        })
    }
    
    
    func gotoVCB(_ sender: UIButton) {
        let vc = StickersController4JSQ()
        vc.modalPresentationStyle = .custom
        present(vc, animated: true, completion: nil)
    }
    
    
    func client(_ client: PubNub, didReceiveMessage message: PNMessageResult) {
        print("******didReceiveMessage*****")
        print("from client!!!!!!!!!!!!!!!!!!!!!!!\(message.data)")
        print("*******UUID from message IS \(message.uuid)")
        
        guard let json  = message.data.message as? NSDictionary else {
            return
        }
        guard let readyMessage = parseData(["message" : json,
                                            "timetoken" : message.data.timetoken]) else {
                                                return
        }
        
        if let index = messageModel.index(where: { message -> Bool in readyMessage.idMes == message.idMes}) {
            messageModel.remove(at: index)
        }
        
        messageModel.append(readyMessage)
        collectionView.reloadData()
        finishReceivingMessage()
    }
    func getTime() -> String{
        let currentDate = Date()  // -  get the current date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm a" //format style to look like 00:00 am/pm
        let dateString = dateFormatter.string(from: currentDate)
        return dateString
    }
    
    ///AccessoryButton
    
    //    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
    //        picker.dismiss(animated: true, completion: nil)
    //        let picture = info[UIImagePickerControllerEditedImage] as? UIImage
    //
    //        if (info[UIImagePickerControllerEditedImage] as? UIImage) != nil
    //        {
    //
    //
    //            var media = CustomJSQPhotoMediaItem(image: picture)
    //            let mes = JSQMessage(senderId: userName, displayName: userName, media: media)
    //            guard let newMessage = mes else {return}
    //            ///
    //            let pubChat = MesJSQMedia(username: userName, image: imgName, imgSticker: imageSticker)
    //            let newDict = chatMessageToDictionarMedia(pubChat)
    //            appDel.client?.publish(newDict, toChannel: chan, compressed: true, withCompletion: nil)
    //
    //            mesModelJSQ.append(newMessage)
    //            finishReceivingMessage()
    //        }
    //
    //    }
    
    ///////////Stickers
    func checkStickers() {
        if imageSticker.isEmpty == false {
            
            let currentDate = Date()
            let newMes = MesJSQMedia(date: currentDate, idMes: NSUUID().uuidString , username: senderDisplayName, avatar: imgName, imgSticker: imageSticker)
            appDel.client?.publish(newMes.toDictionaryMessage(), toChannel: chan, withCompletion: nil)
            messageModel.append(newMes)
            finishReceivingMessage()
            imageSticker = ""
        }
        
    }
    
    ///////JSQ
    
    
    /////Nib
    let customToolBar = Bundle.main.loadNibNamed("NewViewWithButton", owner: self, options: nil)?.first as? NewViewWithButton
    
    
    ///////////ImagePicker
    private func chooseMedia(type: CFString) {
        picker.mediaTypes = [type as String]
        present(picker, animated: true, completion: nil)
    }
    override func didPressAccessoryButton(_ sender: UIButton!) {
        
        performSegue(withIdentifier: "showStickersVC", sender: self)
        
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion:nil)
    }
    
   
    //Parse
    func fetchParse() {

        parseQuery.findObjectsInBackground { (objects, error) in
            if error == nil {
                print("!!!!!!!!Successfully retrive \(objects?.count)")
                if let objects = objects {
                    for object in objects {
                        
                        //Date
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "dd-MM-yyyy HH:mm:ss.SSS"
                        let dateStr = dateFormatter.string(from: (object.createdAt as NSDate?)! as Date)
                        let currentD = dateFormatter.date(from: dateStr)
                        
        
                        let nickName = object["nick"] as? String ?? ""
                        let mesID    = object.objectId as? String ?? ""
                        print("date!!!!!\(dateStr)")
                       // let avatar   = object["avatar"] as? UIImage ?? #imageLiteral(resourceName: "s11")
                        print("!!!!!!!!nick \(nickName)")
                        let image    = object["image"]
//                        var newMes = MesJSQMediaImage(date: currentD!, idMes: mesID, username: nickName, avatar: imgName, img: "#imageLiteral(resourceName: "s15")")
                        //self.messageModel.append(newMes)
                        self.collectionView.reloadData()
                        self.finishReceivingMessage()
                    }
                }
            }
        }
//        if imageFromParse != nil {
//        let nickName    = parseAntiIos["nick"] as! String
//        let mesId       = parseAntiIos.objectId as! String
//        let currentDate = Date()
//
//        var newMes = MesJSQMediaImage(date: currentDate, idMes: mesId, username: nickName, avatar: imgName, img: imageFromParse)
//        messageModel.append(newMes)
//        finishReceivingMessage()
//        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickerImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            var imageFromImagePicker: UIImageView!
            var newPic = pickerImage
            guard newPic == pickerImage else { return }
            let currentDate = Date()
//            let newMes = MesJSQMediaImage(date: currentDate, idMes: NSUUID().uuidString, username: senderDisplayName, avatar: imgName, img: newPic)
//
            ////Parsing
            guard let imageData = UIImagePNGRepresentation(newPic) else {return}
            guard let imageFile = PFFile(data: imageData) else {return}
            let imageAvatar = UIImage(named: imgName) ?? #imageLiteral(resourceName: "s11")
            guard let avatarData = UIImagePNGRepresentation(imageAvatar) else {return}
            guard let avatarFile : PFFile = PFFile(data: avatarData) else {return}
            
            
            parseAntiIos["avatar"] = avatarFile
            parseAntiIos["image"]  = imageFile
            parseAntiIos["nick"]   = self.senderDisplayName
            
            parseAntiIos.saveInBackground(block: { (success, error) in
                if error == nil {
                    print("good stuf")
                }
                else {
                    print("Errorr!!!! \(error.debugDescription)")
                }
                
                let nickName    = self.parseAntiIos["nick"] as! String
                let mesId       = self.parseAntiIos.objectId as! String
                let currentDate = Date()
                
                var newMes = MesJSQMediaImage(date: currentDate, idMes: mesId, username: nickName, avatar: imgName, img: "photo0")
           
                self.appDel.client?.publish(newMes.toDictionaryMessage(), toChannel: chan, withCompletion: nil)
                self.messageModel.append(newMes)
                
                self.finishReceivingMessage()
                
              
                
            })
            
//            let parseImgObject = PFObject(className: "img")
//            parseImgObject["fileImg"]  = imageFile
//            parseImgObject["userName"] = self.senderDisplayName
//
//
//
//            parseImgObject.saveInBackground { (succes, error) in
//                print("Object has been saved.")
//                let objectId = parseImgObject.objectId
//                print("!!!!!!!!!!!\(objectId as! String)")
//            }
            
            
            
//            messageModel.append(newMes)
//            finishReceivingMessage()
        }
        dismiss(animated: true, completion: nil)
    }
    
    
    override func didPressAccessoryButton2(_ sender: UIButton!) {
        let picker = UIImagePickerController()
        picker.delegate = self
        if (UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary)) {
            picker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        }
        present(picker, animated: true, completion:nil)
    }
    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        var currentDate = Date()
        let newMes = MesJSQText(date: currentDate, idMes: NSUUID().uuidString, username: userName, textMes: text, avatar: imgName)
        appDel.client?.publish(newMes.toDictionaryMessage(), toChannel: chan, withCompletion: nil)
        messageModel.append(newMes)
        collectionView.reloadData()
        finishSendingMessage()
        
    }
    //0. когда мы создаем соообщение (json), мы указываем его тип (type = text, type = sticker, type = image)
    //1. можно использовать наследников от jsqmessage и ты туда сможешь напихать все что угодно, в том числе аватар, каритнку и т.д.
    //2. замутил бы там еще и тип сообщения
    //3. добавил бы для сообщений айдишку - let id = NSUUID().uuidString
    //4. когда сообщение пришло, проверить, есть ли сообщение с такой айдишкой в массиве и если есть уже, то удалить из массива и добавить то, которое от сервераъ
    //5. теперь будет легко проверить, что
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let message = self.messageModel[indexPath.item]
        var cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
        return cell
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellTopLabelAt indexPath: IndexPath!) -> CGFloat {
        return 30
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForCellTopLabelAt indexPath: IndexPath!) -> NSAttributedString! {
        let message = messageModel[indexPath.item]
        let mesTime = message.date
        let currentDate = mesTime
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm a"
        let dateString = dateFormatter.string(from: currentDate)
        
        return NSAttributedString(string: dateString)
        
    }
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messageModel.count
        
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        
        return messageModel[indexPath.item].jsqMessage
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        let buble = JSQMessagesBubbleImageFactory()
        let message = messageModel[indexPath.item]
        
        if senderDisplayName == message.jsqMessage.senderDisplayName {
            return buble?.outgoingMessagesBubbleImage(with: .red)
        } else {
            return buble?.incomingMessagesBubbleImage(with: .red)
        }
    }
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        
        var avatarMes  = messageModel[indexPath.item]
        var avatarImg  = avatarMes.avatar
        if avatarImg.isEmpty == false {
            var avatarName = UIImage(named: avatarImg)
            
            if senderDisplayName == avatarMes.jsqMessage.senderDisplayName {
                return JSQMessagesAvatarImageFactory.avatarImage(with: avatarName, diameter: 45)
            } else {
                if avatarImg.isEmpty == false {
                    return JSQMessagesAvatarImageFactory.avatarImage(with: avatarName, diameter: 45)
                } else {
                    return JSQMessagesAvatarImageFactory.avatarImage(with: #imageLiteral(resourceName: "s11"), diameter: 45) }
            }
        } else {
            return JSQMessagesAvatarImageFactory.avatarImage(with: #imageLiteral(resourceName: "s11"), diameter: 45)
        }
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForMessageBubbleTopLabelAt indexPath: IndexPath!) -> NSAttributedString! {
        let message = messageModel[indexPath.item]
        let mesUseeName = message.jsqMessage.senderDisplayName
        //        var nameUser = NSAttributedString(string: mesUseeName!)
        
        return NSAttributedString(string: mesUseeName!)
    }
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForMessageBubbleTopLabelAt indexPath: IndexPath!) -> CGFloat {
        return 30
    }
}

//Parse
extension JSQMesVC {
    
    func parseData (_ json: [NSDictionary]) -> [MessageToJSQ] {
        var list     = [MessageToJSQ]()
        for data in json {
            if let data = parseData(data) {
                list.append(data)
            }
            
        }
        return list
    }
    
    func parseData(_ data: NSDictionary) -> MessageToJSQ? {
        
        if  let message = data["message"] as? NSDictionary,
            let type = message["type"] as? String {
            switch type {
            case "text":
                let usernameJson = message["nick"] as? String ?? ""
                let textJson     = message["text"]  as? String ?? ""
                let imgJson      = message["avatar"] as? String ?? ""
                let idJson       = message["idMes"] as? String ?? ""
                var dataJs       = Date()
                if let date = data["timetoken"] as? Double {
                    dataJs = Date(timeIntervalSince1970: date / 10000000 )
                    
                }
                
                let newM = MesJSQText(date: dataJs, idMes: idJson, username: usernameJson, textMes: textJson, avatar: imgJson )
                return newM
                
                
            case "sticker" :
                let usernameJson = message["nick"] as? String ?? ""
                let imgJson      = message["avatar"] as? String ?? ""
                let stickJson    = message["stickers"] as? String ?? ""
                let idJson       = message["idMes"] as? String ?? ""
                var dataJs       = Date()
                if let date = data["timetoken"] as? Double {
                    dataJs = Date(timeIntervalSince1970: date / 10000000 )
                    
                }
                let newM = MesJSQMedia(date: dataJs, idMes: idJson, username: usernameJson, avatar: imgJson, imgSticker: stickJson)
                return newM
                
            case "image" :
                let usernameJson = message["nick"] as? String ?? ""
                let imgJson      = message["avatar"] as? String ?? ""
                let idJson       = message["idMes"] as? String ?? ""
                var dataJs       = Date()
                if let date = data["timetoken"] as? Double {
                    dataJs = Date(timeIntervalSince1970: date / 10000000 )
                }
                
                var photoJson = message["photo"] as? String ?? ""
//                if imageJson == "photo1" {
//              imageJson = "ok"
//                        print("Photttttooooosss!!!!!!!!!!")
//                    print("!!!!!!!!id \(imageJson)")
//                    print("photos:::::::::::::::\(parseAntiIos["image"])")
//                    
//  
//                }
                let newM = MesJSQMediaImage(date: dataJs, idMes: idJson, username: usernameJson, avatar: imgJson, img: photoJson)
                return newM
            default :
                return nil
            }
        }
        return  nil
    }
}
//For Media
class CustomJSQPhotoMediaItem: JSQPhotoMediaItem {
    override init!(image: UIImage!) {
        super.init(image: image)
        
    }
    // imageView.contentMode = UIViewContentModeScaleAspectFill;
    // imageView.frame = CGRectMake(0.0f, 0.0f, size.width, size.height);
    override init!(maskAsOutgoing: Bool) {
        super.init(maskAsOutgoing: maskAsOutgoing)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    override func mediaViewDisplaySize() -> CGSize {
        let ratio = self.image.size.height / self.image.size.width
        let w = min(UIScreen.main.bounds.width * 0.8, self.image.size.width)
        let h = w * ratio
        return CGSize(width: w, height: h)
    }
    
    
}

//




