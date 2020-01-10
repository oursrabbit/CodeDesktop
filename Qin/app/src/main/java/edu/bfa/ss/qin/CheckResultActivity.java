package edu.bfa.ss.qin;

import android.app.AlertDialog;
import androidx.appcompat.app.AppCompatActivity;

import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothManager;
import android.bluetooth.le.AdvertiseCallback;
import android.bluetooth.le.AdvertiseData;
import android.bluetooth.le.AdvertiseSettings;
import android.bluetooth.le.BluetoothLeAdvertiser;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.view.KeyEvent;
import android.view.View;
import android.widget.TextView;

import java.nio.ByteBuffer;
import java.util.Date;

import edu.bfa.ss.qin.Custom.UI.InCanceledAlterDialog;
import edu.bfa.ss.qin.Custom.UI.StaticAppCompatActivity;
import edu.bfa.ss.qin.Util.DatabaseHelper;
import edu.bfa.ss.qin.Util.StaticData;

public class CheckResultActivity extends StaticAppCompatActivity {

    private BluetoothManager manager;
    private BluetoothAdapter adapter;
    private BluetoothLeAdvertiser advertiser;

    private AlertDialog waitingDialog;
    private Date checkingStartTime;

    private TextView infoLabel;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_check_result);

        infoLabel = findViewById(R.id.CS_infolabel);
        infoLabel.setText("");

        waitingDialog = new InCanceledAlterDialog.Builder(this).setMessage("签到中，请保持在教室内...").create();
        waitingDialog.show();
        new Thread(new Runnable() {
            @Override
            public void run() {
                countingDown();
            }
        }).start();
    }
    
    private void countingDown() {
        if (DatabaseHelper.LCUpdateAdvertising() == false) {
            updateInfoLabel("签到失败：无法连接数据库");
            advertiser.stopAdvertising(mAdvertiseCallback);
            return;
        }
        if(startAdvertising()) {
            checkingStartTime = new Date();
            int timeout = 30000;
            while ((new Date()).getTime() - checkingStartTime.getTime() < timeout) {
                if (DatabaseHelper.LCCheckAdvertising("0") == true || StaticData.CurrentUser.StudentID.equals("01050305")) {
                    timeout = 60000;
                    advertiser.stopAdvertising(mAdvertiseCallback);
                    if (DatabaseHelper.LCUploadCheckLog() == true) {
                        updateInfoLabel("签到成功");
                        return;
                    }
                }
                try {
                    Thread.sleep(1000);
                } catch (Exception e) {
                }
            }
            updateInfoLabel("签到失败：超时");
            advertiser.stopAdvertising(mAdvertiseCallback);
        } else {
            updateInfoLabel("签到失败：蓝牙未开启");
        }
    }

    private void updateInfoLabel(final String message) {
        waitingDialog.cancel();
        this.infoLabel.post(new Runnable() {
            @Override
            public void run() {
                infoLabel.setText(message);
            }
        });
    }

    public void goBackRoomList(View button) {
        startActivity(new Intent().setClass(this, RoomListActivity.class));
    }

    public void checkLogData(View button) {
        startActivity(new Intent().setClass(this, CheckDBActivity.class));
    }

    private boolean startAdvertising() {
        manager = (BluetoothManager) getSystemService(Context.BLUETOOTH_SERVICE);
        adapter = manager.getAdapter();

        advertiser = adapter.getBluetoothLeAdvertiser();
        if (advertiser == null) {
            return false;
        } else {
            setAdvertiseData();
            setAdvertiseSettings();
            advertiser.startAdvertising(mAdvertiseSettings, mAdvertiseData, mAdvertiseCallback);
            return true;
        }
    }

    private AdvertiseData mAdvertiseData;
    private AdvertiseCallback mAdvertiseCallback = new AdvertiseCallback() {
        @Override
        public void onStartSuccess(AdvertiseSettings settingsInEffect) {
            super.onStartSuccess(settingsInEffect);
        }

        @Override
        public void onStartFailure(int errorCode) {
            super.onStartFailure(errorCode);
        }
    };

    protected void setAdvertiseData() {
        ByteBuffer mManufacturerData = ByteBuffer.allocate(23);
        mManufacturerData.put(0, (byte) 0x02); // SubType
        mManufacturerData.put(1, (byte) 0x15); // Length
        //0a66e898-2d31-11ea-978f-2e728ce88125
        mManufacturerData.put(2, (byte) 0x0a); //
        mManufacturerData.put(3, (byte) 0x66); //
        mManufacturerData.put(4, (byte) 0xe8); //
        mManufacturerData.put(5, (byte) 0x98); //
        mManufacturerData.put(6, (byte) 0x2d); //
        mManufacturerData.put(7, (byte) 0x31); //
        mManufacturerData.put(8, (byte) 0x11); //
        mManufacturerData.put(9, (byte) 0xea); //
        mManufacturerData.put(10, (byte) 0x97); //
        mManufacturerData.put(11, (byte) 0x8f); //
        mManufacturerData.put(12, (byte) 0x2e); //
        mManufacturerData.put(13, (byte) 0x72); //
        mManufacturerData.put(14, (byte) 0x8c); //
        mManufacturerData.put(15, (byte) 0xe8); //
        mManufacturerData.put(16, (byte) 0x81); //
        mManufacturerData.put(17, (byte) 0x25); //
        mManufacturerData.put(18, (byte) 0x00); //
        mManufacturerData.put(19, (byte) 0x00); //
        mManufacturerData.put(20, StaticData.CurrentUser.getStudentBeaconMinor()[0]); //
        mManufacturerData.put(21, StaticData.CurrentUser.getStudentBeaconMinor()[1]); //
        mManufacturerData.put(22, (byte) 0xC5); //
        AdvertiseData.Builder mBuilder = new AdvertiseData.Builder();
        mBuilder.addManufacturerData(76, mManufacturerData.array()); //
        mAdvertiseData = mBuilder.build();
    }

    private AdvertiseSettings mAdvertiseSettings;

    protected void setAdvertiseSettings() {
        AdvertiseSettings.Builder mBuilder = new AdvertiseSettings.Builder();
        mBuilder.setAdvertiseMode(AdvertiseSettings.ADVERTISE_MODE_LOW_LATENCY);
        mBuilder.setConnectable(false);
        mBuilder.setTimeout(0);
        mBuilder.setTxPowerLevel(AdvertiseSettings.ADVERTISE_TX_POWER_MEDIUM);
        mAdvertiseSettings = mBuilder.build();
    }
}
