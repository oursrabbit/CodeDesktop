package edu.bfa.ss.qin.Util;

import org.json.JSONArray;
import org.json.JSONObject;

import java.net.URLEncoder;
import java.util.ArrayList;
import java.util.Date;

public class Schedule {
    public String ID = "";
    public Date StartDate;
    public int ContinueWeek = 0;
    public String StartSectionID = "";
    public int ContinueSection = 0;
    public String RoomID = "";
    public String CourseID = "";
    public String[] ProfessorID;

    public static void GetSchedules() {
        try {
            String regex = "{\"$regex\":\"(^" + ApplicationHelper.CurrentUser.ID + ";)|(;" + ApplicationHelper.CurrentUser.ID + ";)|(;" + ApplicationHelper.CurrentUser.ID + "$)|(^" + ApplicationHelper.CurrentUser.ID + "$)\"}";
            String condition = URLEncoder.encode("{\"StudentID\":" + regex + "}", "UTF-8");
            String url = DatabaseHelper.LeancloudAPIBaseURL + "/1.1/classes/Schedule?where=" + condition;
            JSONObject response = DatabaseHelper.LCSearch(url);
            JSONArray DatabaseResults = response.getJSONArray("results");
            for (int i = 0; i < DatabaseResults.length(); i++) {
                JSONObject checkLog = DatabaseResults.getJSONObject(i);
                Schedule newSchedule = new Schedule();
                newSchedule.ID = checkLog.getString("ID");
                newSchedule.StartDate = ApplicationHelper.getStringDate("yyyy-MM-dd", checkLog.getString("StartDate"));
                newSchedule.ContinueWeek = checkLog.getInt("ContinueWeek");
                newSchedule.StartSectionID = checkLog.getString("StartSectionID");
                newSchedule.ContinueSection = checkLog.getInt("ContinueSection");
                newSchedule.CourseID = checkLog.getString("CourseID");
                newSchedule.RoomID = checkLog.getString("RoomID");
                newSchedule.ProfessorID = checkLog.getString("ProfessorID").split(";");
                ApplicationHelper.CurrentUser.Schedules.add(newSchedule);
            }
        } catch (Exception ignore) {
            return;
        }
    }
}
