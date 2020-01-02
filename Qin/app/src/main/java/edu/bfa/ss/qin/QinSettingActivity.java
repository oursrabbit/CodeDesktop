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
import edu.bfa.ss.qin.Custom.UI.InCanceledAlterDialog;
import edu.bfa.ss.qin.Util.DatabaseHelper;
import edu.bfa.ss.qin.Util.StaticData;
import io.realm.Realm;

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
        checkStudentID();
        idtextView = findViewById(R.id.QS_idtextview);
        idtextView.setText(StaticData.StudentID);
        saveButton = findViewById(R.id.QS_savebutton);
        saveButton.setEnabled(false);
        waitingDialog = new InCanceledAlterDialog.Builder(this).setMessage("正在更新数据...").create();

        if (StaticData.InitState == true) {
            waitingDialog.show();
            new Thread(new Runnable() {
                @Override
                public void run() {
                    Realm realm = Realm.getDefaultInstance();
                    if (StaticData.InitQinApplication(QinSettingActivity.this, realm) == true) {
                        waitingDialog.cancel();
                        if (checkStudentID() == true)
                            QinSettingActivity.this.startActivity(new Intent().setClass(QinSettingActivity.this, RoomListActivity.class));
                    } else {
                        waitingDialog.cancel();
                    }
                    realm.close();
                    realm = null;
                }
            }).start();
        } else {
            saveButton.setEnabled(true);
        }
    }

    public void updateStudentID(View button) {
        StaticData.StudentID = idtextView.getText().toString();
        SharedPreferences localStore = getSharedPreferences("localData", Context.MODE_PRIVATE);
        SharedPreferences.Editor editor = localStore.edit();
        editor.putString("StudentID", StaticData.StudentID);
        editor.commit();
        Intent intent = new Intent();
        intent.setClass(QinSettingActivity.this, RoomListActivity.class);
        startActivity(intent);
    }

    private boolean checkStudentID() {
        SharedPreferences localStore = getSharedPreferences("localData", Context.MODE_PRIVATE);
        StaticData.StudentID = localStore.getString("StudentID", "");
        return StaticData.StudentID != "";
    }
}
