package com.example.hellohttp;

import androidx.appcompat.app.AppCompatActivity;

import android.os.Bundle;
import android.widget.TextView;

import com.android.volley.AuthFailureError;
import com.android.volley.Request;
import com.android.volley.RequestQueue;
import com.android.volley.Response;
import com.android.volley.VolleyError;
import com.android.volley.toolbox.JsonObjectRequest;
import com.android.volley.toolbox.JsonRequest;
import com.android.volley.toolbox.StringRequest;
import com.android.volley.toolbox.Volley;

import org.json.JSONObject;

import java.io.UnsupportedEncodingException;
import java.net.URI;
import java.net.URLEncoder;
import java.util.HashMap;
import java.util.Map;

public class MainActivity extends AppCompatActivity {

    private String LeancloudAppid = "YHwFdAE1qj1OcWfJ5xoayLKr-gzGzoHsz";
    private String LeancloudAppKey = "UbnM6uOP2mxah3nFMzurEDQL";
    private String LeancloudAPIBaseURL = "https://yhwfdae1.lc-cn-n1-shared.com";
    private String LeancloudIDHeader = "X-LC-Id";
    private String LeancloudKeyHeader = "X-LC-Key";
    private String HttpContentTypeHeader = "Content-Type";
    private String HttpContentType = "application/json";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        String condition = "";
        try {
            condition = URLEncoder.encode("{\"RoomID\":\"606\"}", "UTF-8");
        } catch (UnsupportedEncodingException e) {
            e.printStackTrace();
        }
        final TextView textView = (TextView) findViewById(R.id.text);
        RequestQueue queue = Volley.newRequestQueue(this);
        String url = LeancloudAPIBaseURL + "/1.1/classes/CheckRecording?where=" + condition;

        JsonObjectRequest jsonObjectRequest = new JsonObjectRequest
                (Request.Method.GET, url, null, new Response.Listener<JSONObject>() {

                    @Override
                    public void onResponse(JSONObject response) {
                        textView.setText("Response: " + response.toString());
                    }
                }, new Response.ErrorListener() {

                    @Override
                    public void onErrorResponse(VolleyError error) {
                        // TODO: Handle error
                        textView.setText("Error");
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
