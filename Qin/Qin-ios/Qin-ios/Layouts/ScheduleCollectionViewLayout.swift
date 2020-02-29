//
//  ScheduleCollectionViewLayout.swift
//  Qin-ios
//
//  Created by 杨璨 on 2020/2/21.
//  Copyright © 2020 canyang. All rights reserved.
//

import UIKit

class ScheduleCollectionViewLayout: UICollectionViewLayout {
    
    let oneMin = 1
    let oneHour = 60
    
    var timeLineAttributesArray = [UICollectionViewLayoutAttributes]()
    var scheduleAttributesArray = [UICollectionViewLayoutAttributes]()
    
    override func prepare() {
        super.prepare()
        
        guard let collectionView = collectionView else { return }
        
        timeLineAttributesArray.removeAll()
        scheduleAttributesArray.removeAll()
        
        let timelineCell = collectionView.numberOfItems(inSection: 0)
        for currentTimeLineCell in 0 ..< timelineCell {
            let attributes = UICollectionViewLayoutAttributes(forCellWith: IndexPath(item: currentTimeLineCell, section: 0))
            attributes.frame = CGRect(x: 0, y: currentTimeLineCell * oneHour, width: Int(collectionView.bounds.size.width), height: oneHour)
            timeLineAttributesArray.append(attributes)
        }
        
        let scheduleCell = collectionView.numberOfItems(inSection: 1)
        for currentScheduleCell in 0 ..< scheduleCell {
            let schedule = ApplicationHelper.CurrentUser.DrawableSchedules[currentScheduleCell]
            let attributes = UICollectionViewLayoutAttributes(forCellWith: IndexPath(item: currentScheduleCell, section: 1))
            attributes.frame = CGRect(x: 0, y: schedule.getCellX(), width: Int(collectionView.bounds.size.width), height: schedule.getCellHeight())
            attributes.zIndex = 1
            scheduleAttributesArray.append(attributes)
        }
    }
    
    override var collectionViewContentSize: CGSize {
        return CGSize(width: collectionView!.bounds.size.width, height: CGFloat(oneHour * 24))
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return timeLineAttributesArray+scheduleAttributesArray
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return indexPath.section == 0 ? timeLineAttributesArray[indexPath.row] : scheduleAttributesArray[indexPath.row]
    }
}
