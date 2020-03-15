import 'dart:convert';

import '../databasehelper.dart';

class Professor {

  static List<Professor> allProfessors;
  
  var id = "NONE";
  var name = "无效教师";

  static getAllProfessors() async {
    allProfessors = new List<Professor>();
    var results = new List<dynamic>();
    do {
      var currentCount = allProfessors.length;
      var url = Uri.encodeFull(DatabaseHelper.LeancloudAPIBaseURL +
          '/1.1/classes/Professor?skip=$currentCount');
      var response = await DatabaseHelper.leanCloudSearch(url);
      var data = json.decode(response.body);
      results = data["results"];
      for (var checkLog in results) {
        var professor = Professor();
        professor.id = checkLog["ID"];
        professor.name = checkLog["Name"];
        allProfessors.add(professor);
      }
    } while (results.length != 0);
  }
  
  /*
  static Future<Professor> getProfessorByID(String id) async {
    Map<String, String> jsonMap = {
      'ID': id,
    };
    String jsonString = json.encode(jsonMap);
    var url = Uri.encodeFull(DatabaseHelper.LeancloudAPIBaseURL +
        '/1.1/classes/Professor?where=$jsonString');
    var response = await DatabaseHelper.LeanCloudSearch(url);
    var data = json.decode(response.body);
    var results = data["results"];
    if (results.length == 1) {
      var professor = Professor();
      var checkLog = results[0];
      professor.id = checkLog["ID"];
      professor.name = checkLog["Name"];
      return professor;
    } else {
      return new Professor();
    }
  }*/
}