package edu.bfa.ss.qin;

import androidx.appcompat.app.AppCompatActivity;

import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.view.View;
import android.widget.EditText;

import edu.bfa.ss.qin.Util.StaticData;

public class QinSettingActivity extends AppCompatActivity {

    private EditText idtextView;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_qin_setting);

        idtextView = findViewById(R.id.QS_idtextview);
        idtextView.setText(StaticData.StudentID);
    }

    public void updateStudentID(View button) {
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
