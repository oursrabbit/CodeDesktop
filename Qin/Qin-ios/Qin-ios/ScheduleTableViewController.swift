//
//  ScheduleTableViewController.swift
//  Qin-ios
//
//  Created by 杨璨 on 2020/2/15.
//  Copyright © 2020 canyang. All rights reserved.
//

import UIKit
import RealmSwift

class ScheduleTableViewController: StaticViewController {
    
    @IBOutlet weak var calendarTop: NSLayoutConstraint!
    @IBOutlet weak var headerViewHeight: NSLayoutConstraint!
    @IBOutlet weak var selectMonthButton: UIButton!
    @IBOutlet weak var calendarDayCollectionView: UICollectionView!
    @IBOutlet weak var scheduleCollectionView : UICollectionView!
    @IBOutlet weak var arrowImageView: UIImageView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var nocourseImageView: UIImageView!
    
    var selectDate = Date()
    var selectingMonth = false
    var startDate = Date()
    var endDate = Date()
    
    var schedules = [Schedule]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        startDate = Calendar.current.date(from: DateComponents(year: Date().year - 3))!
        endDate = Calendar.current.date(from: DateComponents(year: Date().year + 3))!
        
        goBackToToday(nil)
    }
    
    @IBAction func goBackToToday(_ sender: Any?) {
        selectDate = Date()
        selectingMonth = false
        InitInterface()
    }
    
    func InitInterface() {
        schedules = ApplicationHelper.CurrentUser.GetScheduleBy(date: selectDate)
        self.calendarDayCollectionView.backgroundColor = UIColor.clear.withAlphaComponent(0)
        if selectingMonth {
            headerViewHeight.constant = 400
            self.calendarDayCollectionView.reloadData()
            self.calendarDayCollectionView.collectionViewLayout = CalendarMonthCollectionViewLayout()
            let section = (selectDate.year - startDate.year) * 12 + selectDate.monthInYear - 1
            self.calendarDayCollectionView.layoutIfNeeded()
            calendarDayCollectionView.scrollToItem(at: IndexPath(row: 1, section: section), at: [.top, .left], animated: true)
        } else {
            headerViewHeight.constant = 200
            self.calendarDayCollectionView.reloadData()
            self.calendarDayCollectionView.collectionViewLayout = CalendayDayCollectionViewLayout()
            self.calendarDayCollectionView.layoutIfNeeded()
            calendarDayCollectionView.scrollToItem(at: IndexPath(row: selectDate.dayInMonth - 1, section: 0), at: .left, animated: true)
        }
        nocourseImageView.isHidden = schedules.count != 0
        self.selectMonthButton.setTitle(selectDate.yearMonthStringZH, for: .normal)
        self.scheduleCollectionView.reloadData()
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
    @IBAction func showMonthSelectionTable(_ sender: Any) {
        self.selectingMonth = !self.selectingMonth
        self.InitInterface()
    }
}

