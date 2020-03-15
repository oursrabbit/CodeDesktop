import 'dart:convert';

import '../databasehelper.dart';

class Student {
  var objectID = "NONE";
  var id = "NONE";
  var baiduFaceID = "NONE";
  var advertising = 0;
  var name = "无效学生";
  var ble = 0;
  var email = "";

  static Future<Student> getStudentByID(String id) async {
    Map<String, String> jsonMap = {
      'ID': id,
    };
    String jsonString = json.encode(jsonMap);
    var url = Uri.encodeFull(DatabaseHelper.LeancloudAPIBaseURL +
        '/1.1/classes/Student?where=$jsonString');
    var response = await DatabaseHelper.leanCloudSearch(url);
    var data = json.decode(response.body);
    var results = data["results"];
    if (results.length == 1) {
      var student = Student();
      var checkLog = results[0];
      student.advertising = 0;
      student.baiduFaceID = checkLog["BaiduFaceID"] as String;
      student.objectID = checkLog["objectId"] as String;
      student.ble = checkLog["BLE"];
      student.id = checkLog["ID"] as String;
      student.name = checkLog["Name"] as String;
      student.email = checkLog["Email"] as String;
      return student;
    } else {
      return new Student();
    }
  }
}