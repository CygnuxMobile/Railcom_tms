package com.example.tms_newui;

import android.Manifest;
import android.annotation.SuppressLint;
import android.app.Activity;
import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothDevice;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.pm.PackageManager;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.ArrayAdapter;
import android.widget.ListView;
import android.widget.TextView;


import androidx.core.app.ActivityCompat;

import java.util.Objects;
import java.util.Set;

public class DeviceListActivity extends Activity {
    //ActivityDeviceListBinding binding;
    private static final boolean D = true;
    public static String EXTRA_DEVICE_ADDRESS = "device_address";
    public static String EXTRA_DEVICE_NAME = "device_name";
    private static final String TAG = "DeviceListActivity";
    private BluetoothAdapter mBtAdapter;
    @SuppressLint("MissingPermission")
    private OnItemClickListener mDeviceClickListener = (adapterView, v, arg2, arg3) -> {
        DeviceListActivity.this.mBtAdapter.cancelDiscovery();
        String info = ((TextView) v).getText().toString();
        String address = info.substring(info.length() - 17);
        String name = info.substring(0, info.length() - 17);
        Intent intent = new Intent();
        intent.putExtra(DeviceListActivity.EXTRA_DEVICE_ADDRESS, address);
        intent.putExtra(DeviceListActivity.EXTRA_DEVICE_NAME, name);
        DeviceListActivity.this.setResult(-1, intent);
        DeviceListActivity.this.finish();
    };
    private ArrayAdapter<String> mNewDevicesArrayAdapter;
    private ArrayAdapter<String> mPairedDevicesArrayAdapter;
    private final BroadcastReceiver mReceiver = new BroadcastReceiver() {
        @SuppressLint("MissingPermission")
        public void onReceive(Context context, Intent intent) {
            String action = intent.getAction();
            if ("android.bluetooth.device.action.FOUND".equals(action)) {
                BluetoothDevice device = intent.getParcelableExtra("android.bluetooth.device.extra.DEVICE");
                if (device.getBondState() != 12) {
                    DeviceListActivity.this.mNewDevicesArrayAdapter.add(device.getName() + "\n" + device.getAddress());
                }
            } else if ("android.bluetooth.adapter.action.DISCOVERY_FINISHED".equals(action)) {
                DeviceListActivity.this.setProgressBarIndeterminateVisibility(false);
                DeviceListActivity.this.setTitle(R.string.select_device);
                if (DeviceListActivity.this.mNewDevicesArrayAdapter.getCount() == 0) {
                    DeviceListActivity.this.mNewDevicesArrayAdapter.add(DeviceListActivity.this.getResources().getText(R.string.none_found).toString());
                }
            }
        }
    };

    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        requestWindowFeature(5);
        setContentView(R.layout.device_list);
      /*  binding = ActivityDeviceListBinding.inflate(getLayoutInflater());
        View view = binding.getRoot();
        setContentView(view);*/

        setResult(0);
        findViewById(R.id.button_scan).setOnClickListener(v -> {
            DeviceListActivity.this.doDiscovery();
            v.setVisibility(View.GONE);
        });
        this.mPairedDevicesArrayAdapter = new ArrayAdapter(this, R.layout.device_name);
        this.mNewDevicesArrayAdapter = new ArrayAdapter(this, R.layout.device_name);
        ListView pairedListView = findViewById(R.id.paired_devices);
        pairedListView.setAdapter(this.mPairedDevicesArrayAdapter);
        pairedListView.setOnItemClickListener(this.mDeviceClickListener);
        ListView newDevicesListView = findViewById(R.id.new_devices);
        newDevicesListView.setAdapter(this.mNewDevicesArrayAdapter);
        newDevicesListView.setOnItemClickListener(this.mDeviceClickListener);
        registerReceiver(this.mReceiver, new IntentFilter("android.bluetooth.device.action.FOUND"));
        registerReceiver(this.mReceiver, new IntentFilter("android.bluetooth.adapter.action.DISCOVERY_FINISHED"));
        this.mBtAdapter = BluetoothAdapter.getDefaultAdapter();
        Set<BluetoothDevice> pairedDevices = this.mBtAdapter.getBondedDevices();
        if (pairedDevices.size() > 0) {
            findViewById(R.id.title_paired_devices).setVisibility(View.VISIBLE);
            for (BluetoothDevice device : pairedDevices) {
                this.mPairedDevicesArrayAdapter.add(device.getName() + "\n" + device.getAddress());
            }
            return;
        }
        this.mPairedDevicesArrayAdapter.add(getResources().getText(R.string.none_paired).toString());
    }

    @SuppressLint("MissingPermission")
    protected void onDestroy() {
        super.onDestroy();
        if (this.mBtAdapter != null) {
            this.mBtAdapter.cancelDiscovery();
        }
        unregisterReceiver(this.mReceiver);
    }

    private void doDiscovery() {
        Log.d(TAG, "doDiscovery()");
        setProgressBarIndeterminateVisibility(true);
        setTitle(R.string.scanning);
        findViewById(R.id.title_new_devices).setVisibility(View.VISIBLE);
        if (ActivityCompat.checkSelfPermission(this, Manifest.permission.BLUETOOTH_SCAN) != PackageManager.PERMISSION_GRANTED) {
            // TODO: Consider calling
            //    ActivityCompat#requestPermissions
            // here to request the missing permissions, and then overriding
            //   public void onRequestPermissionsResult(int requestCode, String[] permissions,
            //                                          int[] grantResults)
            // to handle the case where the user grants the permission. See the documentation
            // for ActivityCompat#requestPermissions for more details.
            return;
        }
        if (this.mBtAdapter.isDiscovering()) {
            this.mBtAdapter.cancelDiscovery();
        }
        this.mBtAdapter.startDiscovery();
    }
}
