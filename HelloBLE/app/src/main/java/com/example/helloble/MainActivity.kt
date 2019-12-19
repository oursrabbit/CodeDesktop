package com.example.helloble

import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothManager
import android.bluetooth.le.*
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import androidx.appcompat.app.AppCompatActivity
import android.os.Bundle
import android.os.ParcelUuid
import android.widget.Toast
import androidx.core.app.JobIntentService

class MainActivity : AppCompatActivity() {

    private val bluetoothScanner: BluetoothLeScanner? by lazy(LazyThreadSafetyMode.NONE) {
        val bluetoothManager = getSystemService(Context.BLUETOOTH_SERVICE) as BluetoothManager
        bluetoothManager.adapter.bluetoothLeScanner
    }

    class myScanCallback: ScanCallback() {
        override fun onBatchScanResults(results: MutableList<ScanResult>?) {
            super.onBatchScanResults(results)
        }

        override fun onScanFailed(errorCode: Int) {
            super.onScanFailed(errorCode)
        }

        override fun onScanResult(callbackType: Int, result: ScanResult?) {
            super.onScanResult(callbackType, result)
            var record = result?.scanRecord
            var data = record?.serviceData
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

       /* packageManager.takeIf {
            it.hasSystemFeature(PackageManager.FEATURE_BLUETOOTH_LE)
        }?.also {
            Toast.makeText(this, "支持", Toast.LENGTH_LONG).show()
        }
        var filters = ArrayList<ScanFilter>()
        var scanFilter = ScanFilter.Builder()
            .setServiceUuid(ParcelUuid.fromString("fda50693-a4e2-4fb1-afcf-c6eb07647825")).build()
        var scanSettings = ScanSettings.Builder().build()
        filters.add(scanFilter)*/
        bluetoothScanner?.startScan(myScanCallback())
    }
}
