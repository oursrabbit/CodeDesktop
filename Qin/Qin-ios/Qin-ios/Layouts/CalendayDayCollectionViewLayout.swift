//
//  CalendayDayCollectionViewLayout.swift
//  Qin-ios
//
//  Created by 杨璨 on 2020/2/21.
//  Copyright © 2020 canyang. All rights reserved.
//

import UIKit

class CalendayDayCollectionViewLayout: UICollectionViewLayout {
    
    var dayInMonthAttributesArray = [UICollectionViewLayoutAttributes]()
    let cellSize = CGSize(width: 44, height: 48)
    let cellOutSize = 44 + 8
    
    override func prepare() {
        super.prepare()
        
        guard let collectionView = collectionView else { return }
        
        dayInMonthAttributesArray.removeAll()
        
        let dayInMonthCell = collectionView.numberOfItems(inSection: 0)
        for currentDayinMonth in 0 ..< dayInMonthCell {
            let attributes = UICollectionViewLayoutAttributes(forCellWith: IndexPath(item: currentDayinMonth, section: 0))
            attributes.frame = CGRect(x: cellOutSize * currentDayinMonth, y: 8, width: Int(cellSize.width), height: Int(cellSize.height))
            dayInMonthAttributesArray.append(attributes)
        }
    }
    
    override var collectionViewContentSize: CGSize {
        return CGSize(width: collectionView!.numberOfItems(inSection: 0) * (cellOutSize), height: 48 + 8 + 8)
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return dayInMonthAttributesArray
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return dayInMonthAttributesArray[indexPath.row]
    }
}
