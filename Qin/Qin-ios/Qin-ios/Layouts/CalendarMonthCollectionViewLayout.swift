//
//  CalendarMonthCollectionViewLayout.swift
//  Qin-ios
//
//  Created by 杨璨 on 2020/2/22.
//  Copyright © 2020 canyang. All rights reserved.
//

import UIKit

class CalendarMonthCollectionViewLayout: UICollectionViewLayout {
    
    var atts = [Int : [UICollectionViewLayoutAttributes]]()
    var marine = CGFloat.zero
    var cellWidth = CGFloat.zero
    var cellHeight = CGFloat.zero
    
    var monthHeight = CGFloat.zero
    var yearHeight = CGFloat.zero
    
    override func prepare() {
        super.prepare()
        
        guard let collectionView = collectionView else { return }
        
        atts.removeAll()
        
        cellWidth = collectionView.bounds.size.width / 8
        marine = cellWidth / 2
        cellHeight = 50 + 10
        
        monthHeight = cellHeight * 6 + cellHeight + cellHeight
        yearHeight = monthHeight * 12

        for currentYear in 0..<7 {
            for currentMonth in 0..<12 {
                let section = (currentYear * 12) + currentMonth
                let sectionStartY = CGFloat(currentYear) * yearHeight + CGFloat(currentMonth) * monthHeight
                var currentatts = [UICollectionViewLayoutAttributes]()
                let yearMonthattributes = UICollectionViewLayoutAttributes(forCellWith: IndexPath(item: 0, section: section))
                yearMonthattributes.frame = CGRect(x: marine, y: sectionStartY, width: collectionView.bounds.size.width - cellWidth, height: cellHeight)
                currentatts.append(yearMonthattributes)
                for row in 0..<7 {
                    for column in 0..<7 {
                        let currentCell = row * 7 + column + 1
                        let cellattr = UICollectionViewLayoutAttributes(forCellWith: IndexPath(row: currentCell, section: section))
                        let x = CGFloat(column) * cellWidth + marine
                        let y = (sectionStartY + cellHeight) + CGFloat(row) * cellHeight
                        cellattr.frame = CGRect(x: x, y: y, width: cellWidth, height: cellHeight)
                        currentatts.append(cellattr)
                    }
                }
                atts.updateValue(currentatts, forKey: section)
            }
        }
    }
    
    override var collectionViewContentSize: CGSize {
        return CGSize(width: collectionView!.bounds.size.width, height: yearHeight * 7)
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var allattr = [UICollectionViewLayoutAttributes]()
        for item in atts {
            allattr += item.value
        }
        return allattr
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return atts[indexPath.section]![indexPath.row]
    }
}
