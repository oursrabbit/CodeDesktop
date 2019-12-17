package com.example.hellomedia;

import androidx.appcompat.app.AppCompatActivity;

import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.SharedPreferences;
import android.hardware.camera2.CameraAccessException;
import android.hardware.camera2.CameraCharacteristics;
import android.hardware.camera2.CameraManager;
import android.os.Bundle;
import android.text.InputType;
import android.view.View;
import android.widget.EditText;

public class FaceDetectActivity extends AppCompatActivity {

    private CameraManager cameraManager;

    private boolean isDetectFace = false;
    private String accessToken = "";
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_facedetect);

        if (checkStudentID() == false)
        {
            Intent intent = new Intent();
            intent.setClass(FaceDetectActivity.this, IndexActivity.class);
            startActivity(intent);
        }
    }

    public void checkLogButtonClicked(View button){
        cleanUpVedioCapture();
        Intent intent = new Intent();
        intent.setClass(FaceDetectActivity.this, CheckDBActivity.class);
        startActivity(intent);
    }

    public void faceDetectButtonClicked(View button){
        setupVedioCapture();
    }

    public void settingButtonClicked(View button){
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

    private void setupVedioCapture(){
        cameraManager = (CameraManager)getSystemService(CAMERA_SERVICE);
        try {
            for (String cameraID: cameraManager.getCameraIdList()) {
                CameraCharacteristics chars = cameraManager.getCameraCharacteristics(cameraID);
                System.out.println(chars);
            }
        } catch (CameraAccessException e) {
            e.printStackTrace();
        }
    }

    private void cleanUpVedioCapture(){

    }
}
