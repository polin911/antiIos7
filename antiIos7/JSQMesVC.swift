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

class JSQMesVC: JSQMessagesViewController, PNObjectEventListener {

    var messageModel = [MesJSQ]()
    var mesModelJSQ = [JSQMessage]()
    var appDel = UIApplication.shared.delegate as! AppDelegate

    
    ///
    var bubble = JSQMessagesBubbleImageFactory()
    var avatars = Dictionary<String, UIImage>()
    let bubbleFactory = JSQMessagesBubbleImageFactory()
   ///////////////////////
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = chan
        self.senderId = userName
        self.senderDisplayName = userName
        
        print("!!!!!!!!!!!!!!!!!!SenderId!!!!!!!!!!!!!!!!!!:\(senderId)")
        print("!!!!!!!!!!!!!!!!!!SenderN!!!!!!!!!!!!!!!!!!:\(userName)")
       
        /////////////customCell
        self.collectionView.register(UINib(nibName: "messageViewIncoming", bundle: nil), forCellWithReuseIdentifier: "incomingCell")
        self.collectionView.register(UINib(nibName: "messageViewOutgoingCell", bundle: nil), forCellWithReuseIdentifier: "outgoingCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        initPubNub()
        updateTableview()
    }
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        self.collectionView.collectionViewLayout.springinessEnabled = true

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
        updateHistory()
 
        guard let deviceToken   = UserDefaults.standard.object(forKey: "deviceToken") as? Data
            else {
                return
        }
        print("**********deviceToken is **** \(deviceToken)")
    }
    
    func parseJson(_ anyObj:AnyObject) -> [MesJSQ]{
        
        var list:[MesJSQ] = []
        
        if  anyObj is [AnyObject] {
            
            for jsonMsg in anyObj as! [AnyObject] {
                let json = jsonMsg["message"] as? NSDictionary
               
                let usernameJson = (json?["username"] as AnyObject? as? String) ?? "" // to get rid of null
                let textJson   = (json?["text"]  as AnyObject? as? String) ?? ""
                let timeJson   = (json?["time"]  as AnyObject? as? String) ?? ""
                let imgJson    = (json?["image"] as AnyObject as? String) ?? ""
                let imgStickerJ  = (json?["stickers"] as AnyObject? as? String) ?? ""
                
                list.append(MesJSQ(username: usernameJson, textMes: textJson, time: timeJson, image: imgJson, imgSticker: imgStickerJ))
            }
            collectionView.reloadData()
            
        }
        
        return list
        
    }
    func updateHistory(){
        
        let appDel = UIApplication.shared.delegate! as! AppDelegate
        
        appDel.client?.historyForChannel(chan, start: nil, end: nil, includeTimeToken: true, withCompletion: { (result, status) in
            print("!!!!!!!!!Status: \(result)")
            
            
           // chatMesArray2 = self.parseJson(result!.data.messages as AnyObject)
            self.mesModelJSQ = self.parseJsonforJSq(result?.data.messages as AnyObject)
            self.updateTableview()
            
        })
    }
    func updateTableview(){
        self.collectionView.reloadData()
//        if self.collectionView.contentSize.height > self.collectionView.frame.size.height {
//            collectionView.scrollToItem(at: IndexPath(row: chatMesArray2.count - 1, section: 0), at: UICollectionViewScrollPosition.bottom, animated: true)
       // }
    }
    func updateChat(){
        collectionView.reloadData()
        
        let numberOfSections = collectionView.numberOfSections
        let numberOfRows = collectionView.numberOfItems(inSection: numberOfSections-1)
        
        if numberOfRows > 0 {
            let indexPath = IndexPath(row:numberOfRows - 1, section:numberOfSections - 1)
            
            //IndexPath(forRow: numberOfRows-1, inSection: (numberOfSections-1))
            collectionView.scrollToItem(at: indexPath, at: .bottom,
                                      animated: true)
        }
    }
    func client(_ client: PubNub, didReceiveMessage message: PNMessageResult) {
        print("******didReceiveMessage*****")
        print("from client!!!!!!!!!!!!!!!!!!!!!!!\(message.data)")
        print("*******UUID from message IS \(message.uuid)")
        
        let stringData  = message.data.message as? NSDictionary
        
        
        let stringName    = stringData?["username"] as? String ?? ""
        let stringText    = stringData?["text"] as? String ?? ""
        let stringTime    = stringData?["time"] as? String ?? ""
        let stringImg     = stringData?["image"] as? String ?? ""
        let stringSticker = stringData?["stickers"] as? String ?? ""
        
        
        let newMessage = MesJSQ(username: stringName, textMes: stringText, time: stringTime, image: stringImg, imgSticker: stringSticker)
       // chatMesArray2.append(newMessage)

        updateChat()
    }
    func getTime() -> String{
        let currentDate = Date()  // -  get the current date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm a" //format style to look like 00:00 am/pm
        let dateString = dateFormatter.string(from: currentDate)
        
        
        return dateString
    }
    //////
    

    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        
        //for PubNub
        let pubChat = MesJSQ(username: senderDisplayName, textMes: text, time: getTime(), image: "", imgSticker: imgSticker)
        let newDict = chatMessageToDictionary(pubChat)
        appDel.client?.publish(newDict, toChannel: chan, compressed: true, withCompletion: nil)
        messageModel.append(pubChat)
        updateTableview()
        
        //For JSq
        let mes = JSQMessage(senderId: senderId, senderDisplayName: senderDisplayName, date: date, text: text)
        mesModelJSQ.append(mes!)
        finishSendingMessage()
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let message = self.mesModelJSQ[indexPath.item]
//        if message.senderId == self.senderId {
//            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "outgoingCell", for: indexPath) as! messageViewOutgoingCell

