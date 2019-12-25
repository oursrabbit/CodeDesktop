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
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.EditText;
import android.widget.ListView;
import android.widget.TextView;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Date;
import java.util.HashMap;
import java.util.Hashtable;
import java.util.List;
import java.util.Optional;
import java.util.OptionalInt;
import java.util.UUID;

public class ScannerActivity extends AppCompatActivity {
    private CountDownTimer timer;
    private BluetoothLeScanner leScanner;

    private HashMap<String , iBeacon> iBeacons;
    private boolean iniRoomList = true;
    private int checkMinor = -1;

    private ListView iBeaconListView;
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
        iBeaconListView = findViewById(R.id.S_ibeaconlist);

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

                        List<String> removeKeys = new ArrayList<String>();
                        for(iBeacon bb : iBeacons.values()) {
                            if ((((new Date()).getTime()) - (bb.LastAdvertisingTime.getTime())) > 10 * 1000) {
                                removeKeys.add(bb.Minor + "");
                            }
                        }
                        for(String rk : removeKeys) {
                            iBeacons.remove(rk);
                        }

                        if(iniRoomList) {
                            iBeaconListView.post(new Runnable() {
                                @Override
                                public void run() {
                                    iBeaconAdapter adapter = new iBeaconAdapter(ScannerActivity.this, R.layout.ibeaconitem, new ArrayList<iBeacon>(iBeacons.values()));
                                    iBeaconListView.setAdapter(adapter);
                                }
                            });
                            iniRoomList = false;
                        }

                        if (checkMinor != -1){

                        }
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
        iBeacons = new HashMap<String, iBeacon>();
        leScanner = ((BluetoothManager) getSystemService(Context.BLUETOOTH_SERVICE)).getAdapter().getBluetoothLeScanner();

        ScanSettings.Builder builder = new ScanSettings.Builder();
        builder.setCallbackType(ScanSettings.CALLBACK_TYPE_ALL_MATCHES);
        builder.setMatchMode(ScanSettings.MATCH_MODE_AGGRESSIVE);
        builder.setNumOfMatches(ScanSettings.MATCH_NUM_MAX_ADVERTISEMENT);
        builder.setScanMode(ScanSettings.SCAN_MODE_LOW_LATENCY);
        ScanSettings scanSettings =  builder.build();

        List<ScanFilter> filters = new ArrayList<ScanFilter>();
        ScanFilter.Builder filterBuilder = new ScanFilter.Builder();
        filterBuilder.setManufacturerData(76, new byte[]{
                0x02, 0x15,
                (byte)0xFD, (byte)0xA5, 0x06, (byte)0x93,
                (byte)0xA4, (byte)0xE2,
                0x4F, (byte)0xB1,
                (byte)0xAF, (byte)0xCF, (byte)0xC6, (byte)0xEB, 0x07, 0x64, 0x78, 0x25,
                0x00, 0x00,
                0x00, 0x00,
                0x00
        }, new byte[]{
                1,1,
                1,1,1,1,
                1,1,
                1,1,
                1,1,1,1,1,1,1,1,
                0,0,
                0,0,
                0
        });
        filters.add(filterBuilder.build());

        leScanner.startScan(filters, scanSettings, myScanCallback);
    }

    private ScanCallback myScanCallback = new ScanCallback() {
        @Override
        public void onScanResult(int callbackType, ScanResult result) {
            byte[] beaconRawData = result.getScanRecord().getBytes();
            iBeacon beacon = iBeacon.Creater(beaconRawData);
            if (iBeacons.containsKey(beacon.Minor + "")){
                iBeacons.get(beacon.Minor + "").LastAdvertisingTime = new Date();
            } else {
                iBeacons.put(beacon.Minor + "", beacon);
            }
            super.onScanResult(callbackType, result);
        }
    };

    public void refreshBLETable(View button) {
        iniRoomList = true;
    }
}

class iBeacon {
    public String UUID;
    public int Major;
    public int Minor;
    public int SignalPower;

    public Date LastAdvertisingTime;

    public static iBeacon Creater(byte[] rawData) {
        iBeacon beacon = new iBeacon();
        beacon.UUID = "";
        for (int i = 9; i < 25; i++) {
            beacon.UUID += String.format("%02X", rawData[i]);
        }
        beacon.Major = 0;
        for (int i = 25; i < 27; i++) {
            beacon.Major += rawData[i];
            beacon.Major = beacon.Major << (8 * (26 - i));
        }
        beacon.Minor = 0;
        for (int i = 27; i < 29; i++) {
            beacon.Minor += rawData[i];
            beacon.Minor = beacon.Minor << (8 * (28 - i));
        }
        beacon.SignalPower = (int) rawData[29];
        beacon.LastAdvertisingTime = new Date();
        return beacon;
    }
}

class iBeaconAdapter extends ArrayAdapter<iBeacon> {
    private Context host;

    private int resourceId;

    public iBeaconAdapter(Context context, int resource, List<iBeacon> objects) {
        super(context, resource, objects);
        resourceId = resource;
        host = context;
    }

    @Override
    public View getView(int position, View convertView, ViewGroup container) {
        if (convertView == null) {
            convertView = LayoutInflater.from(host).inflate(resourceId, container, false);
        }
        ((TextView)convertView.findViewById(R.id.S_ITEM_minor)).setText(getItem(position).Minor + "");
        return convertView;
    }
}
