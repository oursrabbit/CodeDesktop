package edu.bfa.ss.qinemitter;

import androidx.appcompat.app.AppCompatActivity;

import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothManager;
import android.bluetooth.le.AdvertiseCallback;
import android.bluetooth.le.AdvertiseData;
import android.bluetooth.le.AdvertiseSettings;
import android.bluetooth.le.BluetoothLeAdvertiser;
import android.content.Context;
import android.os.Bundle;

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

        manager = (BluetoothManager) getSystemService(Context.BLUETOOTH_SERVICE);
        adapter = manager.getAdapter();
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
        AdvertiseData.Builder mBuilder = new AdvertiseData.Builder();
        ByteBuffer mManufacturerData = ByteBuffer.allocate(24);
        byte[] uuid = {0x2F, (byte)0x23, 0x44, (byte)0x54, (byte)0xCF, (byte)0x6D, 0x4A, 0x0F, (byte)0xAD, (byte)0xF2, (byte)0xF4, (byte)0x91, (byte)0x1B, (byte)0xA9, (byte)0xFF, (byte)0xA6};
        mManufacturerData.put(0, (byte)0x02); // Beacon Identifier
        mManufacturerData.put(1, (byte)0x15); // Beacon Identifier
        for (int i=2; i<=17; i++) {
            mManufacturerData.put(i, uuid[i-2]); // adding the UUID
        }
        mManufacturerData.put(18, (byte)0x05); // first byte of Major
        mManufacturerData.put(19, (byte)0x00); // second byte of Major
        mManufacturerData.put(20, (byte)0x06); // first minor
        mManufacturerData.put(21, (byte)0x00); // second minor
        mManufacturerData.put(22, (byte)0xB5); // txPower
        mBuilder.addManufacturerData(0x004C, mManufacturerData.array()); // using google's company ID
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
