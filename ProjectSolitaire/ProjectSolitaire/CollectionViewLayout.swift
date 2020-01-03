//
//  CollectionViewLayout.swift
//  LLMark
//
//  Created by 杨璨 on 2019/9/5.
//  Copyright © 2019 canyang. All rights reserved.
//

import UIKit

class CollectionViewLayout: UICollectionViewLayout {
    
    var contentWidth = 0
    var contentHeight = 0
    var attrCache = [[UICollectionViewLayoutAttributes]](repeating: [UICollectionViewLayoutAttributes](), count: 4)
    
    //2019-01-01 to 2099-12-31
    let cellHeight = 100
    let cellWidth = 100
    let totalYear = 20
    let totalMonth = 12
    let daysPerRow = 7
    let rowsPerMonth = 5
    let daysPerMonth = 7 * 5
    let cellsPerMonth = 7 * 5 + 7 + 1
    let cellsPerYear = 12 * (7 * 5 + 7 + 1) + 1
    
    var baseYearHeight = 0
    var baseMonthHeigt = 0
    
    override func prepare() {
        calculateCacheForAllCells()
        super.prepare()
    }
    
    func calculateCacheForAllCells() {
        contentWidth = cellWidth * daysPerRow
        // monthHeight + weekdayheight + daysHeight
        baseMonthHeigt = cellHeight + cellHeight / 2 + cellHeight * rowsPerMonth
        // yearHeight + monthHeight
        baseYearHeight = cellHeight + totalMonth * baseMonthHeigt
        contentHeight = totalYear * baseYearHeight
        attrCache[0].removeAll()
        attrCache[1].removeAll()
        attrCache[2].removeAll()
        attrCache[3].removeAll()
        
        for year in 0..<totalYear {
            attrCache[0].append(calculateCellFrame(year: year, month: 0, day: 0, cellType: 0))
            for month in 0..<totalMonth {
                attrCache[1].append(calculateCellFrame(year: year, month: month, day: 0, cellType: 1))
                for weekday in 0..<daysPerRow {
                    attrCache[2].append(calculateCellFrame(year: year, month: month, day: weekday, cellType: 2))
                }
                for day in 7..<(daysPerMonth + 7) {
                    attrCache[3].append(calculateCellFrame(year: year, month: month, day: day, cellType: 3))
                }
            }
        }
    }
    
    //cellType
    //0: Year,  1: Month,  2: WeekDay,  3:  Day
    func calculateCellFrame(year: Int, month: Int, day: Int, cellType: Int) -> UICollectionViewLayoutAttributes {
        switch cellType {
        case 0:
            let attr = UICollectionViewLayoutAttributes(forCellWith: IndexPath(row: year * cellsPerYear, section: 0))
            print("row \(attr.indexPath.row)")
            let X = 0
            let Y = year * baseYearHeight
            let Height = cellHeight
            let Width = contentWidth
            attr.frame = CGRect(x: X, y: Y, width: Width, height: Height)
            return attr
        case 1:
            let attr = UICollectionViewLayoutAttributes(forCellWith: IndexPath(row: year * cellsPerYear + 1 + month * cellsPerMonth, section: 1))
            print("row \(attr.indexPath.row)")
            let X = 0
            let Y = year * baseYearHeight + cellHeight + month * baseMonthHeigt
            let Height = cellHeight
            let Width = contentWidth
            attr.frame = CGRect(x: X, y: Y, width: Width, height: Height)
            return attr
        case 2:
            let attr = UICollectionViewLayoutAttributes(forCellWith: IndexPath(row: year * cellsPerYear + 1 + month * cellsPerMonth + 1 + day, section: 2))
            print("row \(attr.indexPath.row)")
            let X = day * cellWidth
            let Y = year * baseYearHeight + cellHeight + month * baseMonthHeigt + cellHeight
            let Height = cellHeight / 2
            let Width = cellWidth
            attr.frame = CGRect(x: X, y: Y, width: Width, height: Height)
            return attr
        case 3:
            let attr = UICollectionViewLayoutAttributes(forCellWith: IndexPath(row: year * cellsPerYear + 1 + month * cellsPerMonth + 1 + day, section: 3))
            print("row \(attr.indexPath.row)")
            let X = ((day - 7) % 7) * cellWidth
            let Y = year * baseYearHeight + cellHeight + month * baseMonthHeigt + cellHeight + cellHeight / 2 + ((day - 7) / 7) * cellHeight
            let Height = cellHeight
            let Width = cellWidth
            attr.frame = CGRect(x: X, y: Y, width: Width, height: Height)
            return attr
        default:
            return UICollectionViewLayoutAttributes()
        }
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    override var collectionViewContentSize: CGSize {
        get {
            print("width \(contentWidth) height \(contentHeight)")
            return CGSize(width: contentWidth, height: contentHeight)
        }
    }
    
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return nil
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return attrCache[indexPath.section][indexPath.row]
    }
}
