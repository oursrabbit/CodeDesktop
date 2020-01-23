package edu.bfa.ss.qindevice;

import androidx.appcompat.app.AppCompatActivity;
import androidx.core.content.ContextCompat;

import android.Manifest;
import android.app.Application;
import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothManager;
import android.bluetooth.le.BluetoothLeScanner;
import android.bluetooth.le.ScanCallback;
import android.bluetooth.le.ScanFilter;
import android.bluetooth.le.ScanResult;
import android.bluetooth.le.ScanSettings;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.location.LocationManager;
import android.net.Uri;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.widget.TextView;

import org.json.JSONObject;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

public class MainActivity extends AppCompatActivity {

    private BluetoothManager manager;
    private BluetoothAdapter adapter;
    private BluetoothLeScanner scanner;
    private TextView infoLabel;

    private List<String> updatingStudentID;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        infoLabel = findViewById(R.id.MA_infoLabel);

        /*requestPermissions(new String[] {
                Manifest.permission.ACCESS_COARSE_LOCATION,
                Manifest.permission.ACCESS_FINE_LOCATION,
                Manifest.permission.BLUETOOTH,
                Manifest.permission.BLUETOOTH_ADMIN,
                Manifest.permission.INTERNET,
                Manifest.permission.ACCESS_NETWORK_STATE}, 0);*/

