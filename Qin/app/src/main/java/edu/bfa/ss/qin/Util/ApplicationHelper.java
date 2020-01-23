package edu.bfa.ss.qin.Util;

import android.Manifest;
import android.content.Context;
import android.content.SharedPreferences;
import android.content.pm.PackageManager;

import org.json.JSONArray;
import org.json.JSONObject;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.net.URL;
import java.text.DateFormat;
import java.text.ParseException;
import java.text.ParsePosition;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.HashMap;
import java.util.TimeZone;

import javax.net.ssl.HttpsURLConnection;

import edu.bfa.ss.qin.Custom.UI.QinApplication;
import io.realm.Realm;
import io.realm.internal.android.ISO8601Utils;

import static edu.bfa.ss.qin.Util.DatabaseHelper.LeancloudAPIBaseURL;

public class ApplicationHelper {

    public enum QinMessage {
        NetError,
        ApplicationVersionError,
        Nothing,
        Success,
        DatabaseUpdated
    }

    public static Student CurrentUser = new Student();
    public static int CheckInRoomID;

    public static byte[] getCheckInRoomID() {
        byte[] bytes = {0x00, 0x00};
        bytes[0] = (byte)(CheckInRoomID >> 8 & 0xFF);
        bytes[1] = (byte)(CheckInRoomID & 0xFF);
        return bytes;
    }

    public static final int localVersion = 1;
    public static int serverVersion = 0;
    public static int databaseVersion = 0;

    public static String toISO8601UTC(Date date) {
        TimeZone tz = TimeZone.getTimeZone("UTC+8");
        DateFormat df = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm'Z'");
        df.setTimeZone(tz);
        return df.format(date);
    }

    public static Date fromISO8601UTC(String dateStr) {
        try {
            return ISO8601Utils.parse(dateStr, new ParsePosition(0));
        } catch (ParseException e) {
            e.printStackTrace();
        }
        return null;
    }

    public static String getDateString(String formart, Date date) {
        //TimeZone tz = TimeZone.getTimeZone("UTC+8");
        DateFormat df = new SimpleDateFormat(formart);
        //df.setTimeZone(tz);
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

    public static ApplicationHelper.QinMessage checkVersion(StaticDataUpdateInfoListener listener) {
        try {
            if (listener != null)
                listener.updateInfomation("正在检查软件版本...");
            String url = DatabaseHelper.LeancloudAPIBaseURL + "/1.1/classes/ApplicationData/5e184373562071008e2f4a0a";
            JSONObject response = DatabaseHelper.LCSearch(url);
            ApplicationHelper.serverVersion = response.getInt("ApplicationVersion");
            ApplicationHelper.databaseVersion = response.getInt("DatabaseVersion");
            if (ApplicationHelper.localVersion == ApplicationHelper.serverVersion) {
                return QinMessage.Success;
            } else {
                return QinMessage.ApplicationVersionError;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return QinMessage.NetError;
    }

    public static QinMessage checkLocalDatabaseVersion(StaticDataUpdateInfoListener listener) {
        if (listener != null)
            listener.updateInfomation("正在检查本地数据版本...");
        SharedPreferences localStore = QinApplication.getContext().getSharedPreferences("localData", Context.MODE_PRIVATE);
        int localDataVersion = localStore.getInt("localDataVersion", -1);
        if (localDataVersion == ApplicationHelper.databaseVersion) {
            return QinMessage.Success;
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
                Building newBuilding = realm.createObject(Building.class, checkLog.getInt("ID"));
                newBuilding.Name = checkLog.getString("Name");
                buildings.put(newBuilding.ID + "", newBuilding);
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
                Room newRoom = realm.createObject(Room.class, checkLog.getInt("ID"));
                newRoom.Name = checkLog.getString("Name");
                //Relation
                int locationID = checkLog.getInt("LocationID");
                Building location = buildings.get(locationID + "");
                newRoom.Location = location;
                location.Rooms.add(newRoom);
            }
            realm.commitTransaction();
            localStore.edit().putInt("localDataVersion", ApplicationHelper.databaseVersion).commit();
            return QinMessage.DatabaseUpdated;
        } catch (Exception e) {
            realm.cancelTransaction();
            e.printStackTrace();
            return QinMessage.NetError;
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
