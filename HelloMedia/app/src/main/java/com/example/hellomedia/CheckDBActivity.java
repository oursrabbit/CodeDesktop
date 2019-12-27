package com.example.hellomedia;

import android.app.AlertDialog;
import android.content.Context;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.ListView;
import android.widget.TextView;

import androidx.appcompat.app.AppCompatActivity;

import com.example.hellomedia.Util.StaticData;

import org.json.JSONArray;
import org.json.JSONObject;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.net.URL;
import java.net.URLEncoder;
import java.util.ArrayList;
import java.util.List;

import javax.net.ssl.HttpsURLConnection;

public class CheckDBActivity extends AppCompatActivity {

    private String LeancloudAppid = "YHwFdAE1qj1OcWfJ5xoayLKr-gzGzoHsz";
    private String LeancloudAppKey = "UbnM6uOP2mxah3nFMzurEDQL";
    private String LeancloudAPIBaseURL = "https://yhwfdae1.lc-cn-n1-shared.com";
    private String LeancloudIDHeader = "X-LC-Id";
    private String LeancloudKeyHeader = "X-LC-Key";
    private String HttpContentTypeHeader = "Content-Type";
    private String HttpContentType = "application/json";

    private AlertDialog waitingDialog;
    private ListView logsTable;
    private TextView idLabel;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_check_db);
        logsTable = findViewById(R.id.CDB_logsTable);
        idLabel = findViewById(R.id.CDB_idLabel);
        idLabel.setText(StaticData.StudentID);
        AlertDialog.Builder builder = new AlertDialog.Builder(CheckDBActivity.this);
        waitingDialog = builder.setMessage("正在加载数据，请稍后...").show();
        new Thread(new Runnable() {
            @Override
            public void run() {
                LoadingDatabase();
            }
        }).start();
    }

    private void LoadingDatabase() {
        try {
            String condition = URLEncoder.encode("{\"StudentID\":\"" + StaticData.StudentID + "\"}", "UTF-8");
            String url = LeancloudAPIBaseURL + "/1.1/classes/CheckRecording?where=" + condition;
            HttpsURLConnection connection = (HttpsURLConnection) (new URL(url)).openConnection();
            connection.setRequestMethod("GET");
            connection.setRequestProperty(LeancloudIDHeader, LeancloudAppid);
            connection.setRequestProperty(LeancloudKeyHeader, LeancloudAppKey);
            connection.setRequestProperty(HttpContentTypeHeader, HttpContentType);
            if (connection.getResponseCode() == 200) {
                JSONObject response = new JSONObject(new BufferedReader(new InputStreamReader(connection.getInputStream())).readLine());
                JSONArray DatabaseResults = response.getJSONArray("results");
                final List<CheckDBItem> checkLogs = new ArrayList<CheckDBItem>();
                for (int i = 0; i < DatabaseResults.length(); i++) {
                    JSONObject checkLog = DatabaseResults.getJSONObject(i);
                    CheckDBItem newLog = new CheckDBItem();
                    newLog.StudentID = checkLog.getString("StudentID");
                    newLog.RoomID = checkLog.getString("RoomID");
                    newLog.CheckDate = checkLog.getJSONObject("CheckDate").getString("iso");
                    checkLogs.add(newLog);
                }
                logsTable.post(new Runnable() {
                    @Override
                    public void run() {
                        waitingDialog.cancel();
                        CheckDBItemAdapter adapter = new CheckDBItemAdapter(CheckDBActivity.this, R.layout.checklogitem, checkLogs);
                        logsTable.setAdapter(adapter);
                    }
                });
            } else {
                return;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}

class CheckDBItem {
    public String StudentID;
    public String CheckDate;
    public String RoomID;
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
        ((TextView) convertView.findViewById(R.id.CDB_ITEM_checkdate)).setText(getItem(position).CheckDate);
        return convertView;
    }
}
