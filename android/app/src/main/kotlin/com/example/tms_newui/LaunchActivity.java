package com.example.tms_newui;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.os.Bundle;
import android.os.Handler;
import android.util.Base64;
import android.util.Log;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

//import com.google.gson.Gson;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.ByteArrayOutputStream;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodChannel;

public class LaunchActivity extends FlutterActivity implements ActivityAware{

    private static final String CHANNEL = "tms.com/method";

    private EventChannel.EventSink attachEvent;
    private MethodChannel methodChannel;

    BinaryMessenger getBinaryMessenger() {
        return Objects.requireNonNull(getFlutterEngine()).getDartExecutor().getBinaryMessenger();
    }

    private final BroadcastReceiver receiver = new BroadcastReceiver() {
        @Override
        public void onReceive(Context context, Intent intent) {

        }
    };


    @Override
    protected void onDestroy() {
        super.onDestroy();
    }

    private final BroadcastReceiver alarmReceiver = new BroadcastReceiver() {
        @Override
        public void onReceive(Context context, Intent intent) {

        }
    };

    public static String convertBitmapToBase64(Bitmap bitmap) {
        ByteArrayOutputStream baos = new ByteArrayOutputStream();
        bitmap.compress(Bitmap.CompressFormat.JPEG, 100, baos);
        byte[] encodedBytes = baos.toByteArray();
        return Base64.encodeToString(encodedBytes, Base64.DEFAULT);
    }

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        methodChannel = new MethodChannel(getBinaryMessenger(), CHANNEL);
        methodChannel.setMethodCallHandler(
                (call, result) -> {
                    switch (call.method) {
                        case "sayHello":
                            List<String> Data = (List<String>) call.arguments;
                            String a = hello(Data);
                            result.success(a);
                            break;
                        case "bluetooth":

                            break;
                        case "launchZebra":


                            Log.i("Fluter", "onCreate: ---------TEST LEVEL 2--------- " + call.arguments.getClass());

                            Map<String, ArrayList<String>> map = (Map<String, ArrayList<String>>) call.arguments;

                            System.out.println("The Value is: " + map.get("printDataList"));

                            Intent intent = new Intent(this, PrintLaunchActivity.class).putStringArrayListExtra(PrintLaunchActivity.ACK_PRINT, map.get("printDataList"));
                            startActivity(intent);
                            Log.e("AAVYU", "onCreate: ---------TEST LEVEL 2--------- ");
                            try {


                            } catch (Exception e) {
                                Log.e("AAVYU", "onCreate: ---------" + e.toString() + "--------- ");
                            }

                            Log.e("AAVYU", "onCreate: ---------TEST LEVEL 3--------- ");
                            break;
                    }

                }
        );

    }

    public String hello(List<String> arg) {
        System.out.print(arg);
        return arg.toString();
    }

    //    private void printAllStickers() {
//        HomeActivity homeActivity = (HomeActivity) getActivity();
//        convertBase64ToBitmaps(homeActivity.getImagesForPrint());
//    }
    private Bitmap convertBase64ToBitmap(String base64String) {
        byte[] decodedBytes = Base64.decode(base64String, Base64.DEFAULT);
        return BitmapFactory.decodeByteArray(decodedBytes, 0, decodedBytes.length);
    }


    @Override
    public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
    }

    @Override
    public void onDetachedFromActivityForConfigChanges() {

    }

    @Override
    public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {

    }

    @Override
    public void onDetachedFromActivity() {

    }
}