//            cell.chatTxtLbl.text = message.text
//            cell.chatNameLbl.text = message.senderDisplayName
//            return cell
//        } else {
//            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "incomingCell", for: indexPath) as! messageViewIncoming
//            cell.timeLabel.text = message.text
//            return cell
//        }
      let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
        if !message.isMediaMessage {
            cell.textView?.linkTextAttributes = [
                NSAttributedStringKey.foregroundColor.rawValue: cell.textView!.textColor!,
                NSAttributedStringKey.underlineStyle.rawValue: NSUnderlineStyle.styleSingle.rawValue
            ]
        }
 return cell
    }
    
//     func collectionView(collectionView: JSQMessagesCollectionView!, bubbleImageViewForItemAtIndexPath indexPath: NSIndexPath!) -> UIImageView! {
//        let message = mesModelJSQ[indexPath.item]
//
//
//        if message.senderId == self.senderId {
//            return UIImageView(image: outgoingBubbleImageView.image, highlightedImage: outgoingBubbleImageView.highlightedImage)
//        }
//
//        return UIImageView(image: incomingBubbleImageView.image, highlightedImage: incomingBubbleImageView.highlightedImage)
//    }
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return mesModelJSQ.count
        // return messageModel.count
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        //mesModelJSQ[indexPath.item].text == messageModel[indexPath.row].textMes
//        let message = mesModelJSQ[indexPath.item]
//        let mesData = super.collectionView(collectionView, messageDataForItemAt: indexPath) as! JSQMessageData
//
//        if !message.isMediaMessage {
//           ew mesData.text!() == message.text
//        }
        
        return mesModelJSQ[indexPath.item]
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        let buble = JSQMessagesBubbleImageFactory()
        let message = mesModelJSQ[indexPath.item]

        if senderId == message.senderId {
            return buble?.outgoingMessagesBubbleImage(with: .blue)
        } else {
            return buble?.incomingMessagesBubbleImage(with: .black)
        }
    }
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        
        
        return nil
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForMessageBubbleTopLabelAt indexPath: IndexPath!) -> NSAttributedString! {
        let message = mesModelJSQ[indexPath.item]
        let mesUseeName = message.senderDisplayName
        
        
        return NSAttributedString(string: mesUseeName!)
    }
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForMessageBubbleTopLabelAt indexPath: IndexPath!) -> CGFloat {
        return 45
    }
    
}
extension JSQMesVC {
    func parseJsonforJSq(_ anyObj:AnyObject) -> [JSQMessage] {
        var list: [JSQMessage] = []
         if  anyObj is [AnyObject] {
        for jsonMsg in anyObj as! [AnyObject] {
            let json = jsonMsg["message"] as? NSDictionary
            
            let usernameJson = (json?["username"] as AnyObject? as? String) ?? "" // to get rid of null
            let textJson   = (json?["text"]  as AnyObject? as? String) ?? ""
            let timeJson   = (json?["time"]  as AnyObject? as? String) ?? ""
            let imgJson    = (json?["image"] as AnyObject as? String) ?? ""
            let sendIdJ    = (json?["uuid"] as AnyObject? as? String) ?? ""
            let imgStickerJ = (json?["stickers"] as AnyObject? as? String) ?? ""
            
            let imgForJSq = UIImage(named: imgStickerJ)
            let phoForJSQ = JSQPhotoMediaItem(image: imgForJSq)
            
            list.append(JSQMessage(senderId: usernameJson, displayName: usernameJson, media: phoForJSQ))
        }
        collectionView.reloadData()
        
    }
    
    return list
    
    }
}
extension JSQMesVC {
   
    
}

    

