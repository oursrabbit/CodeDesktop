package com.canyang.ssa.sign

import android.Manifest
import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothManager
import android.bluetooth.le.AdvertiseCallback
import android.bluetooth.le.AdvertiseData
import android.bluetooth.le.AdvertiseSettings
import android.bluetooth.le.BluetoothLeAdvertiser
import android.content.Context
import android.content.pm.PackageManager
import androidx.annotation.NonNull
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant
import java.nio.ByteBuffer

class MainActivity: FlutterFragmentActivity() {
    private var StudentBLE = 0
    private var CheckRoomBLE = 0
    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "edu.bfa.sa.android/camera").setMethodCallHandler {
            // Note: this method is invoked on the main thread.
            call, result ->
            if (call.method == "checkCameraPermission") {
                result.success(checkCameraPermission())
            } else {
                result.notImplemented()
            }
        }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "edu.bfa.sa.android/ble").setMethodCallHandler {
            // Note: this method is invoked on the main thread.
            call, result ->
            when (call.method) {
                "checkBLEPermission" -> {
                    result.success(checkBLEPermission())
                }
                "startAdvertising" -> {
                    StudentBLE = call.argument<Int>("studentble")!!;
                    CheckRoomBLE = call.argument<Int>("roomble")!!;
                    result.success(startAdvertising())
                }
                "stopAdvertising" -> {
                    result.success(stopAdvertising());
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun checkCameraPermission(): Boolean {
        if (ContextCompat.checkSelfPermission(this, Manifest.permission.CAMERA)
                != PackageManager.PERMISSION_GRANTED) {
            // Permission is not granted
            ActivityCompat.requestPermissions(this, arrayOf(Manifest.permission.CAMERA), 1234);
            return false;
        }
        return true;
    }

    private fun checkBLEPermission(): Boolean {
        if (ContextCompat.checkSelfPermission(this, Manifest.permission.ACCESS_FINE_LOCATION)
                != PackageManager.PERMISSION_GRANTED) {
            // Permission is not granted
            ActivityCompat.requestPermissions(this, arrayOf(Manifest.permission.ACCESS_FINE_LOCATION), 1234);
            return false;
        }

        if (ContextCompat.checkSelfPermission(this, Manifest.permission.ACCESS_COARSE_LOCATION)
                != PackageManager.PERMISSION_GRANTED) {
            // Permission is not granted
            ActivityCompat.requestPermissions(this, arrayOf(Manifest.permission.ACCESS_COARSE_LOCATION), 1234);
            return false;
        }

        return true;
    }

    private fun stopAdvertising(): Boolean {
        try {
            advertiser.stopAdvertising(mAdvertiseCallback)
        } catch (e: Exception) {

        }
        return true
    }
    private lateinit var manager: BluetoothManager;
    private lateinit var adapter: BluetoothAdapter;
    private lateinit var advertiser: BluetoothLeAdvertiser;

    private fun startAdvertising(): Boolean {
        try {
            manager = getSystemService(Context.BLUETOOTH_SERVICE) as BluetoothManager
            adapter = manager.adapter
            advertiser = adapter.bluetoothLeAdvertiser
            return if (advertiser == null) {
                false
            } else {
                setAdvertiseData()
                setAdvertiseSettings()
                advertiser.startAdvertising(mAdvertiseSettings, mAdvertiseData, mAdvertiseCallback)
                true
            }
        } catch (e: Exception) {
            return false
        }
    }

    private val mAdvertiseCallback: AdvertiseCallback = object : AdvertiseCallback() {
        override fun onStartSuccess(settingsInEffect: AdvertiseSettings) {
            super.onStartSuccess(settingsInEffect)
        }

        override fun onStartFailure(errorCode: Int) {
            super.onStartFailure(errorCode)
        }
    }

    private lateinit var mAdvertiseData: AdvertiseData;
    private fun setAdvertiseData() {
        val mManufacturerData = ByteBuffer.allocate(23)
        mManufacturerData.put(0, 0x02.toByte()) // SubType
        mManufacturerData.put(1, 0x15.toByte()) // Length
        //0a66e898-2d31-11ea-978f-2e728ce88125
        mManufacturerData.put(2, 0x0a.toByte()) //
        mManufacturerData.put(3, 0x66.toByte()) //
        mManufacturerData.put(4, 0xe8.toByte()) //
        mManufacturerData.put(5, 0x98.toByte()) //
        mManufacturerData.put(6, 0x2d.toByte()) //
        mManufacturerData.put(7, 0x31.toByte()) //
        mManufacturerData.put(8, 0x11.toByte()) //
        mManufacturerData.put(9, 0xea.toByte()) //
        mManufacturerData.put(10, 0x97.toByte()) //
        mManufacturerData.put(11, 0x8f.toByte()) //
        mManufacturerData.put(12, 0x2e.toByte()) //
        mManufacturerData.put(13, 0x72.toByte()) //
        mManufacturerData.put(14, 0x8c.toByte()) //
        mManufacturerData.put(15, 0xe8.toByte()) //
        mManufacturerData.put(16, 0x81.toByte()) //
        mManufacturerData.put(17, 0x25.toByte()) //
        mManufacturerData.put(18, getCheckInRoomID()[0]) //
        mManufacturerData.put(19, getCheckInRoomID()[1]) //
        mManufacturerData.put(20, getStudentBeaconMinor()[0]) //
        mManufacturerData.put(21, getStudentBeaconMinor()[1]) //
        mManufacturerData.put(22, 0xC5.toByte()) //
        val mBuilder = AdvertiseData.Builder()
        mBuilder.addManufacturerData(76, mManufacturerData.array()) //
        mAdvertiseData = mBuilder.build()
    }

    fun getCheckInRoomID(): ByteArray {
        val bytes = byteArrayOf(0x00, 0x00)
        bytes[0] = (CheckRoomBLE shr 8 and 0xFF).toByte()
        bytes[1] = (CheckRoomBLE and 0xFF).toByte()
        return bytes
    }

    fun getStudentBeaconMinor(): ByteArray {
        val bytes = byteArrayOf(0x00, 0x00)
        bytes[0] = (StudentBLE shr 8 and 0xFF).toByte()
        bytes[1] = (StudentBLE and 0xFF).toByte()
        return bytes
    }

    private lateinit var mAdvertiseSettings: AdvertiseSettings;

    private fun setAdvertiseSettings() {
        val mBuilder = AdvertiseSettings.Builder()
        mBuilder.setAdvertiseMode(AdvertiseSettings.ADVERTISE_MODE_LOW_LATENCY)
        mBuilder.setConnectable(false)
        mBuilder.setTimeout(0)
        mBuilder.setTxPowerLevel(AdvertiseSettings.ADVERTISE_TX_POWER_MEDIUM)
        mAdvertiseSettings = mBuilder.build()
    }
}
