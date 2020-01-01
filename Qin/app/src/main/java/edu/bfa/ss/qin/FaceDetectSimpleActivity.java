package edu.bfa.ss.qin;

import androidx.appcompat.app.AppCompatActivity;

import android.app.AlertDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.os.Bundle;
import android.view.KeyEvent;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.TextView;

import edu.bfa.ss.qin.Custom.UI.AutoFitTextureView;
import edu.bfa.ss.qin.Util.Camera;

public class FaceDetectSimpleActivity extends AppCompatActivity {

    private Camera captureSession;

    private AutoFitTextureView previewView;
    private TextView infoLabel;

    @Override
    public boolean onKeyDown(int keyCode, KeyEvent event) {
        if (keyCode == KeyEvent.KEYCODE_BACK)
            return false;
        return super.onKeyDown(keyCode, event);
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_face_detect_simple);

        previewView = findViewById(R.id.FDS_previewView);
        infoLabel = findViewById(R.id.FDS_infoLabel);
        infoLabel.setText("");
        captureSession = new Camera(FaceDetectSimpleActivity.this, previewView, infoLabel, new Camera.CameraFaceDetectListener() {
            @Override
            public void onFaceDetected() {
                startActivity(new Intent().setClass(FaceDetectSimpleActivity.this, CheckResultActivity.class));
            }
        });
        captureSession.startRunning();
    }
}
