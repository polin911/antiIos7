//
//  VideoViewController.swift
//  antiIos7
//
//  Created by Polina on 22.11.17.
//  Copyright © 2017 Polina. All rights reserved.
//

import UIKit
import MobileCoreServices
import MediaPlayer
import Parse

class VideoViewController: UIViewController {

    @IBOutlet var textF: UITextField!
    
    @IBAction func SendBtnPressed(_ sender: UIButton) {
    }
    
    @IBAction func rec_Btn_Pressed(_ sender: Any) {
        startCameraFromViewController(viewController: self, withDelegate: self)
    }
    
    func startCameraFromViewController(viewController: UIViewController, withDelegate delegate: UIImagePickerControllerDelegate & UINavigationControllerDelegate) -> Bool {
        if UIImagePickerController.isSourceTypeAvailable(.camera) == false {
            return false
        }
        
        var cameraController = UIImagePickerController()
        cameraController.sourceType = .camera
        cameraController.mediaTypes = [kUTTypeMovie as NSString as String]
        cameraController.allowsEditing = false
        cameraController.delegate = delegate
        
        present(cameraController, animated: true, completion: nil)
        return true
    }
    
    
    func startMediaBrowserFromViewController(viewController: UIViewController, usingDelegate delegate: UINavigationControllerDelegate & UIImagePickerControllerDelegate) -> Bool {
        // 1
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum) == false {
            return false
        }
        
        // 2
        var mediaUI = UIImagePickerController()
        mediaUI.sourceType = .savedPhotosAlbum
        mediaUI.mediaTypes = [kUTTypeMovie as NSString as String]
        mediaUI.allowsEditing = true
        mediaUI.delegate = delegate
        
        // 3
        present(mediaUI, animated: true, completion: nil)
        return true
    }
    
    @objc func video(videoPath: NSString, didFinishSavingWithError error: NSError?, contextInfo info: AnyObject) {
        var title = "Success"
        var message = "Video was saved"
        if let _ = error {
            title = "Error"
            message = "Video failed to save"
        }
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    
    
    
    
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as! JSQMesVC
        var currentDate = Date()
        var idM         = NSUUID().uuidString
        let newMes = MesJSQText(date: currentDate, idMes: idM , username: userName, textMes: textF.text!, avatar: imgName)
        vc.appDel.client?.publish(newMes.toDictionaryMessage(), toChannel: chan, withCompletion: nil)
        vc.messageModel.append(newMes)
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }



}

extension VideoViewController: UIImagePickerControllerDelegate {
    private func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        var parseAntiIos = PFObject(className: "AntiIOS")
        
       // let mediaType = info[UIImagePickerControllerMediaType] as! NSString
        guard let videoURL = info[UIImagePickerControllerMediaURL] as? NSURL else {return}
        guard let dataVideo = NSData(contentsOf: videoURL as URL) else {return}
        let videoFile = PFFile(data: dataVideo as Data, contentType: "video/mp4")
        
        parseAntiIos["video"] = videoFile
        parseAntiIos["nick"]  = userName
        
        parseAntiIos.saveInBackground { (success, error) in
            guard error == nil else {return}
            print("video has been saved")
        }
        
        dismiss(animated: true, completion: nil)
       
        //
            
            
//            if UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(path) {
//                UISaveVideoAtPathToSavedPhotosAlbum(path, self, #selector(VideoViewController.video(videoPath:didFinishSavingWithError:contextInfo:)), nil)
//            }
        
       // }
    }
}

extension VideoViewController: UINavigationControllerDelegate {
}
