package edu.bfa.ss.qin;

import androidx.appcompat.app.AppCompatActivity;

import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.SharedPreferences;
import android.net.Uri;
import android.os.Bundle;
import android.widget.TextView;

import edu.bfa.ss.qin.Custom.UI.InCanceledAlterDialog;
import edu.bfa.ss.qin.Custom.UI.QinApplication;
import edu.bfa.ss.qin.Custom.UI.StaticAppCompatActivity;
import edu.bfa.ss.qin.Util.StaticData;
import io.realm.Realm;
import io.realm.RealmConfiguration;

public class InitializationActivity extends StaticAppCompatActivity {

    private AlertDialog waitingDialog;
    private TextView infoLabel;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_initialization);
        waitingDialog = new InCanceledAlterDialog.Builder(this).setMessage("").show();
        infoLabel = findViewById(R.id.INIT_infolabel);
        initApplication();
    }

    private StaticData.StaticDataUpdateInfoListener updateInfoListener = new StaticData.StaticDataUpdateInfoListener() {
        @Override
        public void updateInfomation(String message) {
            updateWaitingDialog(message);
        }
    };

    public void updateWaitingDialog(final String message) {
        infoLabel.post(new Runnable() {
            @Override
            public void run() {
                waitingDialog.setMessage(message);
            }
        });
    }

    private void initApplication() {
        //Init DB
        Realm.init(QinApplication.getContext());
        RealmConfiguration config = new RealmConfiguration.Builder()
                .deleteRealmIfMigrationNeeded()
                .build();
        Realm.setDefaultConfiguration(config);
        //Init LocalDB
        SharedPreferences localStore = getSharedPreferences("localData", Context.MODE_PRIVATE);
        StaticData.CurrentUser.StudentID = localStore.getString("StudentID", "");
        new Thread(new Runnable() {
            @Override
            public void run() {
                //Check Permission
                if (StaticData.checkPermission(updateInfoListener) == false) {
                    openSystemSetting();
                    return;
                }
                //Check Version
                int versionErrorCode = StaticData.checkVersion(updateInfoListener);
                if (versionErrorCode == 1) {
                    openDownLoadLink();
                    return;
                } else if(versionErrorCode == 2) {
                    showNetError();
                    return;
                }
                //Check DBVersion
                if(StaticData.checkLocalDatabaseVersion(updateInfoListener) == 2) {
                    showNetError();
                    return;
                }
                startQin();
            }
        }).start();
    }

    private void showNetError() {
        infoLabel.post(new Runnable() {
            @Override
            public void run() {
                infoLabel.setText("请重启程序");
                waitingDialog.cancel();
                new InCanceledAlterDialog.Builder(InitializationActivity.this).setMessage("网络错误")
                        .setPositiveButton("退出", new DialogInterface.OnClickListener() {
                            public void onClick(DialogInterface dialog, int id) {
                                InitializationActivity.this.finish();
                            }
                        }).show();
            }
        });
    }

    private void openSystemSetting() {
        infoLabel.post(new Runnable() {
            @Override
            public void run() {
                infoLabel.setText("请重启程序");
                waitingDialog.cancel();
                new InCanceledAlterDialog.Builder(InitializationActivity.this).setMessage("未开启硬件权限，请前往应用设置开启，并重启程序")
                        .setPositiveButton("前往", new DialogInterface.OnClickListener() {
                            public void onClick(DialogInterface dialog, int id) {
                                InitializationActivity.this.startActivity(new Intent(android.provider.Settings.ACTION_APPLICATION_DETAILS_SETTINGS).setData(Uri.parse("package:" + "edu.bfa.ss.qin")));
                                finish();
                            }
                        }).show();
            }
        });
    }

    private void openDownLoadLink() {
        infoLabel.post(new Runnable() {
            @Override
            public void run() {
                infoLabel.setText("请重启程序");
                waitingDialog.cancel();
                new InCanceledAlterDialog.Builder(InitializationActivity.this).setMessage("请更新\n\n本机：" + StaticData.localVersion.VersionString + "\n\n最新版：" + StaticData.serverVersion.VersionString)
                        .setPositiveButton("前往", new DialogInterface.OnClickListener() {
                            public void onClick(DialogInterface dialog, int id) {
                                InitializationActivity.this.startActivity(new Intent(Intent.ACTION_VIEW, Uri.parse("https://www.baidu.com")).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK));
                            }
                        }).show();
            }
        });
    }

    private void startQin() {
        infoLabel.post(new Runnable() {
            @Override
            public void run() {
                InitializationActivity.this.startActivity(new Intent().setClass(InitializationActivity.this, QinSettingActivity.class));
                finish();
            }
        });
    }
}
