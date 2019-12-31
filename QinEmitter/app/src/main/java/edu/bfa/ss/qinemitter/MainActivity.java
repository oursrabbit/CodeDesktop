package edu.bfa.ss.qinemitter;

import androidx.appcompat.app.AppCompatActivity;

import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothManager;
import android.bluetooth.le.AdvertiseCallback;
import android.bluetooth.le.AdvertiseData;
import android.bluetooth.le.AdvertiseSettings;
import android.bluetooth.le.BluetoothLeAdvertiser;
import android.content.Context;
import android.content.pm.PackageManager;
import android.os.Bundle;
import android.os.ParcelUuid;
import android.util.Log;
import android.widget.Toast;

import java.nio.ByteBuffer;
import java.util.UUID;

public class MainActivity extends AppCompatActivity {

    private BluetoothManager manager;
    private BluetoothAdapter adapter;
    private BluetoothLeAdvertiser advertiser;
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        if (!getPackageManager().hasSystemFeature(PackageManager.FEATURE_BLUETOOTH_LE)) {
            Toast.makeText(this, "不支持", Toast.LENGTH_LONG).show();
            return;
        }

        manager = (BluetoothManager) getSystemService(Context.BLUETOOTH_SERVICE);
        adapter = manager.getAdapter();
        adapter.setName("BFASS");
        advertiser = adapter.getBluetoothLeAdvertiser();

        setAdvertiseData();
        setAdvertiseSettings();

        advertiser.startAdvertising(mAdvertiseSettings, mAdvertiseData, mAdvertiseCallback);
    }

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

    private AdvertiseData mAdvertiseData;

    protected void setAdvertiseData() {
        ByteBuffer mManufacturerData = ByteBuffer.allocate(14);
        mManufacturerData.put(0, (byte)0x03); // SubType
        mManufacturerData.put(1, (byte)0x0C); // Length
        mManufacturerData.put(2, (byte)0x00); //
        mManufacturerData.put(3, (byte)0x00); //
        mManufacturerData.put(4, (byte)0x00); //
        mManufacturerData.put(5, (byte)0x00); // 楼号
        mManufacturerData.put(6, (byte)0x00); //
        mManufacturerData.put(7, (byte)0x02); //
        mManufacturerData.put(8, (byte)0x60); //
        mManufacturerData.put(9, (byte)0x00); // 房号
        mManufacturerData.put(10, (byte)0x00); //
        mManufacturerData.put(11, (byte)0x00); //
        mManufacturerData.put(12, (byte)0x00); //
        mManufacturerData.put(13, (byte)0xB0); // 保留

        AdvertiseData.Builder mBuilder = new AdvertiseData.Builder();
        mBuilder.addManufacturerData(0x0501, mManufacturerData.array()); //
        mBuilder.setIncludeDeviceName(true);
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