        if(checkPermission() == false) {
            /*requestPermissions(new String[] {
                    Manifest.permission.ACCESS_COARSE_LOCATION,
                    Manifest.permission.ACCESS_FINE_LOCATION,
                    Manifest.permission.BLUETOOTH,
                    Manifest.permission.BLUETOOTH_ADMIN,
                    Manifest.permission.INTERNET,
                    Manifest.permission.ACCESS_NETWORK_STATE}, 0);*/
            new InCanceledAlterDialog.Builder(this).setMessage("未开启硬件权限，或GPS定位功能，请开启后重启程序")
                    .setPositiveButton("前往系统设置", new DialogInterface.OnClickListener() {
                        public void onClick(DialogInterface dialog, int id) {
                            startActivity(new Intent(android.provider.Settings.ACTION_APPLICATION_DETAILS_SETTINGS).setData(Uri.parse("package:" + "edu.bfa.ss.qindevice")));
                        }
                    }).show();
        } else {
            resetLeScanning(null);
        }
    }

    private void updateInfoLabel(final String message) {
        infoLabel.post(new Runnable() {
            @Override
            public void run() {
                infoLabel.setText(message);
            }
        });
    }

    public void startLeScanning() {
        updateInfoLabel("");
        updatingStudentID = new ArrayList<String>();
        manager = (BluetoothManager)getSystemService(Context.BLUETOOTH_SERVICE);
        adapter = manager.getAdapter();
        scanner = adapter.getBluetoothLeScanner();
        setScannerFilters();
        setScannerSetting();
        //scanner.startScan(mScannerCallback);
        scanner.startScan(mScannerFilters, mScannerSettings, mScannerCallback);
    }

    private List<ScanFilter> mScannerFilters;

    private void setScannerFilters() {
        byte[] iBeaconData = {
                (byte) 0x02, (byte) 0x15,
                //0a66e898-2d31-11ea-978f-2e728ce88125
                (byte) 0x0a, (byte) 0x66, (byte) 0xe8, (byte) 0x98,
                (byte) 0x2d, (byte) 0x31,
                (byte) 0x11, (byte) 0xea,
                (byte) 0x97, (byte) 0x8f,
                (byte) 0x2e, (byte) 0x72, (byte) 0x8c, (byte) 0xe8, (byte) 0x81, (byte) 0x25,
                (byte) 0x00, (byte) 0x00, (byte) 0x00, (byte) 0x00, (byte) 0x00
        };
        byte[] iBeaconMask = {
                1, 1,
                1, 1, 1, 1,
                1, 1,
                1, 1,
                1, 1,
                1, 1, 1, 1, 1, 1,
                0, 0, 0, 0, 0
        };
        mScannerFilters = new ArrayList<ScanFilter>();
        //76 for Apple
        ScanFilter filter = new ScanFilter.Builder().setManufacturerData(76, iBeaconData, iBeaconMask).build();
        mScannerFilters.add(filter);
    }

    private ScanSettings mScannerSettings;

    private void setScannerSetting() {
        mScannerSettings = new ScanSettings.Builder().setScanMode(ScanSettings.SCAN_MODE_LOW_LATENCY).build();
    }

    private ScanCallback mScannerCallback = new ScanCallback() {
        @Override
        public void onScanResult(int callbackType, ScanResult result) {
            super.onScanResult(callbackType, result);
            byte[] iBeaconRawData = result.getScanRecord().getManufacturerSpecificData(76);
            final iBeacon Student = new iBeacon(iBeaconRawData);
            if (!updatingStudentID.contains(Student.StudentBeaconID + "")) {
                updatingStudentID.add(Student.StudentBeaconID + "");
                new Thread(new Runnable() {
                    @Override
                    public void run() {
                        updateStudentsDB(Student);
                    }
                }).start();
            }
        }

        @Override
        public void onScanFailed(int errorCode) {
            super.onScanFailed(errorCode);
        }
    };

    private void updateStudentsDB(iBeacon student) {
        String objectID = DatabaseHelper.getStudentObjectIDByBeacon(student.StudentBeaconID);
        if(!objectID.equals(""))
            DatabaseHelper.LCUpdateAdvertising(objectID);
        updatingStudentID.remove(student.StudentBeaconID + "");
    }

    public void stopLeScanning() {
        if(scanner != null)
            scanner.stopScan(mScannerCallback);
        scanner = null;
        mScannerFilters = null;
        mScannerSettings = null;
        updateInfoLabel("");
        updatingStudentID = new ArrayList<String>();
    }

    public void resetLeScanning(View button) {
        stopLeScanning();
        new Thread(new Runnable() {
            @Override
            public void run() {
                startLeScanning();
            }
        }).start();
    }

    public static boolean checkPermission() {
        if (QinDeviceApplication.getContext().checkSelfPermission(Manifest.permission.BLUETOOTH) != PackageManager.PERMISSION_GRANTED
                || QinDeviceApplication.getContext().checkSelfPermission(Manifest.permission.BLUETOOTH_ADMIN) != PackageManager.PERMISSION_GRANTED
                || QinDeviceApplication.getContext().checkSelfPermission(Manifest.permission.ACCESS_FINE_LOCATION) != PackageManager.PERMISSION_GRANTED
                || QinDeviceApplication.getContext().checkSelfPermission(Manifest.permission.ACCESS_COARSE_LOCATION) != PackageManager.PERMISSION_GRANTED
                || QinDeviceApplication.getContext().checkSelfPermission(Manifest.permission.INTERNET) != PackageManager.PERMISSION_GRANTED
                || QinDeviceApplication.getContext().checkSelfPermission(Manifest.permission.ACCESS_NETWORK_STATE) != PackageManager.PERMISSION_GRANTED) {
            return false;
        }

        LocationManager locationManager = (LocationManager) QinDeviceApplication.getContext().getSystemService(Context.LOCATION_SERVICE);
        boolean gps = locationManager.isProviderEnabled(LocationManager.GPS_PROVIDER);
        boolean network = locationManager.isProviderEnabled(LocationManager.NETWORK_PROVIDER);
        if (!gps && !network) {
            return false;
        }

        //QinDeviceApplication.getContext().checkCallingOrSelfPermission(Context.BLUETOOTH_SERVICE)

        return true;
    }

    private class iBeacon {
        public String UUID;
        public int DeviceBeaconID;
        public int StudentBeaconID;

        public iBeacon(byte[] rawData){
            int rawDataIndex = 0;
            UUID = "";
            DeviceBeaconID = 0;
            StudentBeaconID = 0;
            byte iBeaconType = rawData[rawDataIndex++];
            byte iBeaconDataLength = rawData[rawDataIndex++];
            for (;rawDataIndex < 18;rawDataIndex++)
                UUID += String.format("%02x",rawData[rawDataIndex]);
            DeviceBeaconID = (rawData[rawDataIndex] << 8 & 0xFF00) + rawData[rawDataIndex + 1] & 0xFF;
            StudentBeaconID = (rawData[rawDataIndex + 2] << 8 & 0xFF00) + rawData[rawDataIndex + 3] & 0xFF;
        }
    }
}
