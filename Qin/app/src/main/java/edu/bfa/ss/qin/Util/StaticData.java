package edu.bfa.ss.qin.Util;

import android.Manifest;
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
import io.realm.Realm;

import static edu.bfa.ss.qin.Util.DatabaseHelper.LeancloudAPIBaseURL;

public class StaticData {
    public static String StudentID = "";
    public static Room CheckInRoom;
    public static Boolean InitState = true;
    private static Context errorHost;
    private static Realm realm;

    public static boolean InitQinApplication(Context errorContext, Realm realm) {
        errorHost = errorContext;
        StaticData.realm = realm;
        InitState = false;

        if (checkPermission() == false){
            return false;
        }
        if(checkVersion() == false) {
            return  false;
        }

        new Thread(new Runnable() {
            @Override
            public void run() {
                getBaiduAIAccessToken();
            }
        }).start();
        return true;
    }

    private static class Version {
        public int MainVersion;
        public int FunctionVersion;
        public int BugVersion;
        public int DatabaseVersion;

        public Version(String versionString) {
            MainVersion = Integer.parseInt( versionString.split("\\.")[0]);
            FunctionVersion = Integer.parseInt( versionString.split("\\.")[1]);
            BugVersion = Integer.parseInt( versionString.split("\\.")[2]);
            DatabaseVersion = Integer.parseInt( versionString.split("\\.")[3]);
        }
    }

    public static String toISO8601UTC(Date date) {
        TimeZone tz = TimeZone.getTimeZone("UTC");
        DateFormat df = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm'Z'");
        df.setTimeZone(tz);
        return df.format(date);
    }

    public static Date fromISO8601UTC(String dateStr) {
        TimeZone tz = TimeZone.getTimeZone("UTC");
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
        TimeZone tz = TimeZone.getTimeZone("UTC");
        DateFormat df = new SimpleDateFormat(formart);
        df.setTimeZone(tz);
        return df.format(date);
    }

    public static boolean checkPermission(Context context) {
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

    private static  boolean checkPermission() {
        if (StaticData.checkPermission(errorHost) == false) {
            new InCanceledAlterDialog.Builder(errorHost).setMessage("未开启硬件权限，请前往应用设置开启")
                    .setPositiveButton("前往", new DialogInterface.OnClickListener() {
                        public void onClick(DialogInterface dialog, int id) {
                            errorHost.startActivity(new Intent(android.provider.Settings.ACTION_APPLICATION_DETAILS_SETTINGS).setData(Uri.parse("package:" + "edu.bfa.ss.qin")));
                        }
                    }).show();
            return false;
        } else {
            return true;
        }
    }

    private static boolean checkVersion() {
        SharedPreferences localStore = errorHost.getSharedPreferences("localData", Context.MODE_PRIVATE);
        String versionString = localStore.getString("QinVersion", "1.0.0.0");
        Version localVersion = new Version(versionString);
        try {
            String url = DatabaseHelper.LeancloudAPIBaseURL + "/1.1/classes/QinSetting/5e0c10ae562071008e1fcc28";
            JSONObject response = DatabaseHelper.LCSearch(url);
            String serverVersionString = response.getString("Version");
            Version serverVersion = new Version(serverVersionString);
            if (localVersion.MainVersion != serverVersion.MainVersion || localVersion.FunctionVersion != serverVersion.FunctionVersion || localVersion.BugVersion != serverVersion.BugVersion) {
                new InCanceledAlterDialog.Builder(errorHost).setMessage("请更新\n\n本机：" + localVersion + "最新版：" + serverVersion)
                        .setPositiveButton("前往", new DialogInterface.OnClickListener() {
                            public void onClick(DialogInterface dialog, int id) {
                                errorHost.startActivity(new Intent(Intent.ACTION_VIEW, Uri.parse("https://www.baidu.com")).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK));
                            }
                        }).show();
                return false;
            }
            if (localVersion.DatabaseVersion != serverVersion.DatabaseVersion) {
                if (updateLocalDatabase() == false)
                    return false;
                localStore.edit().putString("QinVersion", serverVersionString).commit();
            }
            return true;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    private static boolean updateLocalDatabase() {
        realm.beginTransaction();
        realm.deleteAll();
        HashMap<String, Building> buildings = new HashMap<String, Building>();
        //Building
        try {
            String url = LeancloudAPIBaseURL + "/1.1/classes/Building?limit=1000&&&&";
            JSONObject response = DatabaseHelper.LCSearch(url);
            JSONArray DatabaseResults = response.getJSONArray("results");
            for (int i = 0; i < DatabaseResults.length(); i++) {
                JSONObject checkLog = DatabaseResults.getJSONObject(i);
                Building newBuilding = realm.createObject(Building.class);
                newBuilding.BuildingName = checkLog.getString("BuildingName");
                buildings.put(newBuilding.BuildingName, newBuilding);
            }
        } catch (Exception e) {
            realm.cancelTransaction();
            e.printStackTrace();
            return false;
        }
        //Room
        try {
            String url = LeancloudAPIBaseURL + "/1.1/classes/Room?limit=1000&&&&";
            JSONObject response = DatabaseHelper.LCSearch(url);
            JSONArray DatabaseResults = response.getJSONArray("results");
            for (int i = 0; i < DatabaseResults.length(); i++) {
                JSONObject checkLog = DatabaseResults.getJSONObject(i);
                Room newRoom = realm.createObject(Room.class);
                newRoom.RoomName = checkLog.getString("RoomName");
                //Relation
                String locationName = checkLog.getString("BuildingName");
                Building location = buildings.get(locationName);
                newRoom.Location = location;
                location.Rooms.add(newRoom);
            }
        } catch (Exception e) {
            realm.cancelTransaction();
            e.printStackTrace();
            return false;
        }
        realm.commitTransaction();
        return true;
    }

    public static String getBaiduAIAccessToken() {
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
