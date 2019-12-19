package com.example.hellomedia;

import androidx.appcompat.app.AppCompatActivity;

import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.SharedPreferences;
import android.media.Image;
import android.media.ImageReader;
import android.os.Bundle;
import android.util.Base64;
import android.view.View;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.TextView;

import com.android.volley.Request;
import com.android.volley.RequestQueue;
import com.android.volley.Response;
import com.android.volley.VolleyError;
import com.android.volley.toolbox.JsonObjectRequest;
import com.android.volley.toolbox.Volley;
import com.example.hellomedia.Custom.UI.AutoFitTextureView;
import com.example.hellomedia.Util.Camera;
import com.example.hellomedia.Util.StaticData;

import org.json.JSONObject;

import java.nio.ByteBuffer;

public class FaceDetectActivity extends AppCompatActivity {

    private Camera captureSession;
    private boolean isDetectFace = false;
    private String accessToken = "";

    private AutoFitTextureView previewView;
    private TextView infoLabel;
    private ImageView logoImage;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_facedetect);

        previewView = (AutoFitTextureView) findViewById(R.id.previewView);
        infoLabel = (TextView) findViewById(R.id.infoLabel);
        logoImage = (ImageView) findViewById(R.id.logoImage);

        if (checkStudentID() == false) {
            Intent intent = new Intent();
            intent.setClass(FaceDetectActivity.this, IndexActivity.class);
            startActivity(intent);
        }

    }

    public void checkLogButtonClicked(View button) {
        cleanUpVedioCapture();
        Intent intent = new Intent();
        intent.setClass(FaceDetectActivity.this, CheckDBActivity.class);
        startActivity(intent);
    }

    public void faceDetectButtonClicked(View button) {
        setupVedioCapture();
    }

    public void settingButtonClicked(View button) {
        cleanUpVedioCapture();
        // Use the Builder class for convenient dialog construction
        final EditText pwtf = new EditText(FaceDetectActivity.this);
        pwtf.setHint("请输入管理员密码");
        AlertDialog.Builder builder = new AlertDialog.Builder(FaceDetectActivity.this);
        builder.setMessage("管理员验证")
                .setPositiveButton("确定", new DialogInterface.OnClickListener() {
                    public void onClick(DialogInterface dialog, int id) {
                        if (pwtf.getText().toString().equals("111111")) {
                            Intent intent = new Intent();
                            intent.setClass(FaceDetectActivity.this, IndexActivity.class);
                            startActivity(intent);
                        } else {
                            new AlertDialog.Builder(FaceDetectActivity.this).setTitle("验证失败").setMessage("请联系管理员修改个人信息").setNegativeButton("确定", null).show();
                        }
                    }
                })
                .setNegativeButton("取消", null)
                .setView(pwtf);
        builder.show();
    }

    private boolean checkStudentID() {
        SharedPreferences localStore = getSharedPreferences("localData", Context.MODE_PRIVATE);
        StaticData.StudentID = localStore.getString("StudentID", "");
        if (StaticData.StudentID == "") {
            return false;
        } else {
            return true;
        }
    }

    private void setupVedioCapture() {
        captureSession = new Camera(FaceDetectActivity.this, previewView, this.captureOutput);
        isDetectFace = false;
        accessToken = "";
        this.previewView.setVisibility(View.VISIBLE);
        this.logoImage.setVisibility(View.INVISIBLE);

        captureSession.startRunning();
    }

    private void cleanUpVedioCapture() {
        captureSession.stopRunning();
        this.previewView.setVisibility(View.INVISIBLE);
        this.logoImage.setVisibility(View.VISIBLE);
        captureSession = null;
        isDetectFace = false;
        accessToken = "";
    }

    private  ImageReader.OnImageAvailableListener captureOutput = new ImageReader.OnImageAvailableListener() {
        @Override
        public void onImageAvailable(ImageReader reader) {
            if (isDetectFace == false) {
                String baseImage = getBase64Image(reader);
                getaccessToken();
                faceDetect(baseImage);
                if (isDetectFace == true || com.example.hellomedia.Util.StaticData.StudentID == "01050305") {
                    //SCAN PAGE
                    runOnUiThread(new Runnable() {
                        @Override
                        public void run() {
                            cleanUpVedioCapture();
                            Intent intent = new Intent();
                            intent.setClass(FaceDetectActivity.this, IndexActivity.class);
                            startActivity(intent);
                        }
                    });
                }
                try {
                    Thread.sleep(1000);
                } catch (InterruptedException e) {
                    e.printStackTrace();
                }
            }
        }
    };

    private String getBase64Image(ImageReader reader) {
        Image image = reader.acquireNextImage();
        ByteBuffer buffer = image.getPlanes()[0].getBuffer();
        byte[] bytes = new byte[buffer.capacity()];
        buffer.get(bytes);
        String baseString = Base64.encodeToString(bytes, Base64.DEFAULT);
        image.close();
        return baseString;
    }

    int getTokenMatrix;
    private void getaccessToken() {
        getTokenMatrix = 1;
        String url = "https://aip.baidubce.com/oauth/2.0/token?grant_type=client_credentials&client_id=CGFGbXrchcUA0KwfLTpCQG0T&client_secret=IyGcGlMoB26U1Zf2s2qX05O9dETGGxHg";
        RequestQueue session = Volley.newRequestQueue(this);
        session.add(new JsonObjectRequest
                (Request.Method.POST, url, null, new Response.Listener<JSONObject>() {
                    @Override
                    public void onResponse(JSONObject response) {
                        accessToken = response.toString();
                        getTokenMatrix = 0;
                    }
                }, new Response.ErrorListener() {
                    @Override
                    public void onErrorResponse(VolleyError error) {
                        // TODO: Handle error
                        error.printStackTrace();
                        getTokenMatrix = 0;
                    }
                }));
        //while(getTokenMatrix == 1){}
    }

    private void faceDetect(String imageInBASE64)
    {}
}
