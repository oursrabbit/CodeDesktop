package com.example.hellomedia;

import androidx.appcompat.app.AppCompatActivity;

import android.os.Bundle;
import android.os.CountDownTimer;
import android.widget.TextView;

public class ScannerActivity extends AppCompatActivity {
    private CountDownTimer timer;

    private TextView infoLabel;
    private int countTime = 30;
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
                        infoLabel.setText(countTime - 1);
                    }
                });
            }

            @Override
            public void onFinish() {

            }
        };
    }
}
