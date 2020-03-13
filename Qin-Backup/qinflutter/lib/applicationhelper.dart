import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:qinflutter/Model/building.dart';
import 'package:qinflutter/Model/room.dart';
import 'package:qinflutter/Model/schedule.dart';
import 'package:qinflutter/Model/student.dart';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class ApplicationHelper {
  static getLocalDatabase(String id, String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(id, value);
  }

  static Future<String> getLocalDatabaseString(String id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(id);
  }

  static bool isOpen = true;
  static Student currentUser = new Student();
  static Schedule checkSchedule = new Schedule();
  static Building checkBuilding = new Building();
  static Room checkRoom = new Room();
  static String checkResult = "";
}

extension StringDateConvert on String {
    DateTime convertToDateTime(String formatter)
    {
      return DateFormat(formatter).parse(this);
    }

    String removeLaseChar()
    {
      if(this == null || this == "")
        return this;
      else
        return this.substring(0, this.length - 2);
    }
}

extension DateStringConvert on DateTime {
    String convertToString(String fomatter)
    {
      return DateFormat(fomatter).format(this);
    }
}