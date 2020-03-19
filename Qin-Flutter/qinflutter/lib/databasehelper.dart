import 'package:http/http.dart' as http;
import 'dart:convert';

import 'applicationhelper.dart';

class DatabaseHelper {
  static var LeancloudAppid = "Tf0m64H1aEhwItMDiMH87pD7-gzGzoHsz";
  static var LeancloudAppKey = "SWhko62oywljuSCkqRnNdjiM";
  static var LeancloudAPIBaseURL = "https://tf0m64h1.lc-cn-n1-shared.com";
  static var LeancloudIDHeader = "X-LC-Id";
  static var LeancloudKeyHeader = "X-LC-Key";
  static var HttpContentTypeHeader = "content-type";
  static var HttpContentTypeJSONUTF8 = "application/json";

  static Future<http.Response> leanCloudSearch(String url) async{
    String dataURL = url;
    http.Response response = await http.get(
        dataURL,
        headers: {
          LeancloudIDHeader: LeancloudAppid,
          LeancloudKeyHeader: LeancloudAppKey,
          HttpContentTypeHeader: HttpContentTypeJSONUTF8,
        });
    return response;
  }

  static Future<bool> leanCloudLogin(String username, String password) async{
    try {
      Map<String, String> jsonMap = {
        'username': username,
        'password': password,
      };
      String jsonString = json.encode(jsonMap);
      var url = Uri.encodeFull(
          DatabaseHelper.LeancloudAPIBaseURL + '/1.1/login');
      http.Response response = await http.post(
          url,
          body: jsonString,
          headers: {
            LeancloudIDHeader: LeancloudAppid,
            LeancloudKeyHeader: LeancloudAppKey,
            HttpContentTypeHeader: HttpContentTypeJSONUTF8,
          });
      var data = json.decode(response.body);
      return username == data["username"];
    } catch (e) {
      return false;
    }
  }

  static Future<bool> leanCloudResetPassword(String email) async {
    Map<String, String> jsonMap = {
      'email': email,
    };
    String jsonString = json.encode(jsonMap);
    var url = Uri.encodeFull(
        DatabaseHelper.LeancloudAPIBaseURL + '/1.1/requestPasswordReset');
    http.Response response = await http.post(
        url,
        body: jsonString,
        headers: {
          LeancloudIDHeader: LeancloudAppid,
          LeancloudKeyHeader: LeancloudAppKey,
          HttpContentTypeHeader: HttpContentTypeJSONUTF8,
        });
    var data = json.decode(response.body);
    return true;
  }

  static Future<bool> updateAdvertising() async {
    try {
      var url = Uri.encodeFull(
          DatabaseHelper.LeancloudAPIBaseURL + "/1.1/classes/Student/" +
              ApplicationHelper.currentUser.objectID);

      http.Response response = await http.put(url, body: jsonEncode(<String, int>{
        "Advertising": 1
      }), headers: {
        LeancloudIDHeader: LeancloudAppid,
        LeancloudKeyHeader: LeancloudAppKey,
        HttpContentTypeHeader: HttpContentTypeJSONUTF8,
      });
      var data = json.decode(response.body);
      var updateTime = data["updatedAt"];
      return updateTime == null ? false : true;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> checkAdvertising() async{
    try {
      var url = Uri.encodeFull(
          DatabaseHelper.LeancloudAPIBaseURL + "/1.1/classes/Student/" +
              ApplicationHelper.currentUser.objectID);
      http.Response response = await http.get(url, headers: {
        LeancloudIDHeader: LeancloudAppid,
        LeancloudKeyHeader: LeancloudAppKey,
        HttpContentTypeHeader: HttpContentTypeJSONUTF8,
      });
      var data = json.decode(response.body);
      var advertising = data["Advertising"];
      return advertising == 0 ? true : false;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> uploadCheckRecording() async {
    try {
      var timeurl = Uri.encodeFull(DatabaseHelper.LeancloudAPIBaseURL + "/1.1/date");
      http.Response timeresponse = await http.get(timeurl, headers: {
        LeancloudIDHeader: LeancloudAppid,
        LeancloudKeyHeader: LeancloudAppKey,
        HttpContentTypeHeader: HttpContentTypeJSONUTF8,
      });
      var timedata = json.decode(timeresponse.body);
      var timeiso = timedata["iso"];
      var checkDate = DateTime.parse(timeiso).toLocal();

      var url = Uri.encodeFull(DatabaseHelper.LeancloudAPIBaseURL + "/1.1/classes/CheckRecording");

      http.Response response = await http.post(url, body: jsonEncode(<String, String>{
        "StudentID": ApplicationHelper.currentUser.id,
        "RoomID" : ApplicationHelper.checkRoom.id,
        "CheckDate" : checkDate.convertToString("yyyy-MM-dd HH:mm:ss"),
        "ScheduleID" : ApplicationHelper.checkSchedule.id
      }), headers: {
        LeancloudIDHeader: LeancloudAppid,
        LeancloudKeyHeader: LeancloudAppKey,
        HttpContentTypeHeader: HttpContentTypeJSONUTF8,
      });
      return response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }
}

class BaiduAiHelper {

  static Future<String> getAccessToken() async
  {
    try {
      var url = Uri.encodeFull("https://aip.baidubce.com/oauth/2.0/token?grant_type=client_credentials&client_id=CGFGbXrchcUA0KwfLTpCQG0T&client_secret=IyGcGlMoB26U1Zf2s2qX05O9dETGGxHg");
      http.Response response = await http.post(url);
      var data = json.decode(response.body);
      return data["access_token"];
    } catch (e) {
      return "";
    }
  }

  static Future<bool> faceDetect(String imageInBASE64, String accessToken) async {
    try {
      var url = Uri.encodeFull(
          "https://aip.baidubce.com/rest/2.0/face/v3/search?access_token=$accessToken");
      http.Response response = await http.post(url,
        //headers: {"Content-Type": "application/json"},
        body: {"image": imageInBASE64,
          "image_type": "BASE64",
          "group_id_list": "2019BK",
          "user_id": ApplicationHelper.currentUser.baiduFaceID,
          "liveness_control": "NORMAL"
        },);
      var data = json.decode(response.body);
      if (data['error_msg'] == "SUCCESS") {
        double score = data["result"]["user_list"][0]["score"];
        if (score > 80) {
          return true;
        }
      } else {
        print("FFFFDDDDTTTTCCC:" + data['error_msg']);
        return false;
      }
    } catch (e) {
      return false;
    }
    return false;
  }
}