//
//  HotModel.swift
//  antiIos7
//
//  Created by Polina on 11.10.17.
//  Copyright © 2017 Polina. All rights reserved.
//

import Foundation

struct HotModel {
    
    var newsTytle = ""
    var url = ""
  //  var countOfPosts = 0
  //  var newsResourse = ""
  //  var imgType = ""
  //  var addButton = true
//    var typeResourse : String
//    var countOfPosts : Int
//    var arrayTypeResourse = ["SowBiz","Sport","Politica"

}
struct Meduza4Json: Codable {
    var title    : String
    var url      : String
    
    enum CodingKeys: String, CodingKey {
        case title = "title"
        case url   = "url"
    }

}


struct Med4JsonDoc: Codable {
    var documents : [String: Meduza4Json]
    
    
}


//func medNews(_ med: Meduza4Json) -> [HotModel] {
//    return [HotModel(newsTytle: med.title, url: med.url)]
//}





