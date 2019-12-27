package com.example.hellomedia;

import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.view.View;
import android.widget.EditText;

import androidx.appcompat.app.AppCompatActivity;

import com.example.hellomedia.Util.StaticData;

public class QinSettingActivity extends AppCompatActivity {

    private EditText idtextView;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_index);

        idtextView = findViewById(R.id.idtextView);

        idtextView.setText(StaticData.StudentID);
    }

    private void checkLogButtonClicked(View button) {
        Intent intent = new Intent();
        intent.setClass(QinSettingActivity.this, CheckDBActivity.class);
        startActivity(intent);
    }

    public void UpdataStudentID(View button) {
        StaticData.StudentID = idtextView.getText().toString();
        SharedPreferences localStore = getSharedPreferences("localData", Context.MODE_PRIVATE);
        SharedPreferences.Editor editor = localStore.edit();
        editor.putString("StudentID", StaticData.StudentID);
        editor.commit();
        Intent intent = new Intent();
        intent.setClass(QinSettingActivity.this, FaceDetectActivity.class);
        startActivity(intent);
    }
}
