import 'dart:convert';

import 'package:qinflutter/Model/relationstudentgroup.dart';

import '../databasehelper.dart';

class Group {
  static List<Group> allGroups;

  var id = "NONE";
  var name = "无效分组";

  static getAllGroups() async {
    allGroups = new List<Group>();
    for (var relation in RelationStudentGroup.allRelationStudentGroups) {
      Map<String, String> jsonMap = {
        'ID': relation.groupID,
      };
      String jsonString = json.encode(jsonMap);
      var url = Uri.encodeFull(DatabaseHelper.LeancloudAPIBaseURL +
          '/1.1/classes/Group?where=$jsonString');
      var response = await DatabaseHelper.leanCloudSearch(url);
      var data = json.decode(response.body);
      var results = data["results"];
      if (results.length > 0) {
        var checkLog = results[0];
        var group = Group();
        group.id = checkLog["ID"];
        group.name = checkLog["Name"];
        allGroups.add(group);
      }
    }
  }

  /*
  static Future<List<Group>> getGroupsByStudentID(String id) async {
    var groups = new List<Group>();
    Map<String, String> jsonMap = {
      'StudentID': id,
    };
    String jsonString = json.encode(jsonMap);
    var url = Uri.encodeFull(DatabaseHelper.LeancloudAPIBaseURL +
        '/1.1/classes/ReStudentGroup?where=$jsonString');
    var response = await DatabaseHelper.LeanCloudSearch(url);
    var data = json.decode(response.body);
    var results = data["results"];
    for(var checkLog in results) {
      String groupID = checkLog['GroupID'];
      groups.add(await getGroupByID(groupID));
    }
    return groups;
  }

  static Future<Group> getGroupByID(String id) async {
    Map<String, String> jsonMap = {
      'ID': id,
    };
    String jsonString = json.encode(jsonMap);
    var url = Uri.encodeFull(DatabaseHelper.LeancloudAPIBaseURL +
        '/1.1/classes/Group?where=$jsonString');
    var response = await DatabaseHelper.LeanCloudSearch(url);
    var data = json.decode(response.body);
    var results = data["results"];
    if (results.length == 1) {
      var group = Group();
      var checkLog = results[0];
      group.id = checkLog["ID"];
      group.name = checkLog["Name"];
      return group;
    } else {
      return new Group();
    }
  }*/
}