package edu.bfa.ss.qin;

import androidx.appcompat.app.AppCompatActivity;
import android.app.AlertDialog;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
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
    public boolean onKeyDown(int keyCode, KeyEvent event) {
        if (keyCode == KeyEvent.KEYCODE_BACK)
            return false;
        return super.onKeyDown(keyCode, event);
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_qin_setting);

        Realm.init(this);
        RealmConfiguration config = new RealmConfiguration.Builder()
                .deleteRealmIfMigrationNeeded()
                .build();
        Realm.setDefaultConfiguration(config);
        checkStudentID();
        idtextView = findViewById(R.id.QS_idtextview);
        idtextView.setText(StaticData.CurrentUser.StudentID);
        saveButton = findViewById(R.id.QS_savebutton);
        waitingDialog = new InCanceledAlterDialog.Builder(this).setMessage("正在更新教室数据...").create();

        new Thread(new Runnable() {
            @Override
            public void run() {
                StaticData.getBaiduAIAccessToken();
            }
        }).start();

        if (StaticData.InitState == true) {
            waitingDialog.show();
            new Thread(new Runnable() {
                @Override
                public void run() {
                    Boolean initRes = StaticData.InitQinApplication(QinSettingActivity.this);
                    if (initRes == true) {
                        if (checkStudentID() == true)
                            saveButton.post(new Runnable() {
                                @Override
                                public void run() {
                                    updateStudentID(null);
                                }
                            });
                    }
                }
            }).start();
        }
    }

    public void updateStudentID(View button) {
        StaticData.CurrentUser.StudentID = idtextView.getText().toString();
        SharedPreferences localStore = getSharedPreferences("localData", Context.MODE_PRIVATE);
        SharedPreferences.Editor editor = localStore.edit();
        editor.putString("StudentID", StaticData.CurrentUser.StudentID);
        editor.commit();
        waitingDialog.setMessage("正在更新用户数据...");
        new Thread(new Runnable() {
            @Override
            public void run() {
                updateStudentObjectID();
            }
        }).start();
    }

    private void updateStudentObjectID() {
        try {
            String condition = URLEncoder.encode("{\"StudentID\":\"" + StaticData.CurrentUser.StudentID + "\"}", "UTF-8");
            String url = DatabaseHelper.LeancloudAPIBaseURL + "/1.1/classes/Students?where=" + condition;
            JSONObject response = DatabaseHelper.LCSearch(url);
            JSONArray DatabaseResults = response.getJSONArray("results");
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
                startActivity(new Intent().setClass(this, RoomListActivity.class));
            }
        } catch (Exception e) {
            saveButton.post(new Runnable() {
                @Override
                public void run() {
                    Toast.makeText(QinSettingActivity.this, "未找到用户", Toast.LENGTH_LONG).show();
                }
            });
            e.printStackTrace();
        } finally {
            waitingDialog.cancel();
        }
    }

    private boolean checkStudentID() {
        SharedPreferences localStore = getSharedPreferences("localData", Context.MODE_PRIVATE);
        StaticData.CurrentUser.StudentID = localStore.getString("StudentID", "");
        return StaticData.CurrentUser.StudentID != "";
    }
}
