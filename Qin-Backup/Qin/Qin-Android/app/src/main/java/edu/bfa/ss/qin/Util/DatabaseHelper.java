package edu.bfa.ss.qin.Util;

import org.json.JSONException;
import org.json.JSONObject;

import java.io.BufferedReader;
import java.io.DataOutputStream;
import java.io.IOException;
import java.io.InputStreamReader;
import java.net.URL;

import javax.net.ssl.HttpsURLConnection;

import io.realm.Realm;

public class DatabaseHelper {
    //Lean Cloud
    public static String LeancloudAppid = "Tf0m64H1aEhwItMDiMH87pD7-gzGzoHsz";
    public static String LeancloudAppKey = "SWhko62oywljuSCkqRnNdjiM";
    public static String LeancloudAPIBaseURL = "https://tf0m64h1.lc-cn-n1-shared.com";
    public static String LeancloudIDHeader = "X-LC-Id";
    public static String LeancloudKeyHeader = "X-LC-Key";
    public static String HttpContentTypeHeader = "Content-Type";
    public static String HttpContentTypeJSONUTF8 = "application/json; charset=utf-8";

    public static JSONObject LCSearch(String searchURL) throws IOException, JSONException {
        HttpsURLConnection connection = (HttpsURLConnection) (new URL(searchURL)).openConnection();
        connection.setRequestMethod("GET");
        connection.setRequestProperty(DatabaseHelper.LeancloudIDHeader, DatabaseHelper.LeancloudAppid);
        connection.setRequestProperty(DatabaseHelper.LeancloudKeyHeader, DatabaseHelper.LeancloudAppKey);
        connection.setRequestProperty(DatabaseHelper.HttpContentTypeHeader, DatabaseHelper.HttpContentTypeJSONUTF8);
        if (connection.getResponseCode() == 200) {
            return new JSONObject(new BufferedReader(new InputStreamReader(connection.getInputStream())).readLine());
        }
        throw new JSONException("获取失败");
    }

    public static boolean LCUpdateAdvertising(){
        try {
            String url = DatabaseHelper.LeancloudAPIBaseURL + "/1.1/classes/Student/" + ApplicationHelper.CurrentUser.LCObjectID;
            HttpsURLConnection connection = (HttpsURLConnection) (new URL(url)).openConnection();
            connection.setRequestMethod("PUT");
            connection.setRequestProperty(DatabaseHelper.LeancloudIDHeader, DatabaseHelper.LeancloudAppid);
            connection.setRequestProperty(DatabaseHelper.LeancloudKeyHeader, DatabaseHelper.LeancloudAppKey);
            connection.setRequestProperty(DatabaseHelper.HttpContentTypeHeader, DatabaseHelper.HttpContentTypeJSONUTF8);
            JSONObject jsonParam = new JSONObject();
            jsonParam.put("Advertising", "1");
            DataOutputStream os = new DataOutputStream(connection.getOutputStream());
            os.writeBytes(jsonParam.toString());
            os.flush();
            os.close();
            return connection.getResponseCode() == 200;
        } catch (Exception e) {
            return false;
        }
    }

    public static boolean LCCheckAdvertising(String value) {
        try {
            String url = DatabaseHelper.LeancloudAPIBaseURL + "/1.1/classes/Student/" + ApplicationHelper.CurrentUser.LCObjectID;
            JSONObject response = DatabaseHelper.LCSearch(url);
            return response.getString("Advertising").equals(value);
        } catch (Exception e) {
            return  false;
        }
    }

    public static boolean LCUploadCheckLog() {
        String url = LeancloudAPIBaseURL + "/1.1/classes/CheckRecording";
        Realm realm = Realm.getDefaultInstance();
        Room checkInRoom = realm.where(Room.class).equalTo("BLE", ApplicationHelper.CheckInRoomID).findFirst();
        try {
            HttpsURLConnection connection = (HttpsURLConnection) (new URL(url)).openConnection();
            connection.setRequestMethod("POST");
            connection.setRequestProperty(LeancloudIDHeader, LeancloudAppid);
            connection.setRequestProperty(LeancloudKeyHeader, LeancloudAppKey);
            connection.setRequestProperty(HttpContentTypeHeader, HttpContentTypeJSONUTF8);
            connection.setDoOutput(true);
            connection.setDoInput(true);
            JSONObject jsonParam = new JSONObject();
            jsonParam.put("StudentID", ApplicationHelper.CurrentUser.BLE);
            jsonParam.put("RoomID", checkInRoom.ID);
            DataOutputStream os = new DataOutputStream(connection.getOutputStream());
            os.writeBytes(jsonParam.toString());
            os.flush();
            os.close();
            return connection.getResponseCode() == 201;
        } catch (Exception e) {
          return false;
        } finally {
            realm.close();
            realm = null;
        }
    }
}
