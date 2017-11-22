//
//  VideoViewController.swift
//  antiIos7
//
//  Created by Polina on 22.11.17.
//  Copyright © 2017 Polina. All rights reserved.
//

import UIKit

class VideoViewController: UIViewController {

    @IBOutlet var textF: UITextField!
    
    @IBAction func SendBtnPressed(_ sender: UIButton) {
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
