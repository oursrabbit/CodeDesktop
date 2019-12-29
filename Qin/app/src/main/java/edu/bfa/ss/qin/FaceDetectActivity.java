package edu.bfa.ss.qin;

import androidx.appcompat.app.AppCompatActivity;

import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.SharedPreferences;
import android.net.Uri;
import android.os.Bundle;
import android.view.KeyEvent;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.TextView;

import edu.bfa.ss.qin.Custom.UI.AutoFitTextureView;
import edu.bfa.ss.qin.Util.Camera;
import edu.bfa.ss.qin.Util.StaticData;

public class FaceDetectActivity extends AppCompatActivity {

    private Camera captureSession;

    private AutoFitTextureView previewView;
    private TextView infoLabel;
    private ImageView logoImage;
    private ImageView logoBgImage;

    @Override
    public boolean onKeyDown(int keyCode, KeyEvent event) {
        if (keyCode == KeyEvent.KEYCODE_BACK)
            return false;
        return super.onKeyDown(keyCode, event);
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_face_detect);

        previewView = findViewById(R.id.FD_previewView);
        infoLabel = findViewById(R.id.FD_infoLabel);
        logoImage = findViewById(R.id.FD_logoImage);
        logoBgImage = findViewById(R.id.FD_logobg);
        
        infoLabel.setText("");

        if (StaticData.checkPermission(this) == false) {
            AlertDialog.Builder builder = new AlertDialog.Builder(FaceDetectActivity.this);
            builder.setMessage("未开启硬件权限，请前往应用设置开启")
                    .setPositiveButton("前往", new DialogInterface.OnClickListener() {
                        public void onClick(DialogInterface dialog, int id) {
                            Intent intent = new Intent(android.provider.Settings.ACTION_APPLICATION_DETAILS_SETTINGS);
                            intent.setData(Uri.parse("package:" + "edu.bfa.ss.qin"));
                            startActivity(intent);
                        }
                    })
                    .setNegativeButton("取消", null);
            builder.show();
            return;
        }

        if (checkStudentID() == false) {
            Intent intent = new Intent();
            intent.setClass(FaceDetectActivity.this, QinSettingActivity.class);
            startActivity(intent);
        }
    }

    public void checkLogButtonClicked(View button) {
        if (checkStudentID() == false) {
            Intent intent = new Intent();
            intent.setClass(FaceDetectActivity.this, CheckDBActivity.class);
            startActivity(intent);
            return;
        }
        cleanUpVedioCapture();
        Intent intent = new Intent();
        intent.setClass(FaceDetectActivity.this, CheckDBActivity.class);
        startActivity(intent);
    }

    public void faceDetectButtonClicked(View button) {
        if (checkStudentID() == false) {
            Intent intent = new Intent();
            intent.setClass(FaceDetectActivity.this, QinSettingActivity.class);
            startActivity(intent);
            return;
        }
        setupVideoCapture();
    }

    public void settingButtonClicked(View button) {
        cleanUpVedioCapture();
        // Use the Builder class for convenient dialog construction
        final View convertView = LayoutInflater.from(this).inflate(R.layout.alterdialog_checkpassword, null);
        AlertDialog.Builder builder = new AlertDialog.Builder(FaceDetectActivity.this);
        builder.setMessage("管理员验证")
                .setPositiveButton("确定", new DialogInterface.OnClickListener() {
                    public void onClick(DialogInterface dialog, int id) {
                        EditText pwtf = convertView.findViewById(R.id.FD_authorpassword);
                        if (pwtf.getText().toString().equals("111111")) {
                            Intent intent = new Intent();
                            intent.setClass(FaceDetectActivity.this, QinSettingActivity.class);
                            startActivity(intent);
                        } else {
                            new AlertDialog.Builder(FaceDetectActivity.this).setTitle("验证失败").setMessage("请联系管理员修改个人信息").setNegativeButton("确定", null).show();
                        }
                    }
                })
                .setNegativeButton("取消", null)
                .setView(convertView);
        builder.show();
    }

    private boolean checkStudentID() {
        SharedPreferences localStore = getSharedPreferences("localData", Context.MODE_PRIVATE);
        StaticData.StudentID = localStore.getString("StudentID", "");
        return StaticData.StudentID != "";
    }

    private void setupVideoCapture() {
        infoLabel.setText("");
        captureSession = new Camera(FaceDetectActivity.this, previewView, infoLabel);
        this.previewView.setVisibility(View.VISIBLE);
        this.logoBgImage.setVisibility(View.INVISIBLE);
        this.logoImage.setVisibility(View.INVISIBLE);

        captureSession.startRunning();
    }

    private void cleanUpVedioCapture() {
        infoLabel.setText("");
        if (captureSession != null)
            captureSession.stopRunning();
        this.previewView.setVisibility(View.INVISIBLE);
        this.logoBgImage.setVisibility(View.VISIBLE);
        this.logoImage.setVisibility(View.VISIBLE);
        captureSession = null;
    }
}
