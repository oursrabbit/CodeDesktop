package com.example.hellomedia;

import androidx.appcompat.app.AppCompatActivity;

import android.app.AlertDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.os.Bundle;
import android.os.CountDownTimer;
import android.view.KeyEvent;
import android.widget.EditText;
import android.widget.TextView;

public class ScannerActivity extends AppCompatActivity {
    private CountDownTimer timer;

    private TextView infoLabel;
    private int countTime = 30;

    @Override
    public boolean onKeyDown(int keyCode, KeyEvent event) {
        if (keyCode == KeyEvent.KEYCODE_BACK)
            return false;
        return super.onKeyDown(keyCode, event);
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_scanner);

        infoLabel = (TextView)findViewById(R.id.S_counddownlabel);

        timer = new CountDownTimer(30000,1000) {
            @Override
            public void onTick(long millisUntilFinished) {
                infoLabel.post(new Runnable() {
                    @Override
                    public void run() {
                        countTime = countTime - 1;
                        infoLabel.setText(countTime + "");
                    }
                });
            }

            @Override
            public void onFinish() {
                AlertDialog.Builder builder = new AlertDialog.Builder(ScannerActivity.this);
                builder.setMessage("签到失败")
                        .setPositiveButton("重新签到", new DialogInterface.OnClickListener() {
                            public void onClick(DialogInterface dialog, int id) {
                                Intent intent = new Intent();
                                intent.setClass(ScannerActivity.this, FaceDetectActivity.class);
                                startActivity(intent);
                            }
                        });
                builder.show();
            }
        };
        timer.start();
    }
}
