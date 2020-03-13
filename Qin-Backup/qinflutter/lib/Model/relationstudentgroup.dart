import 'dart:convert';

import 'package:qinflutter/applicationhelper.dart';

import '../databasehelper.dart';

class RelationStudentGroup {

  static List<RelationStudentGroup> allRelationStudentGroups;

  var studentID = "NONE";
  var groupID = "NONE";

  static getAllRelationStudentGroups() async {
    allRelationStudentGroups = new List<RelationStudentGroup>();
    var results = new List<dynamic>();
    do {
      var currentCount = allRelationStudentGroups.length;
      var url = Uri.encodeFull(DatabaseHelper.LeancloudAPIBaseURL +
          '/1.1/classes/ReStudentGroup?skip=$currentCount');
      var response = await DatabaseHelper.leanCloudSearch(url);
      var data = json.decode(response.body);
      results = data["results"];
      for (var checkLog in results) {
        var relation = RelationStudentGroup();
        relation.groupID = checkLog["GroupID"];
        relation.studentID = checkLog["StudentID"];
        allRelationStudentGroups.add(relation);
      }
    } while (results.length != 0);
  }
}