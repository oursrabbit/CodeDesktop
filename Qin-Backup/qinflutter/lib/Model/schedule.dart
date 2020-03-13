import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:qinflutter/Model/building.dart';
import 'package:qinflutter/Model/checklog.dart';
import 'package:qinflutter/Model/course.dart';
import 'package:qinflutter/Model/professor.dart';
import 'package:qinflutter/Model/room.dart';
import 'package:qinflutter/Model/section.dart';
import 'package:qinflutter/applicationhelper.dart';
import 'package:qinflutter/values/colors.dart';

import '../databasehelper.dart';

class Schedule {
  static List<Schedule> allSchedules;

  var id = "NONE";
  var startDate = DateTime.now();
  var continueWeek = 0;
  var startSectionID = "NONE";
  var continueSection = 0;
  var roomID = "NONE";
  var courseID = "NONE";
  var professorsID = List<String>();

  var cellColorIndex = -1;
  var startSection = Section();
  var endSection = Section();
  var x = 0.0;
  var height = 0.0;
  var room = Room();
  var building = Building();
  var course = Course();
  var professors = List<Professor>();
  var checkLogs = List<CheckLog>();

  static getSchedulesByStudentID(String id) async {
    allSchedules = new List<Schedule>();
    var regex = '(^$id;)|(;$id;)|(;$id\$)|(^$id\$)';
    var jsonMap = {
      'StudentID': {
        '\$regex': regex
      },
    };
    String jsonString = json.encode(jsonMap);
    var url = Uri.encodeFull(DatabaseHelper.LeancloudAPIBaseURL +
        '/1.1/classes/Schedule?where=$jsonString');
    var response = await DatabaseHelper.leanCloudSearch(url);
    var data = json.decode(response.body);
    var results = data["results"];
    for (var checkLog in results) {
      var newSchedule = new Schedule();
      newSchedule.id = checkLog["ID"];
      String startDate = checkLog["StartDate"];
      newSchedule.startDate = startDate.convertToDateTime('yyyy-MM-dd');
      newSchedule.continueWeek = checkLog["ContinueWeek"];
      newSchedule.startSectionID = checkLog["StartSectionID"];
      newSchedule.continueSection = checkLog["ContinueSection"];
      newSchedule.startSection = Section.allSections.firstWhere((t) => t.id == newSchedule.startSectionID, orElse: () => new Section());
      newSchedule.endSection = Section.allSections.firstWhere((t) => t.order == newSchedule.startSection.order + newSchedule.continueSection - 1, orElse: () => new Section());
      newSchedule.courseID = checkLog["CourseID"];
      newSchedule.roomID = checkLog["RoomID"];
      String professorsID = checkLog["ProfessorID"];
      newSchedule.professorsID = professorsID.split(';');
      int precolorIndex = allSchedules.length == 0 ? -1 : allSchedules.last.cellColorIndex;
      do{
        newSchedule.cellColorIndex = Random.secure().nextInt(AppColors.ScheduleCellColors.length - 1);
      }while (precolorIndex == newSchedule.cellColorIndex);
      newSchedule.x = newSchedule.startSection.startTime.hour * 60.0 + 7.0 + newSchedule.startSection.startTime.minute * 1;
      newSchedule.height = (newSchedule.endSection.endTime.hour * 60.0 + newSchedule.endSection.endTime.minute * 1) - (newSchedule.startSection.startTime.hour * 60.0 + newSchedule.startSection.startTime.minute * 1);
      newSchedule.course = Course.allCourses.firstWhere((t) => t.id == newSchedule.courseID, orElse: () => new Course());
      newSchedule.room = Room.allRooms.firstWhere((t) => t.id == newSchedule.roomID, orElse: () => new Room());
      newSchedule.building = newSchedule.room.getLocation();
      for(var proid in newSchedule.professorsID) {
        newSchedule.professors.add(Professor.allProfessors.firstWhere((t) => t.id == proid, orElse: () => new Professor()));
      }
      newSchedule.checkLogs = await CheckLog.getCheckRecordingsByScheduleID(newSchedule.id);
      allSchedules.add(newSchedule);
    }
  }

  CheckLog getCheckLogOnDate(DateTime selectedDay) {
    for(var cl in checkLogs) {
      var checkStart = DateTime(selectedDay.year, selectedDay.month, selectedDay.day, startSection.startTime.hour, startSection.startTime.minute, startSection.startTime.second);
      var checkEnd = DateTime(selectedDay.year, selectedDay.month, selectedDay.day, endSection.endTime.hour, endSection.endTime.minute, endSection.endTime.second);
      if(cl.checkDate.isAfter(checkStart) && cl.checkDate.isBefore(checkEnd) && cl.checkScheduleID == id && cl.checkRoomID == roomID)
        return cl;
    }
    return new CheckLog();
  }

  static List<Schedule> getSchedulesOnDate(DateTime date) {
    var ss = List<Schedule>();
    for(var s in Schedule.allSchedules){
      for(var i = 0; i<s.continueWeek; i++){
        var sday = s.startDate.add(Duration(days: i * 7));
        if(sday.year == date.year && sday.month == date.month && sday.day == date.day){
          ss.add(s);
          break;
        }
      }
    }
    return ss;
  }

