package edu.bfa.ss.qin.Util;

import android.Manifest;
import android.app.Application;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.SharedPreferences;
import android.content.pm.PackageManager;
import android.net.Uri;

import org.json.JSONArray;
import org.json.JSONObject;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.net.URL;
import java.text.DateFormat;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.HashMap;
import java.util.TimeZone;

import javax.net.ssl.HttpsURLConnection;

import edu.bfa.ss.qin.Custom.UI.InCanceledAlterDialog;
import edu.bfa.ss.qin.Custom.UI.QinApplication;
import edu.bfa.ss.qin.InitializationActivity;
import edu.bfa.ss.qin.QinSettingActivity;
import io.realm.Realm;
import io.realm.RealmConfiguration;

import static edu.bfa.ss.qin.Util.DatabaseHelper.LeancloudAPIBaseURL;

public class StaticData {
    public static Student CurrentUser = new Student();
    public static int CheckInRoomID;

    public static Version localVersion = new Version("1.0.0.0");
    public static Version serverVersion;

    public static String toISO8601UTC(Date date) {
        TimeZone tz = TimeZone.getTimeZone("UTC+8");
        DateFormat df = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm'Z'");
        df.setTimeZone(tz);
        return df.format(date);
    }

    public static Date fromISO8601UTC(String dateStr) {
        TimeZone tz = TimeZone.getTimeZone("UTC+8");
        DateFormat df = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'");
        df.setTimeZone(tz);

        try {
            return df.parse(dateStr);
        } catch (ParseException e) {
            e.printStackTrace();
        }

        return null;
    }

    public static String getDateString(String formart, Date date) {
        TimeZone tz = TimeZone.getTimeZone("UTC+8");
        DateFormat df = new SimpleDateFormat(formart);
        df.setTimeZone(tz);
        return df.format(date);
    }

    public static interface StaticDataUpdateInfoListener {
        public void updateInfomation(String message);
    }

    public static boolean checkPermission(StaticDataUpdateInfoListener listener) {
        Context context = QinApplication.getContext();
        if (listener != null)
            listener.updateInfomation("正在检查系统权限...");
        if (context.checkSelfPermission(Manifest.permission.CAMERA) != PackageManager.PERMISSION_GRANTED
                || context.checkSelfPermission(Manifest.permission.BLUETOOTH) != PackageManager.PERMISSION_GRANTED
                || context.checkSelfPermission(Manifest.permission.BLUETOOTH_ADMIN) != PackageManager.PERMISSION_GRANTED
                || context.checkSelfPermission(Manifest.permission.ACCESS_FINE_LOCATION) != PackageManager.PERMISSION_GRANTED
                || context.checkSelfPermission(Manifest.permission.ACCESS_COARSE_LOCATION) != PackageManager.PERMISSION_GRANTED
                || context.checkSelfPermission(Manifest.permission.INTERNET) != PackageManager.PERMISSION_GRANTED
                || context.checkSelfPermission(Manifest.permission.ACCESS_NETWORK_STATE) != PackageManager.PERMISSION_GRANTED) {
            return false;
        }
        return true;
    }

    public static int checkVersion(StaticDataUpdateInfoListener listener) {
        try {
            if (listener != null)
                listener.updateInfomation("正在检查软件版本...");
            String url = DatabaseHelper.LeancloudAPIBaseURL + "/1.1/classes/QinSetting/5e0c10ae562071008e1fcc28";
            JSONObject response = DatabaseHelper.LCSearch(url);
            String serverVersionString = response.getString("Version");
            serverVersion = new Version(serverVersionString);
            if (localVersion.MainVersion != serverVersion.MainVersion || localVersion.FunctionVersion != serverVersion.FunctionVersion || localVersion.BugVersion != serverVersion.BugVersion) {
                return 1;
            }
            return 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 2;
    }

    public static int checkLocalDatabaseVersion(StaticDataUpdateInfoListener listener) {
        if (listener != null)
            listener.updateInfomation("正在检查本地数据版本...");
        SharedPreferences localStore = QinApplication.getContext().getSharedPreferences("localData", Context.MODE_PRIVATE);
        int localDataVersion = localStore.getInt("localDataVersion", -1);
        if (localDataVersion == serverVersion.DatabaseVersion) {
            return 0;
        }
        if (listener != null)
            listener.updateInfomation("正在更新本地数据版本...");
        Realm realm = Realm.getDefaultInstance();
        realm.beginTransaction();
        realm.deleteAll();
        HashMap<String, Building> buildings = new HashMap<String, Building>();
        try {
            if (listener != null)
                listener.updateInfomation("正在获取建筑信息...");
            String url = LeancloudAPIBaseURL + "/1.1/classes/Building?limit=1000&&&&";
            JSONObject response = DatabaseHelper.LCSearch(url);
            JSONArray DatabaseResults = response.getJSONArray("results");
            if (listener != null)
                listener.updateInfomation("正在更新建筑信息...");
            for (int i = 0; i < DatabaseResults.length(); i++) {
                JSONObject checkLog = DatabaseResults.getJSONObject(i);
                Building newBuilding = realm.createObject(Building.class, checkLog.getInt("BuildingID"));
                newBuilding.BuildingName = checkLog.getString("BuildingName");
                buildings.put(newBuilding.BuildingName, newBuilding);
            }
            if (listener != null)
                listener.updateInfomation("正在获取房间信息...");
            url = LeancloudAPIBaseURL + "/1.1/classes/Room?limit=1000&&&&";
            response = DatabaseHelper.LCSearch(url);
            DatabaseResults = response.getJSONArray("results");
            if (listener != null)
                listener.updateInfomation("正在更新房间信息...");
            for (int i = 0; i < DatabaseResults.length(); i++) {
                JSONObject checkLog = DatabaseResults.getJSONObject(i);
                Room newRoom = realm.createObject(Room.class, checkLog.getInt("RoomID"));
                newRoom.RoomName = checkLog.getString("RoomName");
                //Relation
                String locationName = checkLog.getString("BuildingName");
                Building location = buildings.get(locationName);
                newRoom.Location = location;
                location.Rooms.add(newRoom);
            }
            realm.commitTransaction();
            localStore.edit().putInt("localDataVersion", serverVersion.DatabaseVersion).commit();
            return 1;
        } catch (Exception e) {
            realm.cancelTransaction();
            e.printStackTrace();
            return 2;
        } finally {
            realm.close();
        }
    }

    public static String getBaiduAIAccessToken(StaticDataUpdateInfoListener listener) {
        if (listener != null)
            listener.updateInfomation("正在获取人脸识别权限...");
        String url = "https://aip.baidubce.com/oauth/2.0/token?grant_type=client_credentials&client_id=CGFGbXrchcUA0KwfLTpCQG0T&client_secret=IyGcGlMoB26U1Zf2s2qX05O9dETGGxHg";
        try {
            HttpsURLConnection connection = (HttpsURLConnection) (new URL(url)).openConnection();
            connection.setRequestMethod("POST");
            if (connection.getResponseCode() == 200) {
                JSONObject response = new JSONObject(new BufferedReader(new InputStreamReader(connection.getInputStream())).readLine());
                return response.getString("access_token");
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return "";
    }
}