extension ScheduleTableViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if collectionView == self.calendarDayCollectionView {
            if selectingMonth {
                return 7 * 12
            } else {
                return 1
            }
        } else if collectionView == self.scheduleCollectionView {
            return 2
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.calendarDayCollectionView {
            if selectingMonth {
                return 50
            } else {
                return selectDate.daysInMonth
            }
        } else if collectionView == self.scheduleCollectionView {
            if section == 0 {
                return 24
            } else if section == 1 {
                return schedules.count
            }
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == self.calendarDayCollectionView {
            if selectingMonth {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "calendarmonthcell", for: indexPath) as! CalendarMonthCollectionViewCell
                cell.initCellInterface()
                let year = startDate.year + indexPath.section / 12
                let month = indexPath.section % 12 + 1
                let row = (indexPath.row - 1) / 7
                let column = (indexPath.row - 1) % 7
                if indexPath.row == 0 {
                    cell.dayLabel.font = UIFont(name: "HYZiYanHuanLeSongW", size: 20)
                    cell.dayLabel.backgroundColor = UIColor.clear.withAlphaComponent(0)
                    cell.dayLabel.textColor = .white
                    cell.dayLabel.text = "\(year)年\(month)月"
                    cell.pointImageView.isHidden = true
                } else if row == 0 {
                    cell.dayLabel.font = UIFont(name: "HYZiYanHuanLeSongW", size: 18)
                    let weekDayString = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
                    cell.dayLabel.backgroundColor = UIColor.clear.withAlphaComponent(0)
                    cell.dayLabel.textColor = UIColor.deselectDayTextColor
                    cell.dayLabel.text = weekDayString[column]
                    cell.pointImageView.isHidden = true
                } else if Date.getDayByIndexRow(year: year, month: month, row: row, column: column) == 0 {
                    cell.dayLabel.backgroundColor = UIColor.clear.withAlphaComponent(0)
                    cell.dayLabel.textColor = UIColor.deselectDayTextColor
                    cell.dayLabel.text = ""
                    cell.pointImageView.isHidden = true
                } else {
                    cell.dayLabel.font = UIFont.systemFont(ofSize: 18)
                    let day = Date.getDayByIndexRow(year: year, month: month, row: row, column: column)
                    let cellDate = Calendar.current.date(from: DateComponents(year: year, month: month, day: day))!
                    cell.dayLabel.backgroundColor = cellDate.equelsTo(date: selectDate) ? .white : UIColor.clear.withAlphaComponent(0)
                    cell.dayLabel.textColor = cellDate.equelsTo(date: selectDate) ? .selectDayTextColor : UIColor.deselectDayTextColor
                    cell.dayLabel.text = cellDate.dayInMonthString
                    cell.pointImageView.isHidden = ApplicationHelper.CurrentUser.GetScheduleBy(date: cellDate).count == 0
                }
                return cell
            } else {
                let cellDate = Calendar.current.date(from: DateComponents(year: selectDate.year, month: selectDate.monthInYear, day: indexPath.row + 1))!
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "calendardaycell", for: indexPath) as! CalendarDayCollectionViewCell
                cell.backgroundColor = ((indexPath.row == (selectDate.dayInMonth - 1)) ? .white : .calendarBg)
                cell.dayInMonthLabel.text = cellDate.dayInMonthString
                cell.dayInMonthLabel.textColor = ((indexPath.row == (selectDate.dayInMonth - 1)) ? .selectDayTextColor : .deselectDayTextColor)
                cell.dayInWeekLabel.text = cellDate.dayInWeekString
                cell.dayInWeekLabel.textColor = ((indexPath.row == (selectDate.dayInMonth - 1)) ? .selectDayTextColor : .deselectDayTextColor)
                cell.initCellInterface()
                return cell
            }
        } else if collectionView == self.scheduleCollectionView {
            if indexPath.section == 0 {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "timelinecell", for: indexPath) as! ScheduleTimeLineCollectionViewCell
                cell.hourLabel.text = "\(indexPath.row + 1):00" //"\(indexPath.row + 1 % 12)\((indexPath.row/12 == 1 ? "PM" : "AM"))"
                return cell
            } else if indexPath.section == 1 {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "schedulecell", for: indexPath) as! ScheduleCollectionViewCell
                let schedule = schedules[indexPath.row]
                let courseName = (try! Realm()).objects(Course.self).first(where: {$0.ID == schedule.CourseID})?.Name ?? ""
                let room = (try! Realm()).objects(Room.self).first(where: {$0.ID == schedule.RoomID})!
                let building = room.Location!
                let location = "\(building.Name) \(room.Name)"
                var professorString = ""
                for pro in schedule.ProfessorID {
                    let professor = (try! Realm()).objects(Professor.self).first(where: {$0.ID == pro})!
                    professorString += "\(professor.Name) "
                }
                let startSection = (try! Realm()).objects(Section.self).first(where: {$0.ID == schedule.StartSectionID})!
                let endSection = (try! Realm()).objects(Section.self).first(where: {$0.Order == startSection.Order + schedule.ContinueSection - 1})!
                //let checkLog = ApplicationHelper.CurrentUser.GetCheckLogBy(startDate: startSection.StartTime, endDate: endSection.EndTime, roomID: schedule.RoomID)
                //let checkState = checkLog == nil ? "(未签到)" : "(已签到：\(checkLog!.CheckDate.longString)"
                cell.RoomLabel.text = "\(location)  \(startSection.StartTime.shortTimeString)-\(endSection.EndTime.shortTimeString)"
                cell.RoomLabel.textColor = schedule.CellColor
                cell.DateLabel.text = "\(courseName) \(professorString)"
                cell.DateLabel.textColor = schedule.CellColor
                cell.DecorateView.backgroundColor = schedule.CellColor
                //cell.CheckStateLabel.text = checkState
                cell.CheckStateLabel.textColor = schedule.CellColor
                cell.InfoView.backgroundColor = schedule.CellColor.withAlphaComponent(0.15)
                return cell
            }
        }
        let cell = UICollectionViewCell()
        return cell
    }
}

extension ScheduleTableViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        if collectionView == self.calendarDayCollectionView {
            if selectingMonth {
                let year = startDate.year + indexPath.section / 12
                let month = indexPath.section % 12 + 1
                let row = (indexPath.row - 1) / 7
                let column = (indexPath.row - 1) % 7
                if indexPath.row == 0 || row == 0 || Date.getDayByIndexRow(year: year, month: month, row: row, column: column) == 0 {
                    return false
                }
            }
        }
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == self.calendarDayCollectionView {
            if selectingMonth {
                let year = startDate.year + indexPath.section / 12
                let month = indexPath.section % 12 + 1
                let row = (indexPath.row - 1) / 7
                let column = (indexPath.row - 1) % 7
                let day = Date.getDayByIndexRow(year: year, month: month, row: row, column: column)
                selectDate = Calendar.current.date(from: DateComponents(year: year, month: month, day: day))!
                selectingMonth = false
                InitInterface()
            } else {
                if let precell = collectionView.cellForItem(at: IndexPath(row: selectDate.dayInMonth - 1, section: 0)) as? CalendarDayCollectionViewCell {
                    precell.backgroundColor = .calendarBg
                    precell.dayInMonthLabel.textColor = .deselectDayTextColor
                    precell.dayInWeekLabel.textColor = .deselectDayTextColor
                }
                let cell = collectionView.cellForItem(at: indexPath) as! CalendarDayCollectionViewCell
                cell.backgroundColor = .white
                cell.dayInMonthLabel.textColor = .selectDayTextColor
                cell.dayInWeekLabel.textColor = .selectDayTextColor
                selectDate = Calendar.current.date(from: DateComponents(year: selectDate.year, month: selectDate.monthInYear, day: indexPath.row + 1))!
                InitInterface()
            }
        } else if collectionView == self.scheduleCollectionView && indexPath.section == 1 {

        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if collectionView == self.calendarDayCollectionView {
            if selectingMonth {
                //none
            } else {
                if let cell = collectionView.cellForItem(at: indexPath) as? CalendarDayCollectionViewCell {
                    cell.backgroundColor = .calendarBg
                    cell.dayInMonthLabel.textColor = .deselectDayTextColor
                    cell.dayInWeekLabel.textColor = .deselectDayTextColor
                }
            }
        }
    }
}
