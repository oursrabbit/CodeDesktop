package edu.bfa.ss.bananaemitter;

import androidx.appcompat.app.AppCompatActivity;

import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothManager;
import android.bluetooth.le.AdvertiseData;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.os.Bundle;
import android.widget.Toast;

import java.nio.ByteBuffer;
import java.util.UUID;

public class MainActivity extends AppCompatActivity {

    private BluetoothAdapter bluetoothAdapter;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        //Check BLE Available
        if (!getPackageManager().hasSystemFeature(PackageManager.FEATURE_BLUETOOTH_LE)) {
            Toast.makeText(this, "不支持蓝牙BLE", Toast.LENGTH_LONG).show();
        } else {
            Toast.makeText(this, "可以使用，正在初始化", Toast.LENGTH_LONG).show();
        }

        // Initializes Bluetooth adapter.
        final BluetoothManager bluetoothManager =
                (BluetoothManager) getSystemService(Context.BLUETOOTH_SERVICE);
        bluetoothAdapter = bluetoothManager.getAdapter();

        // Ensures Bluetooth is available on the device and it is enabled. If not,
        // displays a dialog requesting user permission to enable Bluetooth.
        if(bluetoothAdapter == null || !bluetoothAdapter.isEnabled()) {
            Intent enableBtIntent = new Intent(BluetoothAdapter.ACTION_REQUEST_ENABLE);
            startActivityForResult(enableBtIntent, 10);
        }

        bluetoothAdapter.getBluetoothLeAdvertiser()
    }

    protected void setAdvertiseData() {
        AdvertiseData.Builder mBuilder = new AdvertiseData.Builder()
        ByteBuffer mManufacturerData = ByteBuffer.allocate(24);
        byte[] uuid = getIdAsByte(UUID.fromString("0CF052C297CA407C84F8B62AAC4E9020"));
        mManufacturerData.put(0, (byte)0xBE); // Beacon Identifier
        mManufacturerData.put(1, (byte)0xAC); // Beacon Identifier
        for (int i=2; i<=17; i++) {
            mManufacturerData.put(i, uuid[i-2]); // adding the UUID
        }
        mManufacturerData.put(18, (byte)0x00); // first byte of Major
        mManufacturerData.put(19, (byte)0x09); // second byte of Major
        mManufacturerData.put(20, (byte)0x00); // first minor
        mManufacturerData.put(21, (byte)0x06); // second minor
        mManufacturerData.put(22, (byte)0xB5); // txPower
        mBuilder.addManufacturerData(224, mManufacturerData.array()); // using google's company ID
        mAdvertiseData = mBuilder.build();
    }
}
