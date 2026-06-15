// ignore_for_file: prefer_interpolation_to_compose_strings
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue_classic/flutter_blue_classic.dart';
import 'package:get/get.dart';
import 'package:tms_newui/widgets/tms_button.dart';

// import 'package:flutter_blue/flutter_blue.dart';
import '../../model/dash_board_model/location_master.dart';
import '../../model/docket_model/docket.dart';
import '../home_page/dash_board_controller.dart';

enum DataStatus { loading, completed, error }

enum PrinterEnum { gcn, quickDocket }

class DocketController extends GetxController {
  DashBoardController ctrl = Get.find<DashBoardController>();
  String docketNumbers = Get.arguments ?? '';
  MethodChannel channel = MethodChannel("tms.com/method");
  Rx<DataStatus> dataStatus = DataStatus.loading.obs;
  Rx<FlutterBlueClassic> flutterBlueClassicPlugin = FlutterBlueClassic(usesFineLocation: true).obs;
  List<String> prnList = [];

  ///DocketDetail List
  RxList<DocketInfo> docketData = <DocketInfo>[].obs;

  @override
  void onInit() {
    getDocketData(docketNumbers: docketNumbers);
    update();
    super.onInit();
  }

  Future<bool> checkBluetoothStatus(BuildContext context) async {
    bool isOn = await flutterBlueClassicPlugin.value.isEnabled;
    return isOn;
  }

  Future<void> showBluetoothDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          title: Text(
            'Bluetooth turned off',
            style: TextStyle(),
          ),
          content: Text('Please enable Bluetooth to use this app.'),
          actions: <Widget>[
            TmsButton(
                text: "OK",
                onPressed: () {
                  Get.back();
                })
          ],
        );
      },
    );
  }

  /// list Store Docket Api data method

  Future<void> getDocketData({required String docketNumbers}) async {
    try {
      DocketDetail? docketDetail = await ctrl.docketApi(docketNumbers: docketNumbers);
      if (docketDetail!.data.isNotEmpty) {
        docketData(docketDetail.data);

        dataStatus(DataStatus.completed);
      } else {
        dataStatus(DataStatus.error);
      }
    } catch (err) {
      dataStatus(DataStatus.error);
    }
  }

  String getRelivrPrintData(argumentData, subIndex) {
    String pkgNo = "";
    int index = subIndex + 1;
    if (index.toString().length == 1) {
      pkgNo = "00" "${index}";
    } else if (index.toString().length == 2) {
      pkgNo = "0" "${index}";
    } else if (index.toString().length == 3) {
      pkgNo = "${index}";
    }

    return "SIZE 72.00 mm, 50.63 mm\n"
            "GAP 3 mm, 0 mm\n"
            "SET RIBBON OFF\n"
            "DIRECTION 0,0\n"
            "REFERENCE 0,0\n"
            "OFFSET 0 mm\n"
            "SET PEEL OFF\n" +
        "SET CUTTER OFF\n" +
        "SET PARTIAL_CUTTER OFF" +
        "SET TEAR ON\n" +
        "CLS\n" +
        "BARCODE 22,400,\"128M\",64,0,270,2,6,\"P${argumentData.dockno + pkgNo}\"\n" +
        "CODEPAGE 1252\n" +
        "TEXT 95,250,\"0\",270,08,08,\"P${argumentData.dockno + pkgNo}\"\n" +
        "BARCODE 130,265,\"128M\",64,0,0,2,6,\"P${argumentData.dockno + pkgNo}\"\n" +
        "TEXT 248,361,\"0\",0,10,10,\"P${argumentData.dockno + pkgNo}\"\n" +
        "BARCODE 120,25,\"128M\",64,0,0,3,6,\"${argumentData.dockno}\"\n" +
        "TEXT 248,95,\"0\",0,10,10,\"${argumentData.dockno}\"\n" +
        "TEXT 165,167,\"0\",0,8,8,\"${argumentData.orgncd}\"\n" +
        "TEXT 406,167,\"0\",0,8,8,\"${argumentData.reassigNDestcd}\"\n" +
        "TEXT 330,230,\"0\",0,8,8,\"${index}/${argumentData.pkgsno.toInt()}\"\n" +
        "PRINT 1,1\n";
  }

  String shortenString(String input, int maxLength) {
    if (input.length <= maxLength) {
      return input;
    } else {
      return input.substring(0, maxLength - 2) + "..";
    }
  }

  Future<dynamic> printImageByMethodChannel({required Map<String, dynamic> arg}) async {
    await channel
        .invokeListMethod("launchZebra", arg)
        .then((value) => print(" heloooooooo" + value!.toList().toString() + " heloooooooo"));
  }

  location(String city) {
    if (ctrl.location.isNotEmpty) {
      List<LocationList> locationList = ctrl.location;
      LocationList selectedValue =
          locationList.where((innerValue) => innerValue.locCode.contains(city)).first;

      String cityFullName = selectedValue.locName;

      return cityFullName;
    } else {
      return city;
    }
  }
}
