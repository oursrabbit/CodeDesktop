package com.example.hellomedia;

import androidx.appcompat.app.AppCompatActivity;

import android.app.AlertDialog;
import android.bluetooth.BluetoothClass;
import android.bluetooth.BluetoothDevice;
import android.bluetooth.BluetoothManager;
import android.bluetooth.le.BluetoothLeScanner;
import android.bluetooth.le.ScanCallback;
import android.bluetooth.le.ScanFilter;
import android.bluetooth.le.ScanRecord;
import android.bluetooth.le.ScanResult;
import android.bluetooth.le.ScanSettings;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.os.Bundle;
import android.os.CountDownTimer;
import android.os.ParcelUuid;
import android.util.Log;
import android.util.SparseArray;
import android.view.KeyEvent;
import android.widget.EditText;
import android.widget.TextView;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.Optional;
import java.util.OptionalInt;
import java.util.UUID;

public class ScannerActivity extends AppCompatActivity {
    private CountDownTimer timer;
    private BluetoothLeScanner leScanner;

    private List<String> roomList;
    private int checkMinor = -1;

    private TextView infoLabel;
    private int countTime = 30;

    @Override
    public boolean onKeyDown(int keyCode, KeyEvent event) {
        if (keyCode == KeyEvent.KEYCODE_BACK)
            return false;
        return super.onKeyDown(keyCode, event);
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_scanner);

        infoLabel = findViewById(R.id.S_counddownlabel);

        countDown();
        setupNFCScanner();
    }

    private void countDown () {
        timer = new CountDownTimer(32000,1000) {
            @Override
            public void onTick(long millisUntilFinished) {
                infoLabel.post(new Runnable() {
                    @Override
                    public void run() {
                        countTime = countTime - 1;
                        if (countTime <= 0)
                            infoLabel.setText("0");
                        else
                            infoLabel.setText(countTime + "");
                    }
                });
            }

            @Override
            public void onFinish() {
                infoLabel.post(new Runnable() {
                    @Override
                    public void run() {
                        infoLabel.setText("0");
                        AlertDialog.Builder builder = new AlertDialog.Builder(ScannerActivity.this);
                        builder.setMessage("签到失败")
                                .setPositiveButton("重新签到", new DialogInterface.OnClickListener() {
                                    public void onClick(DialogInterface dialog, int id) {
                                        Intent intent = new Intent();
                                        intent.setClass(ScannerActivity.this, FaceDetectActivity.class);
                                        startActivity(intent);
                                    }
                                });
                        builder.show();
                    }
                });
            }
        };
        timer.start();
    }

    private void setupNFCScanner() {
        leScanner = ((BluetoothManager) getSystemService(Context.BLUETOOTH_SERVICE)).getAdapter().getBluetoothLeScanner();

        ScanSettings.Builder builder = new ScanSettings.Builder();
        builder.setReportDelay(500);
        ScanSettings scanSettings =  builder.build();

        List<ScanFilter> filters = new ArrayList<ScanFilter>();
        ScanFilter.Builder filterBuilder = new ScanFilter.Builder();
        filterBuilder.setServiceUuid(ParcelUuid.fromString("FDA50693-A4E2-4FB1-AFCF-C6EB07647825".toLowerCase()));
        filters.add(filterBuilder.build());

        leScanner.startScan(null, scanSettings, myScanCallback);
    }

    private ScanCallback myScanCallback = new ScanCallback() {
        @Override
        public void onBatchScanResults(List<ScanResult> results) {
            for(ScanResult res : results){
                byte[] beaconRawData = res.getScanRecord().getBytes();
                iBeacon beacon = iBeacon.Creater(beaconRawData);
                if (beacon !=null && beacon.UUID.equals("FDA50693A4E24FB1AFCFC6EB07647825")) {
                    Log.d("UUIDOUT", beacon.UUID);
                    Log.d("UUIDOUT", beacon.Major + "");
                    Log.d("UUIDOUT", beacon.Minor + "");
                    Log.d("UUIDOUT", beacon.SignalPower + "");
                }
            }
        }
    };

    private void refreshBLETable() {

    }
}

class iBeacon {
    public String UUID;
    public int Major;
    public int Minor;
    public int SignalPower;

    public static iBeacon Creater(byte[] rawData){
        if (rawData[0] == 0x02 && rawData[1] == 0x01 && rawData[2] == 0x06 && rawData[3] == 0x1A && rawData[4] == (byte)0xFF && rawData[5] == 0x4C && rawData[6] == 0x00  && rawData[7] == 0x02 && rawData[8] == 0x15) {
            iBeacon beacon = new iBeacon();
            beacon.UUID = "";
            for (int i = 9; i < 25; i++){
                beacon.UUID += String.format("%02X", rawData[i]);
            }
            beacon.Major = 0;
            for(int i = 25;i<27; i++){
                beacon.Major += rawData[i];
                beacon.Major = beacon.Major << (8 * (26 - i));
            }
            beacon.Minor = 0;
            for(int i = 27;i<29; i++){
                beacon.Minor += rawData[i];
                beacon.Minor = beacon.Minor << (8 * (28 - i));
            }
            beacon.SignalPower = (int)rawData[29];
            return beacon;
        }
        return null;
    }
}
