//
//  newJSQVC.swift
//  antiIos7
//
//  Created by Polina on 18.10.17.
//  Copyright © 2017 Polina. All rights reserved.
//

import UIKit
import Foundation
import JSQMessagesViewController
import PubNub
import UIKit
import AVKit
import MobileCoreServices


class newJSQVC: JSQMessagesViewController,  PNObjectEventListener, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    

    ///////////
    let picker = UIImagePickerController()
    
    
    var newMtransform: JSQMessage!
    var messageModel = [MesJSQ]()
    var mesModelJSQ = [JSQMessage]()
    var appDel = UIApplication.shared.delegate as! AppDelegate
    
    var stickBtn: UIButton!
    
    
    var bubble = JSQMessagesBubbleImageFactory()
    var avatars = Dictionary<String, UIImage>()
    let bubbleFactory = JSQMessagesBubbleImageFactory()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        picker.delegate = self
        self.title = chan
        self.senderId = userName
        self.senderDisplayName = userName
        
        print("!!!!!!!!!!!!!!!!!!SenderId!!!!!!!!!!!!!!!!!!:\(senderId)")
        print("!!!!!!!!!!!!!!!!!!SenderN!!!!!!!!!!!!!!!!!!:\(userName)")
       
        /////////////customCell
        self.collectionView.register(UINib(nibName: "messageViewIncoming", bundle: nil), forCellWithReuseIdentifier: "incomingCell")
        self.collectionView.register(UINib(nibName: "messageViewOutgoingCell", bundle: nil), forCellWithReuseIdentifier: "outgoingCell")
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        initPubNub()
        // updateTableview()
        updateHistory()
    }
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        self.collectionView.collectionViewLayout.springinessEnabled = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    func parseData(_ data: NSDictionary) -> JSQMessage? {
        
        let stringData    = data
        let stringName    = stringData["username"] as? String ?? ""
        let stringTime    = stringData["time"] as? String ?? ""
        let stringImg     = stringData["image"] as? String ?? ""
        var newMessage: JSQMessage?
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
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
extension newJSQVC {
    
    
    /// ButtonSticker
    
    //        
    //        func buttonStickerWork() {
    //            shouldPerformSegue(withIdentifier: "showStickersVC", sender: self)
    //        }
    //        func buttonStickApperiance() {
    //            let imageStick = UIImage(named:"smileStck" )
    //            stickBtn.setImage(imageStick, for: .normal)
    //        }
    
    
    ////// PickerView
    
    private func chooseMedia(type: CFString) {
        picker.mediaTypes = [type as String]
        present(picker, animated: true, completion: nil)
    }
    
    override func didPressAccessoryButton(_ sender: UIButton!) {
        let alertAction = UIAlertController(title: "загрузить фотографию", message: "Твое фото", preferredStyle:.actionSheet)
        let cancel = UIAlertAction(title: "отменить", style: .cancel, handler: nil)
        let photos = UIAlertAction(title: "Фото", style: .default, handler: { (alert: UIAlertAction) in
            self.chooseMedia(type: kUTTypeImage)
            
        })
        let videos = UIAlertAction(title: "Видео", style: .default, handler: { (alert: UIAlertAction) in
            self.chooseMedia(type: kUTTypeVideo)
        })
        alertAction.addAction(videos)
        alertAction.addAction(photos)
        alertAction.addAction(cancel)
        present(alertAction, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pic = info [UIImagePickerControllerOriginalImage] as? UIImage {
            let img = JSQPhotoMediaItem(image: pic)
            self.mesModelJSQ.append(JSQMessage(senderId: senderId, displayName: senderDisplayName, media: img))
        } else if let video = info [UIImagePickerControllerMediaURL] as? URL {
            
        }
        self.dismiss(animated: true, completion: nil)
        collectionView.reloadData()
    }
    
    //////JSQ
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        
        //for PubNub
        let pubChat = MesJSQ(username: senderDisplayName, textMes: text, time: getTime(), image: "", imgSticker: "")
        let newDict = chatMessageToDictionary(pubChat)
        appDel.client?.publish(newDict, toChannel: chan, compressed: true, withCompletion: nil)
        //For JSq
        let mes = JSQMessage(senderId: senderId, displayName: senderDisplayName, text: text)
        mesModelJSQ.append(mes!)
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

