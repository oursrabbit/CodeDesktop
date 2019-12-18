package com.example.hellomedia;

import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatActivity;

import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.SharedPreferences;
import android.graphics.SurfaceTexture;
import android.hardware.camera2.CameraAccessException;
import android.hardware.camera2.CameraCharacteristics;
import android.hardware.camera2.CameraDevice;
import android.hardware.camera2.CameraManager;
import android.os.Bundle;
import android.os.Handler;
import android.os.HandlerThread;
import android.text.InputType;
import android.view.Surface;
import android.view.SurfaceView;
import android.view.TextureView;
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
                if (chars.get(CameraCharacteristics.LENS_FACING) == CameraCharacteristics.LENS_FACING_FRONT){
                    cameraManager.openCamera(cameraID, new CameraStateCallback(), null);
                }
            }
        } catch (CameraAccessException e) {
            e.printStackTrace();
        }
    }

    private class SurfaceCallback implements TextureView.SurfaceTextureListener {
        @Override
        public boolean onSurfaceTextureDestroyed(SurfaceTexture surface) {
            return false;
        }

        @Override
        public void onSurfaceTextureAvailable(SurfaceTexture surface, int width, int height) {

        }

        @Override
        public void onSurfaceTextureSizeChanged(SurfaceTexture surface, int width, int height) {

        }

        @Override
        public void onSurfaceTextureUpdated(SurfaceTexture surface) {

        }
    }

    TextureView preView;

    private class CameraStateCallback extends CameraDevice.StateCallback {
        @Override
        public void onOpened(@NonNull CameraDevice camera) {
            preView = (TextureView)findViewById(R.id.textureView);
            SurfaceTexture texture = preView.getSurfaceTexture();
            texture.setDefaultBufferSize(128,128);
            Surface surface = new Surface(texture);
        }

        @Override
        public void onError(@NonNull CameraDevice camera, int error) {

        }

        @Override
        public void onDisconnected(@NonNull CameraDevice camera) {

        }
    }
    /*private class CameraStateCallback : CameraDevice.StateCallback() {
        override fun onOpened(camera: CameraDevice) {
            cameraDevice = camera
            runOnUiThread { Toast.makeText(this@MainActivity, "相机已开启", Toast.LENGTH_SHORT).show() }
        }

        override fun onError(camera: CameraDevice, error: Int) {
            camera.close()
            cameraDevice = null
        }
    }*/
    private void cleanUpVedioCapture(){

    }
}
