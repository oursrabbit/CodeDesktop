import 'dart:convert';
import 'package:qinflutter/Model/building.dart';
import 'package:qinflutter/Model/room.dart';
import 'package:qinflutter/Model/schedule.dart';
import 'package:qinflutter/applicationhelper.dart';

import '../databasehelper.dart';

class CheckLog {
  var checkDate = DateTime.now();
  var checkScheduleID = "NONE";
  var checkRoomID = "NONE";

  static Future<List<CheckLog>> getAllCheckLogs() async {
    var studentCheckLogs = new List<CheckLog>();
    var results = new List<dynamic>();
    Map<String, String> jsonMap = {
      'StudentID': ApplicationHelper.currentUser.id,
    };
    String jsonString = json.encode(jsonMap);
    do {
      var currentCount = studentCheckLogs.length;
      var url = Uri.encodeFull(DatabaseHelper.LeancloudAPIBaseURL +
          '/1.1/classes/CheckRecording?where=$jsonString&skip=$currentCount');
      var response = await DatabaseHelper.leanCloudSearch(url);
      var data = json.decode(response.body);
      results = data["results"];
      for (var checkLog in results) {
        var studentCheckLog = CheckLog();
        String checkDateString = checkLog["CheckDate"];
        studentCheckLog.checkDate = checkDateString.convertToDateTime('yyyy-MM-dd HH:mm:ss');
        studentCheckLog.checkScheduleID = checkLog["ScheduleID"];
        studentCheckLog.checkRoomID = checkLog["RoomID"];
        studentCheckLogs.add(studentCheckLog);
      }
    } while (results.length != 0);
    return studentCheckLogs;
  }

  static Future<List<CheckLog>> getCheckRecordingsByScheduleID(String id) async {
    var jsonMap = {
      'ScheduleID': id,
    };
    String jsonString = json.encode(jsonMap);
    var url = Uri.encodeFull(DatabaseHelper.LeancloudAPIBaseURL +
        '/1.1/classes/CheckRecording?where=$jsonString');
    var response = await DatabaseHelper.leanCloudSearch(url);
    var data = json.decode(response.body);
    var results = data["results"];
    var studentCheckLogs = new List<CheckLog>();
    for (var checkLog in results) {
      var studentCheckLog = CheckLog();
      String checkDateString = checkLog["CheckDate"];
      studentCheckLog.checkDate = checkDateString.convertToDateTime('yyyy-MM-dd HH:mm:ss');
      studentCheckLog.checkScheduleID = checkLog["ScheduleID"];
      studentCheckLog.checkRoomID = checkLog["RoomID"];
      studentCheckLogs.add(studentCheckLog);
    }
    return studentCheckLogs;
  }
  
  bool isIncludeKeyword(String keywords)
  {
    for(var kw in keywords.split(' ')){
      var checkRoom = Room.allRooms.firstWhere((t) => t.id == checkRoomID, orElse: () => new Room());
      var checkBuilding = checkRoom.getLocation();
      if(checkRoom.name.contains(kw) || checkBuilding.name.contains(kw) || checkDate.convertToString('yyyy-MM-dd-HH-mm-ss').contains(kw)){
        return true;
      }
    }
    return false;
  }

  /*
    static Future<List<CheckLog>> getAllCheckLogs() async {
    var studentCheckLogs = new List<CheckLog>();
    var results = new List<dynamic>();
    Map<String, String> jsonMap = {
      'StudentID': ApplicationHelper.currentUser.id,
    };
    String jsonString = json.encode(jsonMap);
    do {
      var currentCount = studentCheckLogs.length;
      var url = Uri.encodeFull(DatabaseHelper.LeancloudAPIBaseURL +
          '/1.1/classes/CheckRecording?where=$jsonString&skip=$currentCount');
      var response = await DatabaseHelper.LeanCloudSearch(url);
      var data = json.decode(response.body);
      results = data["results"];
      for (var checkLog in results) {
        var studentCheckLog = CheckLog();
        String checkDateString = checkLog["CheckDate"];
        studentCheckLog.checkDate = checkDateString.convertToDateTime('yyyy-MM-dd HH:mm:ss');
        studentCheckLog.checkScheduleID = checkLog["ScheduleID"];
        studentCheckLog.checkRoomID = checkLog["RoomID"];
        studentCheckLog.checkSchedule = await Schedule.getSchedulesByID(studentCheckLog.checkScheduleID);
        studentCheckLog.checkRoom = await Room.getRoomByID(studentCheckLog.checkRoomID);
        studentCheckLog.checkBuilding = await studentCheckLog.checkRoom.getLocation();
        studentCheckLogs.add(studentCheckLog);
      }
    } while (results.length != 0);
    return studentCheckLogs;
  }

  static Future<List<CheckLog>> getCheckRecordingsByScheduleID(String id) async {
    var jsonMap = {
      'ScheduleID': id,
    };
    String jsonString = json.encode(jsonMap);
    var url = Uri.encodeFull(DatabaseHelper.LeancloudAPIBaseURL +
        '/1.1/classes/CheckRecording?where=$jsonString');
    var response = await DatabaseHelper.LeanCloudSearch(url);
    var data = json.decode(response.body);
    var results = data["results"];
    var studentCheckLogs = new List<CheckLog>();
    for (var checkLog in results) {
      var studentCheckLog = CheckLog();
      String checkDateString = checkLog["CheckDate"];
      studentCheckLog.checkDate = checkDateString.convertToDateTime('yyyy-MM-dd HH:mm:ss');
      studentCheckLog.checkScheduleID = checkLog["ScheduleID"];
      studentCheckLog.checkRoomID = checkLog["RoomID"];
      studentCheckLogs.add(studentCheckLog);
    }
    return studentCheckLogs;
  }
   */
}