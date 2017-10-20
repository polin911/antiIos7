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
//import

class JSQMesVC: JSQMessagesViewController, PNObjectEventListener, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    let picker = UIImagePickerController()
    
    @IBOutlet var stickersCollection: UICollectionView!
    var newMtransform: JSQMessage!
    var messageModel = [MesJSQ]()
    var mesModelJSQ = [JSQMessage]()
    var appDel = UIApplication.shared.delegate as! AppDelegate
    
    
    var stickBtn: UIButton!

   // var phForJSq = JSQPhotoMediaItem(image: UIImage(named: imgSticker))
    ///
    var bubble = JSQMessagesBubbleImageFactory()
    var avatars = Dictionary<String, UIImage>()
    let bubbleFactory = JSQMessagesBubbleImageFactory()
   ///////////////////////
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //ButtonForSticker
       // self.inputToolbar.contentView.leftBarButtonItem = stickBtn
      //  buttonStickApperiance()
        
        /////////
        
        picker.delegate = self
        self.title = chan
        self.senderId = userName
        self.senderDisplayName = userName
        
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
        stickBtn.setImage(imageStick, for: .normal)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        initPubNub()
       // updateTableview()
        updateHistory()
        checkStickers()
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
        updateHistory()
 
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
            

            
            self.mesModelJSQ = self.parseDataAny(result!.data.messages as [AnyObject])
            self.collectionView.reloadData()
            self.finishReceivingMessage()
//            imageSticker = ""
            
            print("Stiiiiiiiiiiiiickkers \(imageSticker)")
          
        })
    }
    func parseDataAny(_ any: [AnyObject] ) -> [JSQMessage] {
        var list = [JSQMessage]()
        for data in any {
            if let data = data as? NSDictionary,
                let messageData = data["message"] as? NSDictionary,
                let message = parseData(messageData){
                list.append(message)
            }
        }
        return list
    }
    ///////////Stickers
    
    func checkStickers() {
        if imageSticker.isEmpty == false {

            finishSendingMessage()
        }
    }
//    func sendSticker(nameSticker: String) {
//        let imgForJSq = UIImage(named: nameSticker)
//        let phoForJSQ = JSQPhotoMediaItem(image: imgForJSq)
//        var newMes = JSQMessage(senderId: senderDisplayName, displayName: senderDisplayName, media: phoForJSQ!)
//        guard let readyMes = newMes else {
//            return
//        }
//        //for PubNub
//        let pubChat = MesJSQ(username: senderDisplayName, textMes: "", time: getTime(), image: "", imgSticker: nameSticker)
//        let newDict = chatMessageToDictionary(pubChat)
//        appDel.client?.publish(newDict, toChannel: chan, compressed: true, withCompletion: nil)
//        mesModelJSQ.append(readyMes)
//        collectionView.reloadData()
//        finishReceivingMessage()
//    }
    
//    func parseData4Stickers(_ data: NSDictionary) -> JSQMessage? {
//            let stringData    = data
//            let stringName    = stringData["username"] as? String ?? ""
//            let stringTime    = stringData["time"] as? String ?? ""
//            let stringImg     = stringData["image"] as? String ?? ""
//            var newMessage: JSQMessage?
//            ////Stickers
//            if imgSticker.isEmpty == false {
//                
//                let imgForJSq = UIImage(named: imgSticker)
//                let phoForJSQ = JSQPhotoMediaItem(image: imgForJSq)
//                newMessage = JSQMessage(senderId: stringName, displayName: stringName, media: phoForJSQ)
//            } else if let stringText = stringData["text"] as? String {
//                newMessage = JSQMessage(senderId: stringName, displayName: stringName, text: stringText)
//            }
//            guard let readyMessage = newMessage else {
//                return nil
//            }
//            return readyMessage
//        }
    
    func parseData(_ data: NSDictionary) -> JSQMessage? {
        
        let stringData    = data
        let stringName    = stringData["username"] as? String ?? ""
        let stringTime    = stringData["time"] as? String ?? ""
        let stringImg     = stringData["image"] as? String ?? ""
        var newMessage: JSQMessage?
        ////Stickers
        
//        if imgSticker.isEmpty == false {
//           let imgForJSq = UIImage(named: imgSticker)
//                let phoForJSQ = JSQPhotoMediaItem(image: imgForJSq)
//                newMessage = JSQMessage(senderId: stringName, displayName: stringName, media: phoForJSQ)
//            guard let readyMessage = newMessage else {
//                return nil
//            }
//            return readyMessage
//        }
//////////////////
        
        if  let stringSticker = stringData["stickers"] as? String ,
            stringSticker.isEmpty == false {
            
            let imgForJSq = UIImage(named: stringSticker)
            let phoForJSQ = JSQPhotoMediaItem(image: imgForJSq)
            newMessage = JSQMessage(senderId: stringName, displayName: stringName, media: phoForJSQ)
        } else if let stringText = stringData["text"] as? String {
            newMessage = JSQMessage(senderId: stringName, displayName: stringName, text: stringText)
        }
        guard let readyMessage = newMessage else {
            return nil
        }
        return readyMessage
    }

    func client(_ client: PubNub, didReceiveMessage message: PNMessageResult) {
        print("******didReceiveMessage*****")
        print("from client!!!!!!!!!!!!!!!!!!!!!!!\(message.data)")
        print("*******UUID from message IS \(message.uuid)")
        
        guard let stringData  = message.data.message as? NSDictionary else {
            return
        }
    
        guard  let readyMessage = parseData(stringData) else{
            return
        }
        mesModelJSQ.append(readyMessage)
        collectionView.reloadData()
   // finishReceivingMessage()
    }
    func getTime() -> String{
        let currentDate = Date()  // -  get the current date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm a" //format style to look like 00:00 am/pm
        let dateString = dateFormatter.string(from: currentDate)
        return dateString
    }
    ////// PickerView
    
    
  //////JSQ
    
    override func didPressAccessoryButton(_ sender: UIButton!) {
    performSegue(withIdentifier: "showStickersVC", sender: self)   
        
    }
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        
        //for PubNub
        let pubChat = MesJSQ(username: senderDisplayName, textMes: text, time: getTime(), image: "", imgSticker: imageSticker)
        let newDict = chatMessageToDictionary(pubChat)
        appDel.client?.publish(newDict, toChannel: chan, compressed: true, withCompletion: nil)
        //For JSq
        if imageSticker.isEmpty == true {
        let mes = JSQMessage(senderId: senderId, displayName: senderDisplayName, text: text)
            guard let newMessage = mes else {return}
            mesModelJSQ.append(newMessage)
        } else  {
            var media = JSQPhotoMediaItem(image: UIImage(named: imageSticker))
            let mes = JSQMessage(senderId: senderId, displayName: senderDisplayName, media: media)
            guard let newMessage = mes else {return}
            mesModelJSQ.append(newMessage)
        }
        imageSticker = ""
        collectionView.reloadData()
        finishSendingMessage()
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
            let message = self.mesModelJSQ[indexPath.item]
            let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
        
            return cell
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
            return buble?.outgoingMessagesBubbleImage(with: .black)
        } else {
            return buble?.incomingMessagesBubbleImage(with: .black)
        }
    }
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        let message = mesModelJSQ[indexPath.item]
       // let mes     =
        if senderId == message.senderId {
            return JSQMessagesAvatarImageFactory.avatarImage(with: UIImage(named: imgName), diameter: 30)
        } else {
            return JSQMessagesAvatarImageFactory.avatarImage(with:#imageLiteral(resourceName: "s12") , diameter: 30)
        }

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


    
