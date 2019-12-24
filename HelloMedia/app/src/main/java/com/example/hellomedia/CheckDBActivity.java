package com.example.hellomedia;

import androidx.appcompat.app.AppCompatActivity;

import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.BaseAdapter;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ListView;
import android.widget.TextView;
import android.widget.Toast;

import com.android.volley.AuthFailureError;
import com.android.volley.Request;
import com.android.volley.RequestQueue;
import com.android.volley.Response;
import com.android.volley.VolleyError;
import com.android.volley.toolbox.JsonObjectRequest;
import com.android.volley.toolbox.Volley;
import com.example.hellomedia.Util.StaticData;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.UnsupportedEncodingException;
import java.net.URLEncoder;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class CheckDBActivity extends AppCompatActivity {

    private String LeancloudAppid = "YHwFdAE1qj1OcWfJ5xoayLKr-gzGzoHsz";
    private String LeancloudAppKey = "UbnM6uOP2mxah3nFMzurEDQL";
    private String LeancloudAPIBaseURL = "https://yhwfdae1.lc-cn-n1-shared.com";
    private String LeancloudIDHeader = "X-LC-Id";
    private String LeancloudKeyHeader = "X-LC-Key";
    private String HttpContentTypeHeader = "Content-Type";
    private String HttpContentType = "application/json";

    private RequestQueue queue;

    private AlertDialog waitingDialog;
    private ListView logsTable;
    private  TextView idLabel;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_check_db);
        logsTable = (ListView)findViewById(R.id.CDB_logsTable);
        idLabel = (TextView)findViewById(R.id.CDB_idLabel);
        queue = Volley.newRequestQueue(this);
        idLabel.setText(StaticData.StudentID);
        AlertDialog.Builder builder = new AlertDialog.Builder(CheckDBActivity.this);
        waitingDialog =  builder.setMessage("正在加载数据，请稍后...").show();
        LoadingDatabase();
    }

    private void LoadingDatabase(){
        String condition = "";
        try {
            condition = URLEncoder.encode("{\"StudentID\":\"" + StaticData.StudentID + "\"}", "UTF-8");
        } catch (UnsupportedEncodingException e) {
            e.printStackTrace();
        }
        String url = LeancloudAPIBaseURL + "/1.1/classes/CheckRecording?where=" + condition;

        JsonObjectRequest jsonObjectRequest = new JsonObjectRequest
                (Request.Method.GET, url, null, new Response.Listener<JSONObject>() {

                    @Override
                    public void onResponse(JSONObject response) {
                        try {
                            JSONArray DatabaseResults = response.getJSONArray("results");
                            final List<CheckDBItem> checkLogs = new ArrayList<CheckDBItem>();
                            for(int i =0; i<DatabaseResults.length();i++) {
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
                        } catch (JSONException e) {
                            e.printStackTrace();
                        }
                    }
                }, new Response.ErrorListener() {
                    @Override
                    public void onErrorResponse(VolleyError error) {
                        // TODO: Handle error
                        error.printStackTrace();
                    }
                }){
            @Override
            public Map<String, String> getHeaders() throws AuthFailureError {
                Map<String,String> header = new HashMap<>();
                header.put(LeancloudIDHeader, LeancloudAppid);
                header.put(LeancloudKeyHeader, LeancloudAppKey);
                header.put(HttpContentTypeHeader, HttpContentType);
                return header;
            }
        };
        // Add the request to the RequestQueue.
        queue.add(jsonObjectRequest);
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
        ((TextView)convertView.findViewById(R.id.CDB_ITEM_roomid)).setText(getItem(position).RoomID);
        ((TextView)convertView.findViewById(R.id.CDB_ITEM_checkdate)).setText(getItem(position).CheckDate);
        return convertView;
    }
}
