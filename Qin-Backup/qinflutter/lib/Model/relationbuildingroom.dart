import 'dart:convert';

import 'package:qinflutter/applicationhelper.dart';

import '../databasehelper.dart';

class RelationBuildingRoom {

  static List<RelationBuildingRoom> allRelationBuildingRooms;

  var buildingID = "NONE";
  var roomID = "NONE";

  static getAllRelationBuildingRooms() async {
    allRelationBuildingRooms = new List<RelationBuildingRoom>();
    var results = new List<dynamic>();
    do {
      var currentCount = allRelationBuildingRooms.length;
      var url = Uri.encodeFull(DatabaseHelper.LeancloudAPIBaseURL +
          '/1.1/classes/ReBuildingRoom?skip=$currentCount');
      var response = await DatabaseHelper.leanCloudSearch(url);
      var data = json.decode(response.body);
      results = data["results"];
      for (var checkLog in results) {
        var relation = RelationBuildingRoom();
        relation.roomID = checkLog["RoomID"];
        relation.buildingID = checkLog["BuildingID"];
        allRelationBuildingRooms.add(relation);
      }
    } while (results.length != 0);
  }
}