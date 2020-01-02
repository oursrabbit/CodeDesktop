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
import android.os.Bundle;
import android.view.KeyEvent;
import android.widget.TextView;

import org.json.JSONException;
import org.json.JSONObject;

import java.io.IOException;
import java.nio.ByteBuffer;
import java.util.Date;

import edu.bfa.ss.qin.Custom.UI.InCanceledAlterDialog;
import edu.bfa.ss.qin.Util.DatabaseHelper;
import edu.bfa.ss.qin.Util.StaticData;

public class CheckResultActivity extends AppCompatActivity {

    private BluetoothManager manager;
    private BluetoothAdapter adapter;
    private BluetoothLeAdvertiser advertiser;

    private AlertDialog waitingDialog;
    private Date checkingStartTime;

    private TextView infoLabel;
    @Override
    public boolean onKeyDown(int keyCode, KeyEvent event) {
        if (keyCode == KeyEvent.KEYCODE_BACK)
            return false;
        return super.onKeyDown(keyCode, event);
    }

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
                if (updateDatabaseAdvertising() == false) {
                    updateInfoLabel("签到失败：无法连接数据库");
                    return;
                }
                startAdvertising();
                checkingStartTime = new Date();
                int timeout = 30000;
                while ((new Date()).getTime() - checkingStartTime.getTime() < timeout) {
                    if(checkingAdvertisingFlag() == true) {
                        if(uploadCheck() == true) {
                            updateInfoLabel("签到成功");
                            return;
                        } else {
                            timeout = 60000;
                        }
                    }
                    try { Thread.sleep(1000);} catch (Exception e) {}
                }
                updateInfoLabel("签到失败");
            }
        }).start();
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

    private boolean updateDatabaseAdvertising() {
        return DatabaseHelper.LCUpdateAdvertising();
    }

    private boolean checkingAdvertisingFlag(){
        return DatabaseHelper.LCCheckAdvertising("0");
    }

    private boolean uploadCheck() {
        return DatabaseHelper.LCUploadCheckLog();
    }

    private void startAdvertising() {
        manager = (BluetoothManager) getSystemService(Context.BLUETOOTH_SERVICE);
        adapter = manager.getAdapter();

        advertiser = adapter.getBluetoothLeAdvertiser();
        setAdvertiseData();
        setAdvertiseSettings();
        advertiser.startAdvertising(mAdvertiseSettings, mAdvertiseData, mAdvertiseCallback);
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
        mManufacturerData.put(0, (byte)0x02); // SubType
        mManufacturerData.put(1, (byte)0x15); // Length
        //0a66e898-2d31-11ea-978f-2e728ce88125
        mManufacturerData.put(2, (byte)0x0a); //
        mManufacturerData.put(3, (byte)0x66); //
        mManufacturerData.put(4, (byte)0xe8); //
        mManufacturerData.put(5, (byte)0x98); //
        mManufacturerData.put(6, (byte)0x2d); //
        mManufacturerData.put(7, (byte)0x31); //
        mManufacturerData.put(8, (byte)0x11); //
        mManufacturerData.put(9, (byte)0xea); //
        mManufacturerData.put(10, (byte)0x97); //
        mManufacturerData.put(11, (byte)0x8f); //
        mManufacturerData.put(12, (byte)0x2e); //
        mManufacturerData.put(13, (byte)0x72); //
        mManufacturerData.put(14, (byte)0x8c); //
        mManufacturerData.put(15, (byte)0xe8); //
        mManufacturerData.put(16, (byte)0x81); //
        mManufacturerData.put(17, (byte)0x25); //
        mManufacturerData.put(18, StaticData.CurrentUser.getStrudingIDBytes()[0]); //
        mManufacturerData.put(19, StaticData.CurrentUser.getStrudingIDBytes()[1]); //
        mManufacturerData.put(20, StaticData.CurrentUser.getStrudingIDBytes()[2]); //
        mManufacturerData.put(21, StaticData.CurrentUser.getStrudingIDBytes()[3]); //
        mManufacturerData.put(22, (byte)0xC5); //
        AdvertiseData.Builder mBuilder = new AdvertiseData.Builder();
        mBuilder.addManufacturerData(0x4C00, mManufacturerData.array()); //
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
