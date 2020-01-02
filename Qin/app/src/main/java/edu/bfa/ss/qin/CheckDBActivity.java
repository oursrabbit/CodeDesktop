package edu.bfa.ss.qin;

import androidx.appcompat.app.AppCompatActivity;

import android.content.Context;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.ListView;
import android.widget.TextView;

import org.json.JSONArray;
import org.json.JSONObject;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.net.URL;
import java.net.URLEncoder;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

import javax.net.ssl.HttpsURLConnection;

import edu.bfa.ss.qin.Util.DatabaseHelper;
import edu.bfa.ss.qin.Util.StaticData;

public class CheckDBActivity extends AppCompatActivity {

    private ListView logsTable;
    private TextView idLabel;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_check_db);
        logsTable = findViewById(R.id.CDB_logsTable);
        idLabel = findViewById(R.id.CDB_idLabel);
        idLabel.setText("");
        new Thread(new Runnable() {
            @Override
            public void run() {
                LoadingDatabase();
            }
        }).start();
    }

    private void updateInfoLabel(final String message) {
        this.idLabel.post(new Runnable() {
            @Override
            public void run() {
                idLabel.setText(message);
            }
        });
    }

    private void LoadingDatabase() {
        try {
            updateInfoLabel("正在加载数据...");
            String condition = URLEncoder.encode("{\"StudentID\":\"" + StaticData.StudentID + "\"}", "UTF-8");
            String url = DatabaseHelper.LeancloudAPIBaseURL + "/1.1/classes/CheckRecording?where=" + condition;
            JSONObject response = DatabaseHelper.LCSearch(url);
            JSONArray DatabaseResults = response.getJSONArray("results");
            final List<CheckDBItem> checkLogs = new ArrayList<CheckDBItem>();
            for (int i = 0; i < DatabaseResults.length(); i++) {
                JSONObject checkLog = DatabaseResults.getJSONObject(i);
                CheckDBItem newLog = new CheckDBItem();
                newLog.StudentID = checkLog.getString("StudentID");
                newLog.RoomID = checkLog.getString("RoomID");
                newLog.CheckDateString = checkLog.getString("createdAt");
                checkLogs.add(newLog);
            }
            logsTable.post(new Runnable() {
                @Override
                public void run() {
                    idLabel.setText(StaticData.StudentID);
                    CheckDBItemAdapter adapter = new CheckDBItemAdapter(CheckDBActivity.this, R.layout.table_check_db_item, checkLogs);
                    logsTable.setAdapter(adapter);
                }
            });
        } catch (Exception e) {
            updateInfoLabel("加载失败");
            e.printStackTrace();
        }
    }
}

class CheckDBItem {
    public String StudentID;
    public String CheckDateString;
    public String RoomID;

    public Date getCheckDate() {
        return  StaticData.fromISO8601UTC(CheckDateString);
    }
}

class CheckDBItemAdapter extends ArrayAdapter<CheckDBItem> {
    private Context host;
    private int resourceId;

    public CheckDBItemAdapter(Context context, int resource, List<CheckDBItem> objects) {
        super(context, resource, objects);
        resourceId = resource;
        host = context;
    }

    @Override
    public View getView(int position, View convertView, ViewGroup container) {
        if (convertView == null) {
            convertView = LayoutInflater.from(host).inflate(resourceId, container, false);
        }
        ((TextView) convertView.findViewById(R.id.CDB_ITEM_roomid)).setText(getItem(position).RoomID);
        ((TextView) convertView.findViewById(R.id.CDB_ITEM_checkdate)).setText(StaticData.getDateString("yyyy年MM月dd日", getItem(position).getCheckDate()));
        ((TextView) convertView.findViewById(R.id.CDB_ITEM_checktime)).setText(StaticData.getDateString("HH时mm分", getItem(position).getCheckDate()));
        return convertView;
    }
}
