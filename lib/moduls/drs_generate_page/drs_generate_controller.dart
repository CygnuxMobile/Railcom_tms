import 'dart:convert';

import 'package:get/get.dart';
import 'package:tms_newui/model/drs_generate_model/drs_generate_list_model.dart';
import 'package:tms_newui/utils/tmsapi_method.dart';
import 'package:tms_newui/utils/tmsapp_api.dart';
import 'package:tms_newui/widgets/tost.dart';

import '../../utils/pref.dart';
import '../../widgets/custom_loader.dart';

class DrsGenerateController extends GetxController {
  RxList<DrsGenerateResponse> drsGenerateList = <DrsGenerateResponse>[].obs;

  Future<void> drsGenerateListApi() async {
    try {
      final requestBody = {
        "baseLocationCode": Pref().getBaseLocation(),
        "dockdatefrom": "2024-01-01",
        "dockdateto": "2026-01-01",
        "docketlist": "",
        "baseCompanyCode": Pref().getCompanyCode(),
        "type": "DRS",
      };

      final response = await WebService.tmsPostRequest(
        url: ApiService.GetListForPRSDRS,
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        drsGenerateList.value = drsGenerateResponseFromJson(response.data);
      } else {
        TmsToast.msg("msg");
      }
    } catch (e) {
      AppLoader().hide();
      print("Error in drsGenerateListApi: $e");
      TmsToast.msg("msg");
    }
  }
}
