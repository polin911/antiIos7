//
//  HotNewsVC.swift
//  antiIos7
//
//  Created by Polina on 11.10.17.
//  Copyright © 2017 Polina. All rights reserved.
//

import UIKit

class HotNewsVC: UIViewController {
   
    //Buttons
    @IBOutlet var btnShowBiz: UIButton!
    @IBOutlet var btnSport: UIButton!
    @IBOutlet var btnPolitica: UIButton!
    @IBOutlet var tableViewHot: UITableView!
    
    //
    var hModel: [HotModel] = []
    var typeModel = TypesModel()
    var med4J    : Meduza4Json!
    var titleMed = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        parseJSonMeduza()
        

    }

    func updateView() {
        tableViewHot.delegate = self
        tableViewHot.dataSource = self
    }
    @IBAction func btnPoliticaPressed(_ sender: Any) {
    }
    @IBAction func btnSportPressed(_ sender: Any) {
    }
    @IBAction func btnShowBPressed(_ sender: Any) {
    }
    
    //////////////////API Meduza

}
extension HotNewsVC {
    func parseJSonMeduza() {
        
        var urlStrM = "https://meduza.io/api/v3/search?chrono=news&locale=ru&page=0&per_page=24"
        guard let url = URL(string: urlStrM) else { return }
    
        ///////
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data else {
                print("error with data")
                return
            }
            guard error == nil else {
                print("error \(error)")
                return
            }
            do {
                
                var medData : Meduza4Json
                let meduzaNews = try JSONDecoder().decode(Med4JsonDoc.self, from: data)
                print("!!!!!!!!!!!!!!!Documents: \(meduzaNews)")
                
                let stringData = meduzaNews.documents as? NSDictionary
               // let dataMed = stringData![self.med4J] as? NSDictionary
                let stringTitle = Meduza4Json.CodingKeys.title.rawValue
                let stringUrl   = stringData!["url"] as? String ?? ""
            
                let newMessage = HotModel(newsTytle: stringTitle, url: Meduza4Json.CodingKeys.url.rawValue )
                
                self.hModel.append(newMessage)
                print("title@@@@@@@@@@@@@@@@@@@\(stringTitle)")
                
                
            } catch let error {
                print(error)
            }
            
        } .resume()
        self.tableViewHot.reloadData()
       
    }
}
extension HotNewsVC: UITableViewDelegate , UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableViewHot.dequeueReusableCell(withIdentifier: "HotCell", for: indexPath) as! HotCell
        cell.TitleOfNews.text = hModel[indexPath.row].newsTytle
        
//        if typeModel.typeResourse == typeModel.arrayTypeResourse[2] {
//
//        }
       return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return hModel.count
    }
}
/////////////////////

