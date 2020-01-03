//
//  ProjectsCollectionViewController.swift
//  ProjectSolitaire
//
//  Created by 杨璨 on 2019/12/26.
//  Copyright © 2019 canyang. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"

class ProjectsCollectionViewController: UICollectionViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
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
        return 4
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        switch section {
        case 0:
            return 20
        case 1:
            return 20 * 12
        case 2:
            return 20 * 12 * 7
        case 3:
            return 20 * 12 * 35
        default:
            return 0
        }
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch indexPath.section {
        case 0:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "year", for: indexPath) as! YearCollectionViewCell
            //cell.setupInterface(year: 2018 + indexPath.row / everyYearCells)
            return cell
        case 1:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "month", for: indexPath) as! MonthCollectionViewCell
            //cell.setupInterface(year: 2018 + indexPath.row / everyYearCells)
            return cell
        case 2:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "year", for: indexPath) as! YearCollectionViewCell
            //cell.setupInterface(year: 2018 + indexPath.row / everyYearCells)
            return cell
        case 0:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "day", for: indexPath) as! DailyCollectionViewCell
            //cell.setupInterface(year: 2018 + indexPath.row / everyYearCells)
            return cell
        default:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "day", for: indexPath)
            return cell
        }
    }

    // MARK: UICollectionViewDelegate

    
    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}
