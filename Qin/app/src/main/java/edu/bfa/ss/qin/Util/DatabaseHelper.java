package edu.bfa.ss.qin.Util;

import org.json.JSONException;
import org.json.JSONObject;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.net.URL;

import javax.net.ssl.HttpsURLConnection;

import io.realm.Realm;

public class DatabaseHelper {
    //Lean Cloud
    public static String LeancloudAppid = "YHwFdAE1qj1OcWfJ5xoayLKr-gzGzoHsz";
    public static String LeancloudAppKey = "UbnM6uOP2mxah3nFMzurEDQL";
    public static String LeancloudAPIBaseURL = "https://yhwfdae1.lc-cn-n1-shared.com";
    public static String LeancloudIDHeader = "X-LC-Id";
    public static String LeancloudKeyHeader = "X-LC-Key";
    public static String HttpContentTypeHeader = "Content-Type";
    public static String HttpContentTypeJSON = "application/json";

    public static JSONObject LCSearch(String searchURL) throws IOException, JSONException {
        HttpsURLConnection connection = (HttpsURLConnection) (new URL(searchURL)).openConnection();
        connection.setRequestMethod("GET");
        connection.setRequestProperty(DatabaseHelper.LeancloudIDHeader, DatabaseHelper.LeancloudAppid);
        connection.setRequestProperty(DatabaseHelper.LeancloudKeyHeader, DatabaseHelper.LeancloudAppKey);
        connection.setRequestProperty(DatabaseHelper.HttpContentTypeHeader, DatabaseHelper.HttpContentTypeJSON);
        if (connection.getResponseCode() == 200) {
            return new JSONObject(new BufferedReader(new InputStreamReader(connection.getInputStream())).readLine());
        }
        throw new JSONException("获取失败");
    }
}
