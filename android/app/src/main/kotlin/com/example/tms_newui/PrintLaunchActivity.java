
package com.example.tms_newui;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.app.ProgressDialog;
import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothDevice;
import android.bluetooth.BluetoothProfile;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.SharedPreferences;
import android.graphics.Bitmap;
import android.graphics.Color;
import android.graphics.Matrix;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.util.Log;
import android.view.Menu;
import android.view.View;
import android.view.WindowManager;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.RadioButton;
import android.widget.RelativeLayout;
import android.widget.TextView;
import android.widget.Toast;

import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;
import androidx.appcompat.widget.Toolbar;

import com.zebra.sdk.comm.BluetoothConnection;
import com.zebra.sdk.comm.Connection;
import com.zebra.sdk.comm.ConnectionException;
import com.zebra.sdk.graphics.internal.ZebraImageAndroid;
import com.zebra.sdk.printer.PrinterStatus;
import com.zebra.sdk.printer.SGD;
import com.zebra.sdk.printer.ZebraPrinter;
import com.zebra.sdk.printer.ZebraPrinterFactory;
import com.zebra.sdk.printer.ZebraPrinterLanguageUnknownException;
import com.zebra.sdk.printer.ZebraPrinterLinkOs;

import java.io.File;
import java.util.ArrayList;
import java.util.Objects;

public class PrintLaunchActivity extends AppCompatActivity {

    private static final String bluetoothAddressKey = "ZEBRA_DEMO_BLUETOOTH_ADDRESS";
    private static final String tcpAddressKey = "ZEBRA_DEMO_TCP_ADDRESS";
    private static final String tcpPortKey = "ZEBRA_DEMO_TCP_PORT";
    private static final String PREFS_NAME = "OurSavedAddress";
    public static final String ACK_PRINT = "AckPrintData";
    public Connection connection;
    public static final String DEVICE_NAME = "device_name";
    String address;
    private RadioButton btRadioButton;
    private EditText macAddressEditText;
    private EditText ipAddressEditText;
    private EditText portNumberEditText;

    String printerMacAddress;

    private Button testButton, ExitButton;
    private ZebraPrinter printer;
    private TextView statusField;
    private ProgressDialog progressDialog;
    RelativeLayout toolbar;
    ImageView img_back;
    TextView tvToolbarTitle;
    private BluetoothAdapter mBluetoothAdapter = null;
    private BluetoothChatServices mChatService;
    private String bluetooth_name, bluetooth_address;

    private ArrayList<String> DataPrint = new ArrayList<>();
    public String prnData = "SIZE 69.9 mm, 101.6 mm\n" +
            "DIRECTION 0,0\n" +
            "REFERENCE 0,0\n" +
            "OFFSET 0 mm\n" +
            "SET PEEL OFF\n" +
            "SET CUTTER OFF\n" +
            "SET PARTIAL_CUTTER OFF\n" +
            "SET TEAR ON\n" +
            "CLS\n" +

            //borderbox
            "BOX 10,10,550,750,3\n" +

            //qrcode
            "QRCODE 420,51,L,9,A,90,M2,S7,\" " +
            "getQRCodeValue()" +
            "\"\n" +
            "DIAGONAL 101,460,57,444,3\n" +
            "TEXT 106,450,\"1\",90,2,3,\"" +
            "/" +
            "\"\n" +

            //STO box
            "BOX 320,330,380,420,3\n" +
            "TEXT 360,344,\"ROMAN.TTF\",90,1,10,\"STO\"\n" +

            //header-to, partid, date and description
            "TEXT 534,50,\"ROMAN.TTF\",90,1,10,\"TO:\"\n" +
            "TEXT 534,344,\"ROMAN.TTF\",90,1,10,\"Part ID:\"\n" +
            "TEXT 490,360,\"ROMAN.TTF\",90,1,10,\"Desc:\"\n" +
            "TEXT 534,100,\"ROMAN.TTF\",90,1,10,\"0987654321\"\n" +
            "TEXT 534,490,\"ROMAN.TTF\",90,1,10,\"098765432121\"\n" +
            "TEXT 490,50,\"ROMAN.TTF\",90,1,10,\"15 Jun 23 01:01 Am\"\n" +
            //description
            "TEXT 490,490,\"ROMAN.TTF\",90,1,10,\"MAIN MIRROR\"\n" +
            "TEXT 460,490,\"ROMAN.TTF\",90,1,10,\"ASSAY\"\n" +

