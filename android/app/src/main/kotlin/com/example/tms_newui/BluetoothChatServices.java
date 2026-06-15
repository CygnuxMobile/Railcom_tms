package com.example.tms_newui;

import android.Manifest;
import android.app.Activity;
import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothDevice;
import android.bluetooth.BluetoothServerSocket;
import android.bluetooth.BluetoothSocket;
import android.content.Context;
import android.content.pm.PackageManager;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Matrix;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.os.Message;
import android.util.Log;
import android.widget.Toast;


import androidx.core.app.ActivityCompat;

import com.example.tms_newui.BluetoothChatServices;



import com.example.tms_newui.PrintLaunchActivity;
import com.example.tms_newui.R;



import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;

import java.util.UUID;

public class BluetoothChatServices {
    private static final UUID MY_UUID = UUID.fromString("00001101-0000-1000-8000-00805F9B34FB");
    private static final String NAME = "BluetoothChat";
    public static final int STATE_CONNECTED = 3;
    public static final int STATE_CONNECTING = 2;
    public static final int STATE_LISTEN = 1;
    public static final int STATE_NONE = 0;
    private static final String TAG = "BluetoothChatService";
    public static int t_status = 0;
    private byte[] buffer = new byte[2048];
    private byte[] buffer2 = new byte[2048];
    private int last_bytes = 0;
    private AcceptThread mAcceptThread;
    private final BluetoothAdapter mAdapter = BluetoothAdapter.getDefaultAdapter();
    private ConnectThread mConnectThread;
    private ConnectedThread mConnectedThread;
    private Handler mHandler;
    public int mState = 0;

    private class AcceptThread extends Thread {
        private final BluetoothServerSocket mmServerSocket;

        public AcceptThread() {
            BluetoothServerSocket tmp = null;
            try {
                tmp = mAdapter.listenUsingRfcommWithServiceRecord(BluetoothChatServices.NAME, BluetoothChatServices.MY_UUID);
            } catch (IOException e) {
                Log.e(TAG, "listen() failed", e);
            }
            this.mmServerSocket = tmp;
        }

        public void run() {
            Log.d(TAG, "BEGIN mAcceptThread" + this);
            setName("AcceptThread");
            while (mState != 3) {
                try {
                    BluetoothSocket socket = this.mmServerSocket.accept();
                    if (socket != null) {
                        synchronized (this) {
                            switch (mState) {
                                case STATE_NONE /*0*/:
                                case 3:
                                    try {
                                        socket.close();
                                        break;
                                    } catch (IOException e) {
                                        Log.e(TAG, "Could not close unwanted socket", e);
                                        break;
                                    }
                                case 1:
                                case 2:
                                    connected(socket, socket.getRemoteDevice());
                                    break;
                            }
                        }
                    }
                } catch (IOException e2) {
                    Log.e(TAG, "accept() failed", e2);
                }
            }
            Log.i(TAG, "END mAcceptThread");
        }

        public void cancel() {
            Log.d(TAG, "cancel " + this);
            try {
                this.mmServerSocket.close();
            } catch (IOException e) {
                Log.e(TAG, "close() of server failed", e);
            }
        }
    }

    private class ConnectThread extends Thread {
        private final BluetoothDevice mmDevice;
        private final BluetoothSocket mmSocket;

        public ConnectThread(BluetoothDevice device) {
            this.mmDevice = device;
            BluetoothSocket tmp = null;
            try {
                tmp = device.createRfcommSocketToServiceRecord(BluetoothChatServices.MY_UUID);
            } catch (IOException e) {
                Log.e(TAG, "create() failed", e);
            }
            this.mmSocket = tmp;
        }

        public void run() {
            Log.i(TAG, "BEGIN mConnectThread");
            setName("ConnectThread");
            mAdapter.cancelDiscovery();
            try {
                mmSocket.connect();
                synchronized (this) {
                    mConnectThread = null;
                }
                connected(this.mmSocket, this.mmDevice);
            } catch (IOException e) {
                connectionFailed();
                try {
                    mmSocket.close();
                } catch (IOException e2) {
                    Log.e(TAG, "unable to close() socket during connection failure", e2);
                }
           //     start();
                ConnectThread newConnectThread = new ConnectThread(mmDevice);
                newConnectThread.start();
            }
        }

        public void cancel() {
            try {
                this.mmSocket.close();
            } catch (IOException e) {
                Log.e(TAG, "close() of connect socket failed", e);
            }
        }
    }

    private class ConnectedThread extends Thread {
        private final InputStream mmInStream;
        private final OutputStream mmOutStream;
        private final BluetoothSocket mmSocket;

        public ConnectedThread(BluetoothSocket socket) {
            Log.d(TAG, "create ConnectedThread");
            this.mmSocket = socket;
            InputStream tmpIn = null;
            OutputStream tmpOut = null;
            try {
                tmpIn = socket.getInputStream();
                tmpOut = socket.getOutputStream();
            } catch (IOException e) {
                Log.e(TAG, "temp sockets not created", e);
            }
            this.mmInStream = tmpIn;
            this.mmOutStream = tmpOut;
        }

