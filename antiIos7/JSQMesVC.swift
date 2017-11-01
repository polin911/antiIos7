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

class JSQMesVC: JSQMessagesViewController, PNObjectEventListener, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let picker = UIImagePickerController()
    
    var incomingJSQ = JSQMessagesCollectionViewCellIncoming()
    var outcominJSQ = JSQMessagesCollectionViewCellOutgoing()
    
    @IBOutlet var stickersCollection: UICollectionView!
    //Models:
    var messageModel = [MessageToJSQ]() {
        didSet {
            print("changed Pubnub \(messageModel.count + oldValue.count)")
        }
    }
    var mesModelJSQ = [JSQMessage](){
        didSet {
            print("changed JSQ \(mesModelJSQ.count + oldValue.count)")
        }
    }
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
        checkStickers()
        initPubNub()
        updateHistory()
        
        
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
        config.uuid = userName
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
            // self.mesModelJSQ = self.parseDataAny(result.data.messages as [AnyObject])
            //            self.messageModel = self.parseJsonDataAny(result.data.messages as [AnyObject])
            // self.collectionView.reloadData()
            self.finishReceivingMessage()
            
            print("Stiiiiiiiiiiiiickkers \(imageSticker)")
            
        })
    }
    
    ///////////Stickers
    
    func checkStickers() {
        if imageSticker.isEmpty == false {
            
//            let pubChat = MesJSQMedia(username: userName, image: imgName, imgSticker: imageSticker)
//            let newDict = chatMessageToDictionarMedia(pubChat)
//            appDel.client?.publish(newDict, toChannel: chan, compressed: true, withCompletion: nil)
            
//            var media = CustomJSQPhotoMediaItem(image: UIImage(named: imageSticker))
//            let mes = JSQMessage(senderId: userName, displayName: userName, media: media)
//            guard let newMessage = mes else {return}
//
//            mesModelJSQ.append(newMessage)
            finishReceivingMessage()
            // collectionView.reloadData()
        }
        //imageSticker = ""
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
        
        guard let stringData  = message.data.message as? NSDictionary else {
            return
        }
        
//        guard  let readyMessage = parseData(stringData) else{
//            return
//        }
//        guard let readyJsonMes = parseJsonMessage(stringData) else {
//            return
//        }
        //выдираем айдишку из сообщения
        //если в твоем массиве из сообщений уже есть такое с такой айдишкой, то ты то сообщение удяляешь
    //    messageModel.append(readyJsonMes)
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
    
    
    private func chooseMedia(type: CFString) {
        picker.mediaTypes = [type as String]
        present(picker, animated: true, completion: nil)
    }
    
    
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
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion:nil)
    }
    
    override func didPressAccessoryButton2(_ sender: UIButton!) {
        let picker = UIImagePickerController()
        picker.delegate = self
        if (UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary)) {
            picker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        }
        
        present(picker, animated: true, completion:nil)
        
    }
    
    
    
    ///////JSQ
    override func didPressAccessoryButton(_ sender: UIButton!) {
        
        performSegue(withIdentifier: "showStickersVC", sender: self)
        
    }
  
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        
        
        //for PubNub
        // let pubChat = MesJSQText(username: senderDisplayName, textMes: text, image: imgName)
        //        var newDict = chatMessageToDictionaryMessage(pubChat)
        ////        newDict["id"] = id
        //        appDel.client?.publish(newDict, toChannel: chan, compressed: true, withCompletion: nil)
        //For JSq
        //        let mes = JSQMessage(senderId: senderId, displayName: senderDisplayName, text: text)
        //            guard let newMessage = mes else {return}
        //            mesModelJSQ.append(newMessage)
        collectionView.reloadData()
        finishSendingMessage()
        
    }
    //0. когда мы создаем соообщение (json), мы указываем его тип (type = text, type = sticker, type = image)
    //1. можно использовать наследников от jsqmessage и ты туда сможешь напихать все что угодно, в том числе аватар, каритнку и т.д.
    //2. замутил бы там еще и тип сообщения
    //3. добавил бы для сообщений айдишку - let id = NSUUID().uuidString
    //4. когда сообщение пришло, проверить, есть ли сообщение с такой айдишкой в массиве и если есть уже, то удалить из массива и добавить то, которое от сервераъ
    //5. теперь будет легко проверить, что
    
    
    