  /*
    static Future<List<Schedule>> getSchedulesByStudentID(String id) async {
    List<Schedule> schedules = new List<Schedule>();
    var regex = '(^$id;)|(;$id;)|(;$id\$)|(^$id\$)';
    var jsonMap = {
      'StudentID': {
        '\$regex': regex
      },
    };
    String jsonString = json.encode(jsonMap);
    var url = Uri.encodeFull(DatabaseHelper.LeancloudAPIBaseURL +
        '/1.1/classes/Schedule?where=$jsonString');
    var response = await DatabaseHelper.LeanCloudSearch(url);
    var data = json.decode(response.body);
    var results = data["results"];
    for (var checkLog in results) {
      var newSchedule = new Schedule();
      newSchedule.id = checkLog["ID"];
      String startDate = checkLog["StartDate"];
      newSchedule.startDate = startDate.convertToDateTime('yyyy-MM-dd');
      newSchedule.continueWeek = checkLog["ContinueWeek"];
      newSchedule.startSectionID = checkLog["StartSectionID"];
      newSchedule.continueSection = checkLog["ContinueSection"];
      newSchedule.startSection = await Section.getSectionByID(newSchedule.startSectionID);
      newSchedule.endSection = await Section.getSectionByOrder(newSchedule.startSection.order + newSchedule.continueSection - 1);
      newSchedule.courseID = checkLog["CourseID"];
      newSchedule.roomID = checkLog["RoomID"];
      String professorsID = checkLog["ProfessorID"];
      newSchedule.professorsID = professorsID.split(';');
      int precolorIndex = schedules.length == 0 ? -1 : schedules.last.cellColorIndex;
      do{
        newSchedule.cellColorIndex = Random.secure().nextInt(AppColors.ScheduleCellColors.length - 1);
      }while (precolorIndex == newSchedule.cellColorIndex);
      newSchedule.x = newSchedule.startSection.startTime.hour * 60.0 + 7.0 + newSchedule.startSection.startTime.minute * 1;
      newSchedule.height = (newSchedule.endSection.endTime.hour * 60.0 + newSchedule.endSection.endTime.minute * 1) - (newSchedule.startSection.startTime.hour * 60.0 + newSchedule.startSection.startTime.minute * 1);
      newSchedule.course = await Course.getCourseByID(newSchedule.courseID);
      newSchedule.room = await Room.getRoomByID(newSchedule.roomID);
      newSchedule.building = await newSchedule.room.getLocation();
      for(var proid in newSchedule.professorsID) {
        newSchedule.professors.add(await Professor.getProfessorByID(proid));
      }
      newSchedule.checkLogs = await CheckLog.getCheckRecordingsByScheduleID(newSchedule.id);
      schedules.add(newSchedule);
    }
    return schedules;
  }

  static Future<Schedule> getSchedulesByID(String id) async {
    var jsonMap = {
      'ID': id
    };
    String jsonString = json.encode(jsonMap);
    var url = Uri.encodeFull(DatabaseHelper.LeancloudAPIBaseURL +
        '/1.1/classes/Schedule?where=$jsonString');
    var response = await DatabaseHelper.LeanCloudSearch(url);
    var data = json.decode(response.body);
    var results = data["results"];
    if (results.length != 0) {
      var checkLog = results[0];
      var newSchedule = new Schedule();
      newSchedule.id = checkLog["ID"];
      String startDate = checkLog["StartDate"];
      newSchedule.startDate = startDate.convertToDateTime('yyyy-MM-dd');
      newSchedule.continueWeek = checkLog["ContinueWeek"];
      newSchedule.startSectionID = checkLog["StartSectionID"];
      newSchedule.continueSection = checkLog["ContinueSection"];
      newSchedule.startSection =
      await Section.getSectionByID(newSchedule.startSectionID);
      newSchedule.endSection = await Section.getSectionByOrder(
          newSchedule.startSection.order + newSchedule.continueSection - 1);
      newSchedule.courseID = checkLog["CourseID"];
      newSchedule.roomID = checkLog["RoomID"];
      String professorsID = checkLog["ProfessorID"];
      newSchedule.professorsID = professorsID.split(';');
      newSchedule.x = newSchedule.startSection.startTime.hour * 60.0 + 7.0 +
          newSchedule.startSection.startTime.minute * 1;
      newSchedule.height = (newSchedule.endSection.endTime.hour * 60.0 +
          newSchedule.endSection.endTime.minute * 1) -
          (newSchedule.startSection.startTime.hour * 60.0 +
              newSchedule.startSection.startTime.minute * 1);
      newSchedule.course = await Course.getCourseByID(newSchedule.courseID);
      newSchedule.room = await Room.getRoomByID(newSchedule.roomID);
      newSchedule.building = await newSchedule.room.getLocation();
      for (var proid in newSchedule.professorsID) {
        newSchedule.professors.add(await Professor.getProfessorByID(proid));
      }
      newSchedule.checkLogs =
      await CheckLog.getCheckRecordingsByScheduleID(newSchedule.id);
      return newSchedule;
    } else {
      return new Schedule();
    }
  }
   */
}