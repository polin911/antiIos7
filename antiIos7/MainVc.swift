//
//  MainVc.swift
//  antiIos7
//
//  Created by Polina on 02.10.17.
//  Copyright © 2017 Polina. All rights reserved.
//

import UIKit
import PubNub

class MainVC: UIViewController, PNObjectEventListener{
    
    @IBOutlet var xBtn: UIButton!
    @IBOutlet var stickerCollectionView: UICollectionView!
    @IBOutlet var segment: UISegmentedControl!
    @IBOutlet var userImg: UIImageView!
    //@IBOutlet var chatNameLbl: UILabel!
    @IBOutlet var chatTableView: UITableView!
    
    // var menuTransitionManager = MenuTransitionManager()
    var kPreferredTextFieldToKeyboardOffset: CGFloat = 70.0
    var keyboardFrame: CGRect = CGRect.null
    var keyboardIsShowing: Bool = false
    
    @IBOutlet var messageTxtField: UITextField!
    @IBOutlet var senderBtn: UIButton!
    
    var introModalDidDisplay = false
    
    var imgStrickersString = ["s1.png","s2.png","s3.png","s4.png","s5.png", "s6.png","s7.png","s8.png","s9.png","s10.png","s11.png","s12.png","s13.png","s14.png","s15.png","s16.png"]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
        override func viewWillDisappear(_ animated: Bool) {
            super.viewWillDisappear(animated)
            NotificationCenter.default.removeObserver(self)
        }
    
    override func viewWillAppear(_ animated: Bool) {
        self.title = chan
        updateView()
    }
    
    
    
    func extractedFunc() {
        self.chatTableView.delegate   = self
        self.chatTableView.dataSource = self
        
        self.stickerCollectionView.delegate   = self
        self.stickerCollectionView.dataSource = self
        initPubNub()
        updateTableview()
        userImg.image = UIImage(named: imgName)
    }
    
