import 'dart:convert';

import 'package:qinflutter/Model/relationbuildingroom.dart';
import 'package:qinflutter/Model/room.dart';

import '../databasehelper.dart';

class Building {

  static List<Building> allBuildings;

  var id = "NONE";
  var name = "无效建筑";

  static getAllBuildings() async {
    allBuildings = new List<Building>();
    var results = new List<dynamic>();
    do {
      var currentCount = allBuildings.length;
      var url = Uri.encodeFull(DatabaseHelper.LeancloudAPIBaseURL +
          '/1.1/classes/Building?skip=$currentCount');
      var response = await DatabaseHelper.leanCloudSearch(url);
      var data = json.decode(response.body);
      results = data["results"];
      for (var checkLog in results) {
        var building = Building();
        building.id = checkLog["ID"];
        building.name = checkLog["Name"];
        allBuildings.add(building);
      }
    } while (results.length != 0);
  }
  
  List<Room> getRooms() {
    var rooms = new List<Room>();
    for (var relation in RelationBuildingRoom.allRelationBuildingRooms.where((t) => t.buildingID == id)) {
      rooms.add(Room.allRooms.firstWhere((t) => t.id == relation.roomID, orElse: () => new Room()));
    }
    return rooms;
  }
  
/*
  static Future<Building> getBuildingByID(String id) async {
    Map<String, String> jsonMap = {
      'ID': id,
    };
    String jsonString = json.encode(jsonMap);
    var url = Uri.encodeFull(DatabaseHelper.LeancloudAPIBaseURL +
        '/1.1/classes/Building?where=$jsonString');
    var response = await DatabaseHelper.LeanCloudSearch(url);
    var data = json.decode(response.body);
    var results = data["results"];
    if (results.length == 1) {
      var building = Building();
      var checkLog = results[0];
      building.id = checkLog["ID"];
      building.name = checkLog["Name"];
      return building;
    } else {
      return new Building();
    }
  }

  static Future<List<Building>> getAllBuildings() async {
    var buildings = new List<Building>();
    var results = new List<dynamic>();
    do {
      var currentCount = buildings.length;
      var url = Uri.encodeFull(DatabaseHelper.LeancloudAPIBaseURL +
          '/1.1/classes/Building?skip=$currentCount');
      var response = await DatabaseHelper.LeanCloudSearch(url);
      var data = json.decode(response.body);
      results = data["results"];
      for (var checkLog in results) {
        var building = Building();
        building.id = checkLog["ID"];
        building.name = checkLog["Name"];
        buildings.add(building);
      }
    } while (results.length != 0);
    return buildings;
  }*/
}