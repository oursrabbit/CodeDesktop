package edu.bfa.ss.qin.Util;

import org.json.JSONArray;
import org.json.JSONObject;

import java.util.ArrayList;

import io.realm.Realm;
import io.realm.RealmList;
import io.realm.RealmObject;
import io.realm.annotations.PrimaryKey;

import static edu.bfa.ss.qin.Util.DatabaseHelper.LeancloudAPIBaseURL;

public class Room extends RealmObject {

    public String ID;
    public String Name;
    public int BLE;
    public Building Location;

    public static void GetAll(boolean refresh) {
        Realm realm = Realm.getDefaultInstance();
        realm.beginTransaction();
        if (refresh == true) {
            try {
                ArrayList<Room> items = new ArrayList<Room>();
                JSONArray DatabaseResults = new JSONArray();
                do {
                    String url = LeancloudAPIBaseURL + "/1.1/classes/Room?order=ID&limit=1000&skip=" + items.size();
                    JSONObject response = DatabaseHelper.LCSearch(url);
                    DatabaseResults = response.getJSONArray("results");
                    for (int i = 0; i < DatabaseResults.length(); i++) {
                        JSONObject checkLog = DatabaseResults.getJSONObject(i);
                        Room newItem = realm.createObject(Room.class);
                        newItem.ID = checkLog.getString("ID");
                        newItem.Name = checkLog.getString("Name");
                        newItem.BLE = checkLog.getInt("BLE");
                        items.add(newItem);
                    }
                } while (DatabaseResults.length() != 0);
            } catch (Exception ignored) {
                realm.cancelTransaction();
                realm.close();
                return;
            }
        }
        realm.commitTransaction();
        realm.close();
    }
}
