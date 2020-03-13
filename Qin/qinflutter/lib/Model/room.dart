import 'dart:convert';

import 'package:sign/Model/building.dart';
import 'package:sign/Model/relationbuildingroom.dart';

import '../databasehelper.dart';

class Room {
  static List<Room> allRooms;

  var id = "NONE";
  var name = "无效房间";
  var ble = 0;

  static getAllRooms() async {
    allRooms = new List<Room>();
    var results = new List<dynamic>();
    do {
      var currentCount = allRooms.length;
      var url = Uri.encodeFull(DatabaseHelper.LeancloudAPIBaseURL +
          '/1.1/classes/Room?skip=$currentCount');
      var response = await DatabaseHelper.leanCloudSearch(url);
      var data = json.decode(response.body);
      results = data["results"];
      for (var checkLog in results) {
        var room = Room();
        room.id = checkLog["ID"];
        room.name = checkLog["Name"];
        room.ble = checkLog["BLE"];
        allRooms.add(room);
      }
    } while (results.length != 0);
  }

  Building getLocation() {
    for(var relation in RelationBuildingRoom.allRelationBuildingRooms.where((t)=>t.roomID == id)){
      return Building.allBuildings.firstWhere((t) => t.id == relation.buildingID, orElse: () => new Building());
    }
    return new Building();
  }

  /*static Future<Room> getRoomByID(String id) async {
    Map<String, String> jsonMap = {
      'ID': id,
    };
    String jsonString = json.encode(jsonMap);
    var url = Uri.encodeFull(DatabaseHelper.LeancloudAPIBaseURL +
        '/1.1/classes/Room?where=$jsonString');
    var response = await DatabaseHelper.LeanCloudSearch(url);
    var data = json.decode(response.body);
    var results = data["results"];
    if (results.length == 1) {
      var room = Room();
      var checkLog = results[0];
      room.id = checkLog["ID"];
      room.name = checkLog["Name"];
      room.ble = checkLog["BLE"];
      return room;
    } else {
      return new Room();
    }
  }

  Future<Building> getLocation() async {
    var jsonMap = {
      'RoomID': id,
    };
    String jsonString = json.encode(jsonMap);
    var url = Uri.encodeFull(DatabaseHelper.LeancloudAPIBaseURL +
        '/1.1/classes/ReBuildingRoom?where=$jsonString');
    var response = await DatabaseHelper.LeanCloudSearch(url);
    var data = json.decode(response.body);
    var results = data["results"];
    if (results.length > 0) {
      String buildingID = results[0]['BuildingID'];
      return await Building.getBuildingByID(buildingID);
    }
    else {
      return new Building();
    }
  }*/
}