        public void run() {
            Log.i(TAG, "BEGIN mConnectedThread");
            while (true) {
                try {
                    Thread.sleep(300);
                } catch (InterruptedException e) {
                    e.printStackTrace();
                }
                try {
                    int bytes = this.mmInStream.read(buffer);
                    if (bytes >= 0) {
                        System.arraycopy(buffer, 0, buffer2, last_bytes, bytes);
                    }
                    last_bytes = bytes;
                    mHandler.obtainMessage(2, bytes, -1, buffer2).sendToTarget();
                    for (int i = 0; i <= buffer2.length - 1; i++) {
                        if (buffer2[i] == (byte) 26) {
                            last_bytes = 0;
                            buffer = new byte[1024];
                            buffer2 = new byte[1024];
                            break;
                        }
                    }
                } catch (Exception e) {
                    e.getMessage();
                } /*catch (IOException e2) {
                    Log.e(BluetoothChatService.TAG, "disconnected", e2);
                }*/
            }
        }

        void write(byte[] buffer) {
            try {
                this.mmOutStream.write(buffer);
                buffer = new byte[1024];
                buffer2 = new byte[1024];
                int writebuflen = buffer.length;
                byte[] writebuf = new byte[writebuflen];
                System.arraycopy(buffer, 0, writebuf, 0, writebuflen);
                mHandler.obtainMessage(3, -1, -1, writebuf).sendToTarget();
            } catch (IOException e) {
                Log.e(TAG, "Exception during write", e);
            }
            last_bytes = 0;
        }

        public void cancel() {
            try {
                this.mmSocket.close();
            } catch (IOException e) {
                Log.e(TAG, "close() of connect socket failed", e);
            }
        }
    }

    public BluetoothChatServices(Handler handler) {
        this.mHandler = handler;
    }

    private synchronized void setState(int state) {
        Log.d(TAG, "setState() " + this.mState + " -> " + state);
        this.mState = state;
        this.mHandler.obtainMessage(1, state, -1).sendToTarget();
    }

    public synchronized int getState() {
        return this.mState;
    }

    public synchronized void start() {
        Log.d(TAG, "start");
        if (this.mConnectThread != null) {
            this.mConnectThread.cancel();
            this.mConnectThread = null;
        }
        if (this.mConnectedThread != null) {
            this.mConnectedThread.cancel();
            this.mConnectedThread = null;
        }
        if (this.mAcceptThread == null) {
            this.mAcceptThread = new AcceptThread();
            this.mAcceptThread.start();
        }
        setState(1);
    }

    public synchronized void connect(BluetoothDevice device) {
        Log.d(TAG, "connect to: " + device);
        if (this.mState == 2 && this.mConnectThread != null) {
            this.mConnectThread.cancel();
            this.mConnectThread = null;
        }
        if (this.mConnectedThread != null) {
            this.mConnectedThread.cancel();
            this.mConnectedThread = null;
        }
        this.mConnectThread = new ConnectThread(device);
        this.mConnectThread.start();
        setState(2);
    }

    public synchronized void connected(BluetoothSocket socket, BluetoothDevice device) {
        Log.d(TAG, "connected");
        if (this.mConnectThread != null) {
            this.mConnectThread.cancel();
            this.mConnectThread = null;
        }
        if (this.mConnectedThread != null) {
            this.mConnectedThread.cancel();
            this.mConnectedThread = null;
        }
        if (this.mAcceptThread != null) {
            this.mAcceptThread.cancel();
            this.mAcceptThread = null;
        }
        this.mConnectedThread = new ConnectedThread(socket);
        this.mConnectedThread.start();
        Message msg = this.mHandler.obtainMessage(4);
        Bundle bundle = new Bundle();

        bundle.putString(PrintLaunchActivity.DEVICE_NAME, device.getName());
        msg.setData(bundle);
        this.mHandler.sendMessage(msg);
        t_status = 1;
        setState(3);
    }

    public void write(byte[] out) {
        synchronized (this) {
            if (this.mState != 3) {
                return;
            }
            ConnectedThread r = this.mConnectedThread;
            r.write(out);
        }
    }

    private void connectionFailed() {
        setState(1);
        Message msg = this.mHandler.obtainMessage(5);
        Bundle bundle = new Bundle();
        bundle.putString("BluetoothChat", "Unable to connect device");
        msg.setData(bundle);
        this.mHandler.sendMessage(msg);
    }


