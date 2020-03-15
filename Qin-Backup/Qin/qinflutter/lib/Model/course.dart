import 'dart:convert';

import '../databasehelper.dart';

class Course {
  static List<Course> allCourses;
  
  var id = "NONE";
  var name = "无效课程";

  static getAllCourses() async {
    allCourses = new List<Course>();
    var results = new List<dynamic>();
    do {
      var currentCount = allCourses.length;
      var url = Uri.encodeFull(DatabaseHelper.LeancloudAPIBaseURL +
          '/1.1/classes/Course?skip=$currentCount');
      var response = await DatabaseHelper.leanCloudSearch(url);
      var data = json.decode(response.body);
      results = data["results"];
      for (var checkLog in results) {
        var building = Course();
        building.id = checkLog["ID"];
        building.name = checkLog["Name"];
        allCourses.add(building);
      }
    } while (results.length != 0);
  }

  /*
  static Future<Course> getCourseByID(String id) async {
    Map<String, String> jsonMap = {
      'ID': id,
    };
    String jsonString = json.encode(jsonMap);
    var url = Uri.encodeFull(DatabaseHelper.LeancloudAPIBaseURL +
        '/1.1/classes/Course?where=$jsonString');
    var response = await DatabaseHelper.LeanCloudSearch(url);
    var data = json.decode(response.body);
    var results = data["results"];
    if (results.length == 1) {
      var course = Course();
      var checkLog = results[0];
      course.id = checkLog["ID"];
      course.name = checkLog["Name"];
      return course;
    } else {
      return new Course();
    }
  }*/
}