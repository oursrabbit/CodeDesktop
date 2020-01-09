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
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.Toast;

import org.json.JSONArray;
import org.json.JSONObject;

import java.net.URLEncoder;
import java.util.ArrayList;
import java.util.List;

import edu.bfa.ss.qin.Custom.UI.InCanceledAlterDialog;
import edu.bfa.ss.qin.Util.DatabaseHelper;
import edu.bfa.ss.qin.Util.StaticData;
import edu.bfa.ss.qin.Util.Student;
import io.realm.Realm;
import io.realm.RealmConfiguration;

public class QinSettingActivity extends AppCompatActivity {

    private EditText idtextView;
    private Button saveButton;
    private AlertDialog waitingDialog;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_qin_setting);

        idtextView = findViewById(R.id.QS_idtextview);
        idtextView.setText(StaticData.CurrentUser.StudentID);
        saveButton = findViewById(R.id.QS_savebutton);
        waitingDialog = new InCanceledAlterDialog.Builder(this).setMessage("").create();
    }

    public void updateWaitingDialog(final String message) {
        saveButton.post(new Runnable() {
            @Override
            public void run() {
                waitingDialog.setMessage(message);
            }
        });
    }

    public void updateStudentID(View button) {
        StaticData.CurrentUser.StudentID = idtextView.getText().toString();
        SharedPreferences localStore = getSharedPreferences("localData", Context.MODE_PRIVATE);
        SharedPreferences.Editor editor = localStore.edit();
        editor.putString("StudentID", StaticData.CurrentUser.StudentID);
        editor.commit();
        waitingDialog.show();
        new Thread(new Runnable() {
            @Override
            public void run() {
                updateStudentObjectID();
            }
        }).start();
    }

    private void updateStudentObjectID() {
        try {
            updateWaitingDialog("正在获取用户信息...");
            String condition = URLEncoder.encode("{\"StudentID\":\"" + StaticData.CurrentUser.StudentID + "\"}", "UTF-8");
            String url = DatabaseHelper.LeancloudAPIBaseURL + "/1.1/classes/Students?where=" + condition;
            JSONObject response = DatabaseHelper.LCSearch(url);
            JSONArray DatabaseResults = response.getJSONArray("results");
            updateWaitingDialog("正在更新用户信息...");
            if(DatabaseResults.length() != 1) {
                saveButton.post(new Runnable() {
                    @Override
                    public void run() {
                        Toast.makeText(QinSettingActivity.this, "未找到用户", Toast.LENGTH_LONG).show();
                    }
                });
            } else {
                JSONObject checkLog = DatabaseResults.getJSONObject(0);
                StaticData.CurrentUser.Advertising = "0";
                StaticData.CurrentUser.BaiduFaceID = checkLog.getString("BaiduFaceID");
                StaticData.CurrentUser.ObjectID = checkLog.getString("objectId");
                StaticData.CurrentUser.StudentBeaconID = checkLog.getInt("StudentBeaconMinor");
                startActivity(new Intent().setClass(this, RoomListActivity.class));
            }
        } catch (Exception e) {
            saveButton.post(new Runnable() {
                @Override
                public void run() {
                    Toast.makeText(QinSettingActivity.this, "网络错误", Toast.LENGTH_LONG).show();
                }
            });
            e.printStackTrace();
        } finally {
            waitingDialog.cancel();
        }
    }
}
