package edu.bfa.ss.qin.Util;

import org.json.JSONArray;
import org.json.JSONObject;

import java.net.URLEncoder;
import java.util.ArrayList;

public class Student {
    public String LCObjectID;
    public String ID;
    public int Advertising;
    public String BaiduFaceID;
    public int BLE;
    public String Name;

    public ArrayList<String> GroupsID = new ArrayList<>();
    public ArrayList<Schedule> Schedules = new ArrayList<>();

    public static boolean SetupCurrentStudent() {
        try {
            String condition = URLEncoder.encode("{\"ID\":\"" + ApplicationHelper.CurrentUser.ID + "\"}", "UTF-8");
            String url = DatabaseHelper.LeancloudAPIBaseURL + "/1.1/classes/Student?where=" + condition;
            JSONObject response = DatabaseHelper.LCSearch(url);
            JSONArray DatabaseResults = response.getJSONArray("results");
            if(DatabaseResults.length() != 1) {
            return  false;
            } else
            {
                JSONObject checkLog = DatabaseResults.getJSONObject(0);
                ApplicationHelper.CurrentUser.Advertising = 0;
                ApplicationHelper.CurrentUser.BaiduFaceID = checkLog.getString("BaiduFaceID");
                ApplicationHelper.CurrentUser.LCObjectID = checkLog.getString("objectId");
                ApplicationHelper.CurrentUser.BLE = checkLog.getInt("BLE");
                ApplicationHelper.CurrentUser.ID = checkLog.getString("ID");
                ApplicationHelper.CurrentUser.Name = checkLog.getString("Name");

                Group.GetGroup();
                Schedule.GetSchedules();
                return true;
            }
        } catch (Exception ignore)
        {
            return false;
        }
    }

    public byte[] getStudentBeaconMinor() {
        byte[] bytes = {0x00, 0x00};
        bytes[0] = (byte)(BLE >> 8 & 0xFF);
        bytes[1] = (byte)(BLE & 0xFF);
        return bytes;
    }
}
