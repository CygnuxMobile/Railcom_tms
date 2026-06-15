import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Response;
import 'package:get/get.dart';
import 'package:tms_newui/moduls/manifest_page/manifest_controller.dart';
import 'package:tms_newui/utils/tmsapi_method.dart';

import '../../app_routes.dart';
import '../../model/dash_board_model/location_master.dart';
import '../../model/docket_model/docket.dart';
import '../../model/docket_model/docket_credential.dart';
import '../../utils/logging.dart';
import '../../utils/pref.dart';
import '../../utils/tmsapp_api.dart';

class DashBoardController extends GetxController {
  RxList<LocationList> location = <LocationList>[].obs;
  TextEditingController docketNumber = TextEditingController();
  TextEditingController thcNumber = TextEditingController();
  TextEditingController podNumber = TextEditingController();
  TextEditingController trackingNumber = TextEditingController();
  ManifestController manifestController = Get.put(ManifestController());
  final log = logger;

  @override
  void onInit() async {
    await locationMasterDataApi();
    if (!(Pref().getBranchCode() == 'HQTR')) {
      Pref().saveBaseLocation(val: Pref().getBranchCode());
    }
    super.onInit();
  }


  Future<void> getLocationCode(String value) async {
    String locationName = value;
    String locationCode = locationName.split("-")[0].replaceAll(" ", '');

    await Pref().saveBaseLocation(val: locationCode);
    location.refresh();
  }



  /// location master data
  Future<void> locationMasterDataApi() async {
    try {
      final dio.Response response =
          await WebService.tmsGetRequest(ApiService.getLocationMasterData);
      if (response.statusCode == 200) {
        dynamic responseData = response.data;
        GetLocationMasterData getLocationMasterData =
            await getLocationMasterDataFromJson(responseData);
        location.value = getLocationMasterData.data;
      } else {
        if (response.statusCode == 401) {
          // tokenExpire();
        } else {
          print('${response.statusCode} : ${response.data.toString()}');
        }
      }
    } catch (error) {
      print(error);
    }
  }

  /// docket detail
  Future<DocketDetail?> docketApi({required String docketNumbers}) async {
    final dio.Response response = await WebService.tmsPostRequest(
      url: ApiService.getBarCodePrintByGCN,
      body: docketNoToJson(
        DocketNo(
          dockno: docketNumbers.isEmpty ? docketNumber.text : docketNumbers,
        ),
      ),
    );
    try {
      return docketDetailFromJson(response.data);
    } catch (err) {
      print(err);
      return null;
    }
  }

  ///log out
  logoutDialog() {
    Get.defaultDialog(
      onCancel: () {
        Get.back();
      },
      onConfirm: () async {
        Future.delayed(const Duration(seconds: 0), () async {
          await Pref().logout();
          Get.offAllNamed(AppRoutes.loginScreen);
        });
      },
      title: "LogOut",
      middleText: "Are you sure you want to logout.?",
      backgroundColor: Colors.black,
      titleStyle: const TextStyle(color: Colors.white),
      middleTextStyle: const TextStyle(color: Colors.white),
    );
  }
}
