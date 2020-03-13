package edu.bfa.ss.qin;

import androidx.appcompat.app.AppCompatActivity;

import android.content.Intent;
import android.os.Bundle;

public class LaunchActivity extends AppCompatActivity {

    int countdown = 1;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_launch);

        new Thread(new Runnable() {
            @Override
            public void run() {
                countingDown();
            }
        }).start();
    }

    private void countingDown() {

        while (countdown > 0) {
            countdown = countdown - 1;
            try {
                Thread.sleep(1000);
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
        }

        LaunchActivity.this.startActivity(new Intent().setClass(LaunchActivity.this, InitializationActivity.class));
        finish();
    }
}