            //right side of qr code grnNO and grn date
            "TEXT 350,510,\"ROMAN.TTF\",90,1,10,\"GRN:\"\n" +
            "TEXT 350,570,\"ROMAN.TTF\",90,1,10,\"1234567890\"\n" +
            "TEXT 311,540,\"ROMAN.TTF\",90,1,10,\"15 Jun 2023\"\n" +

            //ty, storage bin, qty, uom
            "TEXT 200,60,\"ROMAN.TTF\",90,1,10,\"T\"\n" +
            "TEXT 156,60,\"ROMAN.TTF\",90,1,10,\"s\"\n" +
            "TEXT 112,60,\"ROMAN.TTF\",90,1,10,\"d\"\n" +
            //ty
            "TEXT 200,130,\"ROMAN.TTF\",90,1,10,\"TY.\"\n" +
            "TEXT 156,120,\"ROMAN.TTF\",90,1,10,\"902\"\n" +
            "TEXT 112,120,\"ROMAN.TTF\",90,1,10,\"902\"\n" +
            //storagebin
            "TEXT 200,250,\"ROMAN.TTF\",90,1,10,\"Storage Bin\"\n" +
            "TEXT 156,250,\"ROMAN.TTF\",90,1,10,\"6543987654\"\n" +
            "TEXT 112,265,\"ROMAN.TTF\",90,1,10,\"12-34-H1\"\n" +
            //qty
            "TEXT 200,530,\"ROMAN.TTF\",90,1,10,\"Qty\"\n" +
            "TEXT 134,540,\"ROMAN.TTF\",90,1,10,\"40\"\n" +
            //uom
            "TEXT 200,620,\"ROMAN.TTF\",90,1,10,\"UOM\"\n" +
            "TEXT 134,630,\"ROMAN.TTF\",90,1,10,\"EA\"\n" +
            "PRINT 1,1\n";

    //    public String prnData = "''\n" +
//        "    ^XA~TA000~JSN^LT0^MNW^MTT^PON^PMN^LH0,0^JMA^PR6,6~SD15^JUS^LRN^CI0^XZ\n" +
//        "    ^XA\n" +
//        "    ^MMC\n" +
//        "    ^PW500\n" +
//        "    ^LL0240\n" +
//        "    ^LS0\n" +
//        "    ^FT144,33^A0N,25,24^FB111,1,0,C^FH\\^FDITEM TITLE^FS\n" +
//        "    ^FT3,61^A@N,20,20,TT0003M_^FB394,1,0,C^FH\\^CI17^F8^FDOption 1, Option 2, Option 3, Option 4, Opt^FS^CI0\n" +
//        "    ^FT3,84^A@N,20,20,TT0003M_^FB394,1,0,C^FH\\^CI17^F8^FDion 5, Option 6 ^FS^CI0\n" +
//        "    ^FT34,138^A@N,25,24,TT0003M_^FB331,1,0,C^FH\\^CI17^F8^FDOrder: https://eat.chat/phobac^FS^CI0\n" +
//        "    ^FT29,173^A@N,20,20,TT0003M_^FB342,1,0,C^FH\\^CI17^F8^FDPromotional Promotional Promotional^FS^CI0\n" +
//        "    ^FT29,193^A@N,20,20,TT0003M_^FB342,1,0,C^FH\\^CI17^F8^FD Promotional Promotional ^FS^CI0\n" +
//        "    ^FT106,233^A0N,25,24^FB188,1,0,C^FH\\^FDPHO BAC HOA VIET^FS\n" +
//        "    ^PQ1,0,1,Y^XZ";
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN, WindowManager.LayoutParams.FLAG_FULLSCREEN);

        SharedPreferences settings = getSharedPreferences(PREFS_NAME, 0);

        try {

            DataPrint = getIntent().getStringArrayListExtra(PrintLaunchActivity.ACK_PRINT);

            Log.d("DataList:KKKK", "------------>" + DataPrint.size());
            for (int i = 0; i < DataPrint.size(); i++) {
                Log.e("TAG", "printAllStickers:set done KK " + DataPrint.get(i));
            }
        } catch (Exception e) {
            Log.e("PPP", "------------>" + e.getMessage());

        }
        toolbar = this.findViewById(R.id.toolbar);
        img_back = this.findViewById(R.id.img_back);
        tvToolbarTitle = this.findViewById(R.id.tvToolbarTitle);
        ExitButton = this.findViewById(R.id.ExitButton);
        macAddressEditText = (EditText) this.findViewById(R.id.macInput);
        img_back.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                onBackPressed();
            }
        });


        tvToolbarTitle.setText("Print Screen");

        printerMacAddress = settings.getString(bluetoothAddressKey, "");
        macAddressEditText.setText(printerMacAddress);
