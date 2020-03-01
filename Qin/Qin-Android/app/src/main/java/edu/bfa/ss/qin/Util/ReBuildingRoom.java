package edu.bfa.ss.qin.Util;

import org.json.JSONArray;
import org.json.JSONObject;

import java.util.ArrayList;

import io.realm.Realm;

import static edu.bfa.ss.qin.Util.DatabaseHelper.LeancloudAPIBaseURL;

public class ReBuildingRoom {
    public static void CreateBuildingRoom(boolean refresh) {
        Building.GetAll(true);
        Room.GetAll(true);
        Realm realm = Realm.getDefaultInstance();
        realm.beginTransaction();
        if (refresh == true) {
            try {
                ArrayList<JSONObject> items = new ArrayList<JSONObject>();
                JSONArray DatabaseResults = new JSONArray();
                do {
                    String url = LeancloudAPIBaseURL + "/1.1/classes/ReBuildingRoom?order=BLE&limit=1000&skip=" + items.size();
                    JSONObject response = DatabaseHelper.LCSearch(url);
                    DatabaseResults = response.getJSONArray("results");
                    for (int i = 0; i < DatabaseResults.length(); i++) {
                        JSONObject checkLog = DatabaseResults.getJSONObject(i);
                        String buildingID = checkLog.getString("BuildingID");
                        String roomID = checkLog.getString("RoomID");
                        Building building = realm.where(Building.class).equalTo("ID", buildingID).findFirst();
                        Room room = realm.where(Room.class).equalTo("ID", roomID).findFirst();
                        building.Rooms.add(room);
                        room.Location = building;
                        items.add(checkLog);
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