    func updateView() {
        extractedFunc()
        
    }
    ///////////////////////////////MARK: PubNubConnection
    
    
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
            //self.occupancyButton.setTitle(occ, for: UIControlState())
        })
        updateHistory()
        
        
        guard let deviceToken   = UserDefaults.standard.object(forKey: "deviceToken") as? Data
            else {
                return
        }
        print("**********deviceToken is **** \(deviceToken)")
        
        
        // appDel.client?.addPushNotifications(onChannels: ["push"], withDevicePushToken: deviceToken, andCompletion: nil)
        
    }
    
    func parseJson(_ anyObj:AnyObject) -> [ChatMessage]{
        
        var list:[ChatMessage] = []
        
        if  anyObj is [AnyObject] {
            
            for jsonMsg in anyObj as! [AnyObject] {
                let json = jsonMsg["message"] as? NSDictionary
                // if(json?["type"] as AnyObject? as? String != "Chat"){ continue }
                let usernameJson = (json?["username"] as AnyObject? as? String) ?? "" // to get rid of null
                let textJson   = (json?["text"]  as AnyObject? as? String) ?? ""
                let timeJson   = (json?["time"]  as AnyObject? as? String) ?? ""
                let imgJson    = (json?["image"] as AnyObject as? String) ?? ""
                let imgStickerJ  = (json?["stickers"] as AnyObject? as? String) ?? ""
                
                list.append(ChatMessage(username: usernameJson, text: textJson, time: timeJson, image: imgJson, imgSticker: imgStickerJ ))
            }
            chatTableView.reloadData()
            
        }
        
        return list
        
    }
    
    func updateHistory(){
        
        let appDel = UIApplication.shared.delegate! as! AppDelegate
        
        appDel.client?.historyForChannel(chan, start: nil, end: nil, includeTimeToken: true, withCompletion: { (result, status) in
            print("!!!!!!!!!Status: \(result)")
            
            
            chatMesArray = self.parseJson(result!.data.messages as AnyObject)
            self.updateTableview()
            
        })
    }
    func updateTableview(){
        self.chatTableView.reloadData()
        
        
        if self.chatTableView.contentSize.height > self.chatTableView.frame.size.height {
            chatTableView.scrollToRow(at: IndexPath(row: chatMesArray.count - 1, section: 0), at: UITableViewScrollPosition.bottom, animated: true)
        }
    }
    func updateChat(){
        chatTableView.reloadData()
        
        let numberOfSections = chatTableView.numberOfSections
        let numberOfRows = chatTableView.numberOfRows(inSection: numberOfSections-1)
        
        if numberOfRows > 0 {
            let indexPath = IndexPath(row:numberOfRows - 1, section:numberOfSections - 1)
            
            //IndexPath(forRow: numberOfRows-1, inSection: (numberOfSections-1))
            chatTableView.scrollToRow(at: indexPath, at: .bottom,
                                      animated: true)
        }
        
    }
    
    /////////////////////MARK: Upload Message
    
    
    /////Mark: clientPubNub
    
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
        
        
        let newMessage = ChatMessage(username: stringName, text: stringText, time: stringTime, image: stringImg, imgSticker: stringSticker )
        
        
        chatMesArray.append(newMessage)
        updateChat()
        
    }
    
    func client(_ client: PubNub, didReceivePresenceEvent event: PNPresenceEventResult) {
        print("******didReceivePresenceEvent*****")
        print(event.data)
        print("*******UUID from presence IS \(event.uuid)")
        
        
        let occ = event.data.presence.occupancy.stringValue
        //occupancyButton.setTitle(occ, for: UIControlState())
        segment.setTitle("Участников: \(occ)", forSegmentAt: 1)
        
        
        
        
        switch event.data.presenceEvent{
        case "join":
            let pubChat = ChatMessage(username:"", text: "\(userName) присоединился к нам!", time: getTime(), image: "", imgSticker: "")
            
            chatMesArray.append(pubChat)
            
        case "leave":
            let pubChat = ChatMessage(username: "", text: "\(event.data.presence.uuid?.uppercased()) left the chat", time: getTime(),image: "", imgSticker: "")
            chatMesArray.append(pubChat)
            
            //        case "timeout":
            //            var pubChat = ChatMessage(username: "", message: "\(event.data.presence.uuid?.uppercased()) - \(userName) покинул нас", time: getTime(),image: "")
            //            chatMesArray.append(pubChat)
            
        default:
            var leaveChat = ChatMessage(username: "", text: "\(event.data.presence.uuid?.uppercased()) - \(userName) покинул нас", time: getTime(),image: "", imgSticker: "")
            //chatMesArray.append(pubChat)
            
        }
        
        if (event.data.presenceEvent == "join"){
            //Add to array
            if !(usersArray.contains(event.data.presence.uuid!)){
                usersArray.append(event.data.presence.uuid!)
            }
        }
        else {
            // Check if in array, only delete if they are
            if (usersArray.contains(event.data.presence.uuid!)){
                usersArray = usersArray.filter{$0 != event.data.presence.uuid}
            }
            
        }
        
        updateChat()
        
        
    }
    
    /////////
    func getTime() -> String{
        let currentDate = Date()  // -  get the current date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm a" //format style to look like 00:00 am/pm
        let dateString = dateFormatter.string(from: currentDate)
        
        
        return dateString
    }
    
    @IBAction func stickerBtnPressed(_ sender: AnyObject) {
        stickerCollectionView.isHidden = false
        xBtn.isHidden = false
    }
    
    @IBAction func buttonNamePressed(_ sender: AnyObject) {
        initPubNub()
        print("pressed")
        updateTableview()
    }
    
    func updateStickers() {
        let appDel = UIApplication.shared.delegate! as! AppDelegate
        let pubChat = ChatMessage(username: userName, text: messageTxtField.text!, time: getTime(), image: imgName, imgSticker: imgSticker)
        let newDict = chatMessageToDictionary(pubChat)
        
        appDel.client?.publish(newDict, toChannel: chan, compressed: true, withCompletion: nil)
        updateTableview()
        
    }
    
    @IBAction func senderBtnPressed(_ sender: AnyObject) {
        let appDel = UIApplication.shared.delegate! as! AppDelegate
        
        
        let message = messageTxtField.text
        if(message == "") {return}
        else{
            let pubChat = ChatMessage(username: userName, text: messageTxtField.text!, time: getTime(), image: imgName, imgSticker: imgSticker)
            
            let newDict = chatMessageToDictionary(pubChat)
            
            appDel.client?.publish(newDict, toChannel: chan, compressed: true, withCompletion: nil)
            
            messageTxtField.text = nil
            updateTableview()
        }
    }
    
    @IBAction func xBtnPressed(_ sender: AnyObject) {
        stickerCollectionView.isHidden = true
        xBtn.isHidden = true
    }
}
extension MainVC: UITableViewDelegate {
    
}
    extension MainVC: UITableViewDataSource {
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = chatTableView.dequeueReusableCell(withIdentifier: "ChatCell", for: indexPath) as! ChatCell
            
            
            cell.chatNameLbl.text = chatMesArray[indexPath.row].username
            cell.chatTxtLbl.text  = chatMesArray[indexPath.row].text
            cell.chatImage.image  = UIImage(named:(chatMesArray[indexPath.row].image))
            cell.timeLbl.text     = chatMesArray[indexPath.row].time
            
            
            cell.imgSticker.image = UIImage(named:(chatMesArray[indexPath.row].imgSticker))
            return cell
        }
        
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return chatMesArray.count
        }
    }
    extension MainVC: UICollectionViewDelegate {
        func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            let currentSticker = imgStrickersString[indexPath.row]
            imgSticker = currentSticker
            stickerCollectionView.isHidden = true
            xBtn.isHidden = true
            updateStickers()
            
        }
        
    }
    
    
    extension MainVC: UICollectionViewDataSource {
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return imgStrickersString.count
        }
        
        func numberOfSections(in collectionView: UICollectionView) -> Int {
            return 1
        }
        
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let cell = stickerCollectionView.dequeueReusableCell(withReuseIdentifier: "StickerCell", for: indexPath) as! SticerCell
            cell.sticerImage.image = UIImage(named: imgStrickersString[indexPath.row])
            return cell
        }
}
