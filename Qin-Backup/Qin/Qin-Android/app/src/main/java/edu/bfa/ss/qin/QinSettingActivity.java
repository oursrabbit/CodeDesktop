package edu.bfa.ss.qin;

import androidx.appcompat.app.AppCompatActivity;
import android.app.AlertDialog;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.Toast;

import org.json.JSONObject;

import edu.bfa.ss.qin.Custom.UI.InCanceledAlterDialog;
import edu.bfa.ss.qin.Util.ApplicationHelper;
import edu.bfa.ss.qin.Util.Student;

public class QinSettingActivity extends AppCompatActivity {

    private EditText idtextView;
    private Button saveButton;
    private AlertDialog waitingDialog;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_qin_setting);

        idtextView = findViewById(R.id.QS_idtextview);
        idtextView.setText(ApplicationHelper.CurrentUser.ID);
        saveButton = findViewById(R.id.QS_savebutton);
        waitingDialog = new InCanceledAlterDialog.Builder(this).setMessage("").create();

        if (ApplicationHelper.CurrentUser.ID != "") {
            updateSchoolID(saveButton);
        }
    }

    public void updateWaitingDialog(final String message) {
        saveButton.post(new Runnable() {
            @Override
            public void run() {
                waitingDialog.setMessage(message);
            }
        });
    }

    public void updateSchoolID(View button) {
        ApplicationHelper.CurrentUser.ID = idtextView.getText().toString();
        SharedPreferences localStore = getSharedPreferences("localData", Context.MODE_PRIVATE);
        SharedPreferences.Editor editor = localStore.edit();
        editor.putString("ID", ApplicationHelper.CurrentUser.ID);
        editor.commit();
        waitingDialog.show();
        new Thread(new Runnable() {
            @Override
            public void run() {
                getCurrentUserInfomation();
            }
        }).start();
    }

    private void getCurrentUserInfomation() {
        updateWaitingDialog("正在更新用户信息...");
        if (Student.SetupCurrentStudent()) {
            startActivity(new Intent().setClass(this, BuildingListActivity.class));
        } else {
            saveButton.post(new Runnable() {
                @Override
                public void run() {
                    Toast.makeText(QinSettingActivity.this, "登陆失败，未找到用户", Toast.LENGTH_LONG).show();
                }
            });
        }
        waitingDialog.cancel();
    }
}
