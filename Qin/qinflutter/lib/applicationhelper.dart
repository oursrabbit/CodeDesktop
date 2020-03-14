import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:local_auth/local_auth.dart';
import 'package:sign/Model/building.dart';
import 'package:sign/Model/room.dart';
import 'package:sign/Model/schedule.dart';
import 'package:sign/Model/student.dart';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class ApplicationHelper {

  static setLocalDatabaseBool(String id, bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(id, value);
  }

  static setLocalDatabaseString(String id, String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(id, value);
  }

  static Future<String> getLocalDatabaseString(String id) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      return prefs.getString(id).isEmpty ? "" : prefs.getString(id);
    } catch (e) {
      return "";
    }
  }

  static Future<bool> getLocalDatabaseBool(String id) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      return prefs.getBool(id) == null ? false : prefs.getBool(id);
    } catch (e) {
      return false;
    }
  }

  static Student currentUser = new Student();
  static Schedule checkSchedule = new Schedule();
  static Building checkBuilding = new Building();
  static Room checkRoom = new Room();
  static String checkResult = "";

  static bool canCheckBiometrics = false;
  static bool useBiometrics = false;
  static LocalAuthentication localAuth = LocalAuthentication();

  static bool autoLogin = false;
  static bool openApp = true;
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