package edu.bfa.ss.qin.Util;

import org.json.JSONArray;
import org.json.JSONObject;

import java.net.URLEncoder;

public class Group {
    public String ID = "";
    public String Name = "";

    public static void GetGroup() {
        try {
            String condition = URLEncoder.encode("{\"StudentID\":\"" + ApplicationHelper.CurrentUser.ID + "\"}", "UTF-8");
            String url = DatabaseHelper.LeancloudAPIBaseURL + "/1.1/classes/ReStudentGroup?where=" + condition;
            JSONObject response = DatabaseHelper.LCSearch(url);
            JSONArray DatabaseResults = response.getJSONArray("results");
            for (int i = 0; i < DatabaseResults.length(); i++) {
                JSONObject checkLog = DatabaseResults.getJSONObject(i);
                String groupID = checkLog.getString("GroupID");
                ApplicationHelper.CurrentUser.GroupsID.add(groupID);
            }
        } catch (Exception ignore) {
            return;
        }
    }
}