  /*  public static void ZebraPrint(Context context, String bluetooth_address, BarCodeSerial item, Integer current_pkg_no) {
        Activity activity = (Activity) context;
        new Handler().post(new Runnable() {
            @Override
            public void run() {
                if (!activity.isFinishing()) {
                    UIHelper helper = new UIHelper(activity);
                    final Bitmap[] bitmap = new Bitmap[1];
                    if (connection == null) {
                        connection = new BluetoothConnection(bluetooth_address);
                    }
                    // Looper.prepare();
                    try {
                        connection.open();
                        ZebraPrinter printer = ZebraPrinterFactory.getInstance(connection);
                        ZebraPrinterLinkOs linkOsPrinter = ZebraPrinterFactory.createLinkOsPrinter(printer);
                        PrinterStatus printerStatus = (linkOsPrinter != null) ? linkOsPrinter.getCurrentStatus() : printer.getCurrentStatus();
                        getPrinterStatus(context, connection);
                        if (printerStatus.isReadyToPrint) {
                            activity.runOnUiThread(new Runnable() {
                                @Override
                                public void run() {
                                    try {
                                        Toast.makeText(context, "Printer Ready", Toast.LENGTH_LONG).show();
                                        bitmap[0] = printPrint(context, connection, printer, helper, item, current_pkg_no);
                                    } catch (Exception e) {
                                        helper.showErrorDialogOnGuiThread(e.getMessage());
                                    }

                                }
                            });
                        } else if (printerStatus.isHeadOpen) {
                            helper.showErrorMessage("Error: Head Open \nPlease Close Printer Head to Print");
                        } else if (printerStatus.isPaused) {
                            helper.showErrorMessage("Error: Printer Paused");
                        } else if (printerStatus.isPaperOut) {
                            helper.showErrorMessage("Error: Media Out \nPlease Load Media to Print");
                        } else {
                            helper.showErrorMessage("Error: Please check the Connection of the Printer");
                        }
                        connection.close();
                        //getAndSaveSettings();
                    } catch (ConnectionException e) {
                        Log.e(TAG, "ZebraPrint: ConnectionException " + e.getMessage());
                        helper.showErrorDialogOnGuiThread(e.getMessage());
                    } catch (ZebraPrinterLanguageUnknownException e) {
                        Log.e(TAG, "ZebraPrint: LanguageUnknownException" + e.getMessage());
                        helper.showErrorDialogOnGuiThread(e.getMessage());
                    } catch (Exception e) {
                        Log.e(TAG, "ZebraPrint:Exception " + e.getMessage());
                        helper.showErrorDialogOnGuiThread(e.getMessage());

                    } finally {
                        helper.dismissLoadingDialog();
                    }
                }
            }
        });
//        return bitmap[0];
    }*/

    public static Bitmap addPaddingTopForBitmap(Bitmap bitmap, int paddingTop) {
        Bitmap outputBitmap = Bitmap.createBitmap(bitmap.getWidth(), bitmap.getHeight() + paddingTop, Bitmap.Config.ARGB_8888);
        Canvas canvas = new Canvas(outputBitmap);
        canvas.drawColor(Color.WHITE);
        canvas.drawBitmap(bitmap, 0, paddingTop, null);
        return outputBitmap;
    }

    public static Bitmap addPaddingBottomForBitmap(Bitmap bitmap, int paddingBottom) {
        Bitmap outputBitmap = Bitmap.createBitmap(bitmap.getWidth(), bitmap.getHeight() + paddingBottom, Bitmap.Config.ARGB_8888);
        Canvas canvas = new Canvas(outputBitmap);
        canvas.drawColor(Color.WHITE);
        canvas.drawBitmap(bitmap, 0, 0, null);
        return outputBitmap;
    }


   /* private static Bitmap printPrint(Context context, Connection connection, ZebraPrinter printer, UIHelper helper, BarCodeSerial item, Integer current_pkg_no) {
        Bitmap img = null;
        try {
            connection.open();
            //connection.write("! U1 JOURNAL\r\n! U1 SETFF 50 2\r\n".getBytes());
            Bitmap signatureBitmap = Bitmap.createScaledBitmap(BitmapFactory.decodeResource(context.getResources(), R.drawable.origin_lat_new_des_2), 574, 372, false);
            //Bitmap signatureBitmap1 = addPaddingLeftForBitmap(signatureBitmap, 30);
            if (item != null) {
                img = Common.writeTextOnDrawable(context, signatureBitmap, item, current_pkg_no).getBitmap();
                Matrix matrix = new Matrix();
                matrix.postRotate(360);
                Bitmap scaledBitmap = Bitmap.createBitmap(img, 0, 0, img.getWidth(), img.getHeight(), matrix, true);
               *//* Bitmap signatureBitmap1 = addPaddingTopForBitmap(scaledBitmap, 50);
                Bitmap signatureBitmap2 = addPaddingBottomForBitmap(signatureBitmap1, 50);*//*
                ZebraImageAndroid zebraImageAndroid = new ZebraImageAndroid(scaledBitmap);
                // printer.printImage(new ZebraImageAndroid(signatureBitmap1), -150, 0, 0, 0, false);
                //connection.write(printString.getBytes());
                printer.printImage(zebraImageAndroid, 0, 0, 0, 0, false); //-150  right ,000
            }
            connection.write("! U1 JOURNAL\r\n! U1 SETFF 50 2\r\n".getBytes());
            connection.close();
        } catch (ConnectionException e) {
            helper.showErrorDialogOnGuiThread(e.getMessage());
        } catch (Exception e) {
            e.printStackTrace();
        }
        return img;
    }*/


}