//    func sendSomeTypeOfMessagePressed(){
//        
//        let text = MesJSQText(username: "dgdsgds", textMes: "text", avatar: "itweewuwieewote")
//        //let stiker
//        //let image
//
//
//        let json = text.toDictionaryMessage()
//        
//        appDel.client?.publish(json, toChannel: chan, compressed: true, withCompletion: nil)
//    }
//    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let message = self.mesModelJSQ[indexPath.item]
        var cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
        
        return cell
        
        
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellTopLabelAt indexPath: IndexPath!) -> CGFloat {
        return 30
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForCellTopLabelAt indexPath: IndexPath!) -> NSAttributedString! {
        let message = mesModelJSQ[indexPath.item]
        let mesTime = message.date
        let currentDate = mesTime  // -  get the current date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm a" //format style to look like 00:00 am/pm
        let dateString = dateFormatter.string(from: currentDate!)
        
        return NSAttributedString(string: dateString)
        
    }
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return mesModelJSQ.count
        
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        
        return mesModelJSQ[indexPath.item]
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        let buble = JSQMessagesBubbleImageFactory()
        let message = mesModelJSQ[indexPath.item]
        
        if senderId == message.senderId {
            return buble?.outgoingMessagesBubbleImage(with: .red)
        } else {
            return buble?.incomingMessagesBubbleImage(with: .red)
        }
    }
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        
        //        var avatarMes = messageModel[indexPath.item]
        //        var newAvatar = avatarMes.image
        //        let message = mesModelJSQ[indexPath.item]
        //        var imageName = UIImage(named: newAvatar)
        //        if senderDisplayName == message.senderDisplayName {
        //            return JSQMessagesAvatarImageFactory.avatarImage(with: imageName, diameter: 45)
        //        } else {
        //            if newAvatar.isEmpty == false {
        //            return JSQMessagesAvatarImageFactory.avatarImage(with: imageName, diameter: 45)
        //
        //            } else {
        //                return JSQMessagesAvatarImageFactory.avatarImage(with: #imageLiteral(resourceName: "s11"), diameter: 45)
        //        }
        //        }
        // collectionView.reloadData()
        return nil
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForMessageBubbleTopLabelAt indexPath: IndexPath!) -> NSAttributedString! {
        let message = mesModelJSQ[indexPath.item]
        let mesUseeName = message.senderDisplayName
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
        var newMes   : MessageToJSQ
      
        if let type = data["type"] as? String {
            switch type {
            case "text":
                let usernameJson = data["username"] as? String ?? ""
                let textJson     = data["text"]  as? String ?? ""
                let imgJson      = data["avatar"] as? String ?? ""
                let idJson       = data["id"] as? String ?? ""
                
                 let newM = MesJSQText(idMes: idJson, username: usernameJson, textMes: textJson, avatar: imgJson )
                return newM
                
                
            case "sticker" :
                let usernameJson = data["username"] as? String ?? ""
                let textJson     = data["text"]  as? String ?? ""
                let imgJson      = data["avatar"] as? String ?? ""
                let stickJson    = data["stickers"] as? String ?? ""
                let idJson       = data["id"] as? String ?? ""
                let newM = MesJSQMedia(idMes: idJson, username: usernameJson, avatar: imgJson, imgSticker: stickJson)
                return newM
                
            default :
               return nil
                
                
            }
        }
        //    func parseDataAny(_ any: [AnyObject] ) -> [JSQMessage] {
        //        var list = [JSQMessage]()
        //        for data in any {
        //            if let data = data as? NSDictionary,
        //                let messageData = data["message"] as? NSDictionary,
        //                let message = parseData(messageData){
        //                list.append(message)
        //            }
        //        }
        //        return list
        //    }
        //
        //    func parseData(_ data: NSDictionary) -> JSQMessage? {
        //
        //        let stringData    = data
        //        let stringName    = stringData["username"] as? String ?? ""
        //       // let stringTime    = stringData["time"] as? String ?? ""
        //        let stringImg     = stringData["image"] as? String ?? ""
        //        var newMessage: JSQMessage?
        //
        //        if  let stringSticker = stringData["stickers"] as? String ,
        //            stringSticker.isEmpty == false {
        //
        //            let imgForJSq = UIImage(named: stringSticker)
        //            let phoForJSQ = JSQPhotoMediaItem(image: imgForJSq)
        //            newMessage = JSQMessage(senderId: stringName, displayName: stringName, media: phoForJSQ)
        //        } else if let stringText = stringData["text"] as? String {
        //            newMessage = JSQMessage(senderId: stringName, displayName: stringName, text: stringText)
        //        }
        //        guard let readyMessage = newMessage else {
        //            return nil
        //        }
        //        return readyMessage
        //    }
        //    func parseJsonDataAny(_ any: [AnyObject] ) -> [MesJSQ] {
        //        var list = [MesJSQ]()
        //        for data in any {
        //            if let data = data as? NSDictionary,
        //                let messageData = data["message"] as? NSDictionary,
        //                let message = parseJsonMessage(messageData){
        //                list.append(message)
        //            }
        //        }
        //        return list
        //    }
        //    func parseJsonMessage(_ data: NSDictionary) -> MesJSQ? {
        //        var newMessage : MesJSQ?
        //                let json = data
        //
        //                let usernameJson = json["username"] as? String ?? "" // to get rid of null
        //                let textJson     = json["text"]  as? String ?? ""
        //                let imgJson      = json["image"] as? String ?? ""
        //                let imgStickerJ  = json["stickers"] as? String ?? ""
        //        newMessage = MesJSQ(username: usernameJson, textMes: textJson,image: imgJson, stick: imgStickerJ)
        //        guard let readyMes = newMessage else {return nil}
        //        return readyMes
        //
        //
        //    }
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




