//
//  StickersController4JSQ.swift
//  antiIos7
//
//  Created by Polina on 18.10.17.
//  Copyright © 2017 Polina. All rights reserved.
//

import UIKit

private let reuseIdentifier = "StickCell"

class StickersController4JSQ: UICollectionViewController {
    
     var imgStrickersString = ["s1.png","s2.png","s3.png","s4.png","s5.png", "s6.png","s7.png","s8.png","s9.png","s10.png","s11.png","s12.png","s13.png","s14.png","s15.png","s16.png"]

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return imgStrickersString.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! StickCell
        let oneStick = imgStrickersString[indexPath.row]
        cell.imgStick.image = UIImage(named: oneStick)

    
        return cell
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }

}
