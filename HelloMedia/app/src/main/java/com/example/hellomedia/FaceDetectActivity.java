package com.example.hellomedia;

import androidx.appcompat.app.AppCompatActivity;

import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.view.KeyEvent;
import android.view.View;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.TextView;

import com.example.hellomedia.Custom.UI.AutoFitTextureView;
import com.example.hellomedia.Util.Camera;
import com.example.hellomedia.Util.StaticData;

public class FaceDetectActivity extends AppCompatActivity {
    private Camera captureSession;

    private AutoFitTextureView previewView;
    private TextView infoLabel;
    private ImageView logoImage;

    @Override
    public boolean onKeyDown(int keyCode, KeyEvent event) {
        if (keyCode == KeyEvent.KEYCODE_BACK)
            return false;
        return super.onKeyDown(keyCode, event);
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_facedetect);

        previewView = findViewById(R.id.FD_previewView);
        infoLabel = findViewById(R.id.FD_infoLabel);
        logoImage = findViewById(R.id.FD_logoImage);

        captureSession = new Camera(this, previewView, infoLabel);

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
        return StaticData.StudentID != "";
    }

    private void setupVedioCapture() {
        captureSession = new Camera(FaceDetectActivity.this, previewView, infoLabel);
        this.previewView.setVisibility(View.VISIBLE);
        this.logoImage.setVisibility(View.INVISIBLE);

        captureSession.startRunning();
    }

    private void cleanUpVedioCapture() {
        if (captureSession != null)
            captureSession.stopRunning();
        this.previewView.setVisibility(View.INVISIBLE);
        this.logoImage.setVisibility(View.VISIBLE);
        captureSession = null;
    }
}