//        Log.e("TAG", "onCreate:KKKKK "+printerMacAddress );

      /*  if(printerMacAddress != null){
            if(printerMacAddress.length() > 0){
                new Handler().postDelayed(new Runnable() {
                    @Override
                    public void run() {
                        enableTestButton(false);
                        setStatus("Connected", Color.GREEN);
                        testButton.setBackground(getResources().getDrawable(R.drawable.circular_background_gray));
                        testButton.setTextColor(Color.BLACK);

                        macAddressEditText.setText(printerMacAddress);
                        progressDialog.show();
                        printAllStickers();
                    }
                }, 500);
            }else{
                Toast.makeText(PrintLaunchActivity.this, "Blootuth Not connected", Toast.LENGTH_SHORT).show();
                // enableTestButton(false);
            }
        }
*/
        progressDialog = new ProgressDialog(PrintLaunchActivity.this);
        progressDialog.setMessage(getString(R.string.pls_wait));
        progressDialog.setCancelable(false);

        statusField = (TextView) this.findViewById(R.id.statusText);

        testButton = (Button) this.findViewById(R.id.testButton);
        testButton.setOnClickListener(new View.OnClickListener() {

            public void onClick(View v) {
                new Thread(new Runnable() {
                    public void run() {
                        startActivityForResult(new Intent(PrintLaunchActivity.this, DeviceListActivity.class), 1);
                    }
                }).start();
            }
        });

        ExitButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                SettingsHelper.clearBluetoothAddress(PrintLaunchActivity.this);
                testButton.setBackground(getResources().getDrawable(R.drawable.circular_background));
                testButton.setTextColor(Color.WHITE);
                enableTestButton(true);
                setStatus("Not Connected", Color.BLACK);


            }
        });

        IntentFilter filter = new IntentFilter();
        filter.addAction(BluetoothDevice.ACTION_ACL_CONNECTED);
        filter.addAction(BluetoothDevice.ACTION_ACL_DISCONNECT_REQUESTED);
        filter.addAction(BluetoothDevice.ACTION_ACL_DISCONNECTED);
        this.registerReceiver(mReceiver, filter);

        mBluetoothAdapter = BluetoothAdapter.getDefaultAdapter();
        setBluetoothListner();

        mChatService = new BluetoothChatServices(mHandler);

        if (this.mBluetoothAdapter == null) {
            Toast.makeText(PrintLaunchActivity.this, "Bluetooth is not available", Toast.LENGTH_SHORT).show();
            finish();
        }

        if (!SettingsHelper.getBluetoothAddress(PrintLaunchActivity.this).isEmpty()) {
            mChatService.connect(mBluetoothAdapter.getRemoteDevice(printerMacAddress));
            enableTestButton(false);
            testButton.setBackground(getResources().getDrawable(R.drawable.circular_background_gray));
            testButton.setTextColor(Color.BLACK);
            progressDialog.show();
        }


    }

    private static final int STATE_CHANGED = 1;

    @SuppressLint("HandlerLeak")
    private final Handler mHandler = new Handler() {
        public void handleMessage(android.os.Message msg) {
            switch (msg.what) {
                case STATE_CHANGED:
                    int newState = msg.arg1;
                    handleStateChanged(newState);
                    break;
            }
        }
    };


    private void handleStateChanged(int newState) {
        // Handle the state change here
        if (newState == 3) {
            setStatus("Connected", Color.GREEN);
            progressDialog.dismiss();
            printAllStickers();
        } else {
            progressDialog.dismiss();
        }
    }

    private void setBluetoothListner() {
        BluetoothProfile.ServiceListener mProfileListener = new BluetoothProfile.ServiceListener() {
            public void onServiceConnected(int profile, BluetoothProfile proxy) {
                if (proxy.getConnectedDevices() != null) {
                    if (mChatService.getState() == 3) {
                        setStatus("Connected", Color.GREEN);
                    } else {
                        setStatus("Not Connected", Color.BLACK);
                    }
                }
            }

            public void onServiceDisconnected(int profile) {
                Toast.makeText(PrintLaunchActivity.this, "Disconnected", Toast.LENGTH_SHORT).show();
            }
        };
        mBluetoothAdapter.getProfileProxy(PrintLaunchActivity.this, mProfileListener, BluetoothProfile.HEADSET);
    }

    private final BroadcastReceiver mReceiver = new BroadcastReceiver() {
        @Override
        public void onReceive(Context context, Intent intent) {
            String action = intent.getAction();
            BluetoothDevice device = intent.getParcelableExtra(BluetoothDevice.EXTRA_DEVICE);

            if (BluetoothDevice.ACTION_FOUND.equals(action)) {
                //Device found
//                printAllEnable(false);
            } else if (BluetoothDevice.ACTION_ACL_CONNECTED.equals(action)) {
                //Device is now connected
                Toast.makeText(context, String.format("Device Connected to %s", device.getName()), Toast.LENGTH_SHORT).show();
                bluetooth_address = device.getAddress();
                bluetooth_name = device.getName();


            } else if (BluetoothAdapter.ACTION_DISCOVERY_FINISHED.equals(action)) {
                //Done searching
//                printAllEnable(false);
            } else if (BluetoothDevice.ACTION_ACL_DISCONNECT_REQUESTED.equals(action)) {
                //Device is about to disconnect
//                printAllEnable(false);
            } else if (BluetoothDevice.ACTION_ACL_DISCONNECTED.equals(action)) {
                //Device has disconnected
//                printAllEnable(false);
            }
        }
    };

    @Override
    protected void onPause() {
        super.onPause();

        // Show the action bar.
        getWindow().clearFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN);
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        // Inflate the menu; this adds items to the action bar if it is present.
//        getMenuInflater().inflate(R.menu.menu_main, menu);
        return true;
    }


    private void setStatus(final String statusMessage, final int color) {

//        statusField.setBackgroundColor(color);
        statusField.setText(statusMessage);
        statusField.setTextColor(color);

    }


    private void enableTestButton(final boolean enabled) {
        runOnUiThread(new Runnable() {
            public void run() {
                testButton.setEnabled(enabled);
            }
        });
    }


    private void toggleEditField(EditText editText, boolean set) {
        /*
         * Note: Disabled EditText fields may still get focus by some other means, and allow text input.
         *       See http://code.google.com/p/android/issues/detail?id=2771
         */
        editText.setEnabled(set);
        editText.setFocusable(set);
        editText.setFocusableInTouchMode(set);
    }

    private boolean isBluetoothSelected() {
        return btRadioButton.isChecked();
    }

    private String getMacAddressFieldText() {
        return macAddressEditText.getText().toString();
    }

    private String getTcpAddress() {
        return ipAddressEditText.getText().toString();
    }

    private String getTcpPortNumber() {
        return portNumberEditText.getText().toString();
    }

    @Override
    public void onActivityResult(int requestCode, int resultCode, @Nullable Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        String TAG = "DocketActivity";
        switch (requestCode) {
            case 1:
                if (resultCode == -1) {
                    printerMacAddress = Objects.requireNonNull(data.getExtras()).getString(DeviceListActivity.EXTRA_DEVICE_ADDRESS);
                    Log.e("TAG", "address_KKKK: " + printerMacAddress);
                    macAddressEditText.setText(printerMacAddress);
                    mChatService.connect(mBluetoothAdapter.getRemoteDevice(printerMacAddress));

                    enableTestButton(false);
                    setStatus("Connected", Color.GREEN);
                    testButton.setBackground(getResources().getDrawable(R.drawable.circular_background_gray));
                    testButton.setTextColor(Color.BLACK);

                    SettingsHelper.saveBluetoothAddress(PrintLaunchActivity.this, printerMacAddress);
                    progressDialog.show();

                    new Handler(Looper.getMainLooper()).postDelayed(new Runnable() {
                        @Override
                        public void run() {
//                            printAllStickers();

//                            doConnectionTest();
                        }
                    }, 1000);

                    return;
                }
                return;
            case 2:
                if (resultCode == -1) {
                    setupChat();
                    return;
                }
                Log.d(TAG, "BT not enabled");
                Toast.makeText(PrintLaunchActivity.this, "Bluetooth not enabled", Toast.LENGTH_SHORT).show();
                finish();
                return;
            default:
                try {
                    //  BluetoothSocket btsocket = DeviceList.getSocket();
                } catch (Exception e) {
                    e.printStackTrace();
                }

        }
    }

    private void printAllStickers() {
        String folderName = "my_images";
        ArrayList<Bitmap> bitmaps = ImageUtils.getBitmapsFromCacheFolder(PrintLaunchActivity.this, folderName);
        Log.e("TAG", "convertBase64ToBitmaps: " + bitmaps.size());
//        FlutterZebraPrint(PrintLaunchActivity.this, getMacAddressFieldText(), bitmaps);
        Log.e("TAG", "printAllStickers:set done " + DataPrint.size());
        for (int i = 0; i < DataPrint.size(); i++) {
            Log.e("TAG", "printAllStickers:set done KK " + DataPrint.get(i));
            startPrinting(DataPrint.get(i));
            //finish();
        }

        Log.e("TAG", "prnData:KKK " + prnData);
        String folderPath = getCacheDir().getAbsolutePath() + File.separator + "my_images";
        ImageUtils.deleteCacheFolder(folderPath);
    }


    public void FlutterZebraPrint(Context context, String bluetooth_address, ArrayList<Bitmap> bitMapList) {

        Activity activity = (Activity) context;
        new Handler().post(new Runnable() {


            @Override
            public void run() {
                if (!activity.isFinishing()) {

                    UIHelper helper = new UIHelper(activity);
                    final Bitmap[] bitmap = new Bitmap[0];
                    if (connection == null) {
                        connection = new BluetoothConnection(bluetooth_address);
                        enableTestButton(true);
                    }

                    // Looper.prepare();
                    try {
                        connection.open();
                        ZebraPrinter printer = ZebraPrinterFactory.getInstance(connection);
                        ZebraPrinterLinkOs linkOsPrinter = ZebraPrinterFactory.createLinkOsPrinter(printer);
                        PrinterStatus printerStatus = (linkOsPrinter != null) ? linkOsPrinter.getCurrentStatus() : printer.getCurrentStatus();
                        getPrinterStatus(PrintLaunchActivity.this);
                        if (printerStatus.isReadyToPrint) {

                            activity.runOnUiThread(new Runnable() {
                                @Override
                                public void run() {
                                    try {
                                        // Toast.makeText(context, "Printer Ready", Toast.LENGTH_LONG).show();
                                        BulkStickerPrint(context, connection, printer, helper, bitMapList);
                                        activity.runOnUiThread(() -> {

                                            progressDialog.dismiss();

                                        });

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
                        showButton();
                        Log.e("TAG", "ZebraPrint: ConnectionException " + e.getMessage());
                        helper.showErrorDialogOnGuiThread(e.getMessage());
                    } catch (ZebraPrinterLanguageUnknownException e) {
                        showButton();
                        Log.e("TAG", "ZebraPrint: LanguageUnknownException" + e.getMessage());
                        helper.showErrorDialogOnGuiThread(e.getMessage());
                    } catch (Exception e) {
                        showButton();
                        Log.e("TAG", "ZebraPrint:Exception " + e.getMessage());
                        helper.showErrorDialogOnGuiThread(e.getMessage());
                    } finally {
                        showButton();
                        helper.dismissLoadingDialog();
                    }
                }
            }
        });
    }

    public void showButton() {
        enableTestButton(true);
        setStatus("Status:Not Connected", Color.GRAY);
        testButton.setBackground(getResources().getDrawable(R.drawable.circular_background));
        testButton.setTextColor(Color.WHITE);
        progressDialog.dismiss();

    }

    public boolean BulkStickerPrint(Context context, Connection connection, ZebraPrinter printer, UIHelper helper, ArrayList<Bitmap> stickerImageList) {
        try {
            connection.open();

            // Convert sticker size from mm to inches
            double stickerWidthInInches = 3.94;//236 / 25.4; // 100 mm to inches
            double stickerHeightInInches = 2.83;//177 / 25.4; // 75 mm to inches

            stickerWidthInInches = 3.32;//236 / 25.4; // 100 mm to inches
            stickerHeightInInches = 2.71;//177 / 25.4; // 75 mm to inches


//            double stickerWidthInInches = 2.95;//236 / 25.4; // 100 mm to inches
//            double stickerHeightInInches = 2.25;//177 / 25.4; // 75 mm to inches

            // Assuming your Zebra printer has a DPI of 203 (change this value if your printer has a different DPI)
            int printerDpi = 203;
            int dpi = printer.getCurrentStatus().labelLengthInDots;
            Log.d("zzzzz============", "====:" + dpi);

            // Calculate the required image size in dots
            int imageWidthInDots = (int) (stickerWidthInInches * printerDpi);
            int imageHeightInDots = (int) (stickerHeightInInches * printerDpi);
            Log.d("zzzzz============", "===w : " + imageWidthInDots + " , h : " + imageHeightInDots);

            // Rotate the image if needed (use your desired rotation angle)
            Matrix matrix = new Matrix();
            matrix.postRotate(270);

            for (int i = 0; i < stickerImageList.size(); i++) {
                // Scale the sticker image to the required size
                Bitmap scaledStickerImage = Bitmap.createScaledBitmap(stickerImageList.get(i), imageWidthInDots, imageHeightInDots, false);


                Bitmap rotatedStickerImage = Bitmap.createBitmap(scaledStickerImage, 0, 0, imageWidthInDots, imageHeightInDots, matrix, true);

                //saveBitmapToCache(context,rotatedStickerImage);

                ZebraImageAndroid zebraImageAndroid = new ZebraImageAndroid(rotatedStickerImage);
                Log.d("zzzzz============", "w : " + zebraImageAndroid.getWidth() + " , h : " + zebraImageAndroid.getHeight());

                // printer.printImage(zebraImageAndroid, 50, 100, 50, -100, false);
                printer.printImage(zebraImageAndroid, -20, 100, 25, 0, false);
            }


            connection.write("! U1 JOURNAL\r\n! U1 SETFF 50 2\r\n".getBytes());
            connection.close();
            return true;
        } catch (ConnectionException e) {
            enableTestButton(true);
            setStatus("Not Connected", Color.GREEN);
            testButton.setBackground(getResources().getDrawable(R.drawable.circular_background));

            helper.showErrorDialogOnGuiThread(e.getMessage());
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    private void setupChat() {
        this.mChatService = new BluetoothChatServices(mHandler);
    }

    public void startPrinting(String printString) {
        mChatService.write(printString.getBytes());

    }


    public void getPrinterStatus(Context context) throws ConnectionException {

        Activity activity = (Activity) context;
        if (!activity.isFinishing()) {
            final String printerLanguage = SGD.GET("device.languages", connection); //This command is used to get the language of the printer.

            final String displayPrinterLanguage = "Printer Language is " + printerLanguage;

            SGD.SET("device.languages", "zpl", connection); //This command set the language of the printer to ZPL

            activity.runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    Toast.makeText(activity, displayPrinterLanguage + "\n" + "Language set to ZPL", Toast.LENGTH_LONG).show();
                }
            });
        }
    }

    @Override
    protected void onResume() {
        super.onResume();
        try {
           /* if(statusField.getText().toString().equals("Connected")){
                printAllStickers();
            }*/
        } catch (Exception e) {

        }
    }
}
