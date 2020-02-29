package edu.bfa.ss.qin.Custom.UI;

import android.view.KeyEvent;

import androidx.appcompat.app.AppCompatActivity;

public class StaticAppCompatActivity extends AppCompatActivity {
    @Override
    public boolean onKeyDown(int keyCode, KeyEvent event) {
        if (keyCode == KeyEvent.KEYCODE_BACK)
            return false;
        return super.onKeyDown(keyCode, event);
    }
}
