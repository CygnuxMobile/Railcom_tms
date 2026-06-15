import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tms_newui/environments%20.dart';
import 'package:tms_newui/utils/connection_handler.dart';
import 'package:tms_newui/utils/podDb/poddb_handler.dart';
import 'package:tms_newui/utils/pref.dart';

import 'get_page.dart';

late PodDb podDb;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await Pref().init();
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
  FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
  podDb = await PodDb.create();
  ConnectionService().initialize();

  /// this line can change app build flavor
  await requestPermissions();
  AppEnvironments.setupEvm(Environments.relicom);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: ScreenUtilInit(
        designSize: const Size(412, 732),
        builder: (BuildContext context, Widget? child) {
          return GetMaterialApp(
            color: context.theme.colorScheme.background,
            debugShowCheckedModeBanner: false,
            builder: EasyLoading.init(),
            getPages: getPages,
          );
        },
      ),
    );
  }
}

Future<void> requestPermissions() async {
  Map<Permission, PermissionStatus> status = await [
    Permission.bluetooth,
    Permission.bluetoothAdvertise,
    Permission.bluetoothConnect,
    Permission.bluetoothScan,
    Permission.location,
  ].request();

  status.forEach((key, value) {
    if (value != PermissionStatus.granted || value == PermissionStatus.limited) {
      Fluttertoast.showToast(
          msg: "Permission not granted",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
      // requestPermissions();
    }
  });
}
