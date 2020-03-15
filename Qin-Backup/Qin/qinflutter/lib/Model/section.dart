
import 'dart:convert';

import '../databasehelper.dart';
import '../applicationhelper.dart';

class Section {

  static List<Section> allSections;

  var id = "NONE";
  var startTime = DateTime.now();
  var endTime = DateTime.now();
  var name = "无效课时";
  var order = 0;

  static getAllSections() async {
    allSections = new List<Section>();
    var results = new List<dynamic>();
    do {
      var currentCount = allSections.length;
      var url = Uri.encodeFull(DatabaseHelper.LeancloudAPIBaseURL +
          '/1.1/classes/Section?skip=$currentCount');
      var response = await DatabaseHelper.leanCloudSearch(url);
      var data = json.decode(response.body);
      results = data["results"];
      for (var checkLog in results) {
        var section = Section();
        section.id = checkLog["ID"];
        String startTimeString = checkLog["StartTime"];
        section.startTime = startTimeString.convertToDateTime('HH:mm');
        String endTimeString = checkLog["EndTime"];
        section.endTime = endTimeString.convertToDateTime('HH:mm');
        section.name = checkLog["Name"];
        section.order = checkLog["Order"];
        allSections.add(section);
      }
    } while (results.length != 0);
  }
  
  /*
    static Future<Section> getSectionByID(String id) async {
    Map<String, String> jsonMap = {
      'ID': id,
    };
    String jsonString = json.encode(jsonMap);
    var url = Uri.encodeFull(DatabaseHelper.LeancloudAPIBaseURL +
        '/1.1/classes/Section?where=$jsonString');
    var response = await DatabaseHelper.LeanCloudSearch(url);
    var data = json.decode(response.body);
    var results = data["results"];
    if (results.length == 1) {
      var section = Section();
      var checkLog = results[0];
      section.id = checkLog["ID"];
      String startTimeString = checkLog["StartTime"];
      section.startTime = startTimeString.convertToDateTime('HH:mm');
      String endTimeString = checkLog["EndTime"];
      section.endTime = endTimeString.convertToDateTime('HH:mm');
      section.name = checkLog["Name"];
      section.order = checkLog["Order"];
      return section;
    } else {
      return new Section();
    }
  }

  static Future<Section> getSectionByOrder(int order) async {
    var jsonMap = {
      'Order': order,
    };
    String jsonString = json.encode(jsonMap);
    var url = Uri.encodeFull(DatabaseHelper.LeancloudAPIBaseURL +
        '/1.1/classes/Section?where=$jsonString');
    var response = await DatabaseHelper.LeanCloudSearch(url);
    var data = json.decode(response.body);
    var results = data["results"];
    if (results.length == 1) {
      var section = Section();
      var checkLog = results[0];
      section.id = checkLog["ID"];
      String startTimeString = checkLog["StartTime"];
      section.startTime = startTimeString.convertToDateTime('HH:mm');
      String endTimeString = checkLog["EndTime"];
      section.endTime = endTimeString.convertToDateTime('HH:mm');
      section.name = checkLog["Name"];
      section.order = checkLog["Order"];
      return section;
    } else {
      return new Section();
    }
  }
   */
}
