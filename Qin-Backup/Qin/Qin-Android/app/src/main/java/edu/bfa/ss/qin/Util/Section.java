package edu.bfa.ss.qin.Util;

import org.json.JSONArray;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.Date;

import io.realm.Realm;
import io.realm.RealmObject;

import static edu.bfa.ss.qin.Util.DatabaseHelper.LeancloudAPIBaseURL;

public class Section extends RealmObject {

    public String ID;
    public String Name;
    public Date StartTime;
    public Date EndTime;
    public int Order;

    public static void GetAll(boolean refresh) {
        Realm realm = Realm.getDefaultInstance();
        realm.beginTransaction();
        if (refresh == true) {
            try {
                ArrayList<Section> items = new ArrayList<Section>();
                JSONArray DatabaseResults = new JSONArray();
                do {
                    String url = LeancloudAPIBaseURL + "/1.1/classes/Section?order=ID&limit=1000&skip=" + items.size();
                    JSONObject response = DatabaseHelper.LCSearch(url);
                    DatabaseResults = response.getJSONArray("results");
                    for (int i = 0; i < DatabaseResults.length(); i++) {
                        JSONObject checkLog = DatabaseResults.getJSONObject(i);
                        Section newItem = realm.createObject(Section.class);
                        newItem.ID = checkLog.getString("ID");
                        newItem.Name = checkLog.getString("Name");
                        newItem.StartTime = ApplicationHelper.getStringDate("HH:mm", checkLog.getString("StartTime"));
                        newItem.EndTime = ApplicationHelper.getStringDate("HH:mm", checkLog.getString("EndTime"));
                        newItem.Order = checkLog.getInt("Order");
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
