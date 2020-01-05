package edu.bfa.ss.qindevice;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.BufferedReader;
import java.io.DataOutputStream;
import java.io.IOException;
import java.io.InputStreamReader;
import java.net.URL;
import java.net.URLEncoder;

import javax.net.ssl.HttpsURLConnection;

public class DatabaseHelper {
    //Lean Cloud
    public static String LeancloudAppid = "YHwFdAE1qj1OcWfJ5xoayLKr-gzGzoHsz";
    public static String LeancloudAppKey = "UbnM6uOP2mxah3nFMzurEDQL";
    public static String LeancloudAPIBaseURL = "https://yhwfdae1.lc-cn-n1-shared.com";
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

    public static String getStudentObjectIDByBeacon(int beacon) {
        try {
            String condition = URLEncoder.encode("{\"StudentBeaconMinor\":" + beacon + "}", "UTF-8");
            String url = DatabaseHelper.LeancloudAPIBaseURL + "/1.1/classes/Students?where=" + condition;
            JSONObject response = DatabaseHelper.LCSearch(url);
            JSONArray DatabaseResults = response.getJSONArray("results");
            if(DatabaseResults.length() != 1) {
                return "";
            } else {
                JSONObject checkLog = DatabaseResults.getJSONObject(0);
                return checkLog.getString("objectId");
            }
        } catch (Exception e) {
            e.printStackTrace();
            return "";
        }
    }

    public static boolean LCUpdateAdvertising(String objectID){
        try {
            String url = DatabaseHelper.LeancloudAPIBaseURL + "/1.1/classes/Students/" + objectID;
            HttpsURLConnection connection = (HttpsURLConnection) (new URL(url)).openConnection();
            connection.setRequestMethod("PUT");
            connection.setRequestProperty(DatabaseHelper.LeancloudIDHeader, DatabaseHelper.LeancloudAppid);
            connection.setRequestProperty(DatabaseHelper.LeancloudKeyHeader, DatabaseHelper.LeancloudAppKey);
            connection.setRequestProperty(DatabaseHelper.HttpContentTypeHeader, DatabaseHelper.HttpContentTypeJSONUTF8);
            JSONObject jsonParam = new JSONObject();
            jsonParam.put("Advertising", "0");
            DataOutputStream os = new DataOutputStream(connection.getOutputStream());
            os.writeBytes(jsonParam.toString());
            os.flush();
            os.close();
            return connection.getResponseCode() == 200;
        } catch (Exception e) {
            return false;
        }
    }
}
