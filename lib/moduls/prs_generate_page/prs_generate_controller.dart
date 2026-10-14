import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../model/drs_model/drs_generate/vendor_type_model.dart';
import '../../model/drs_model/drs_generate/vendor_list_model.dart';
import '../../model/drs_model/drs_generate/vehicle_list_model.dart';
import '../../model/drs_model/drs_generate/vehicle_details_model.dart';
import '../../model/drs_model/drs_generate/driver_list_model.dart';
import '../../model/drs_model/drs_generate/driver_details_model.dart';
import '../../model/drs_model/drs_generate/available_docket_model.dart';
import '../../model/drs_model/drs_generate/prepare_drs_model.dart';
import '../../model/drs_model/update_part_b_response.dart';
import '../../model/drs_model/generate_consolidated_response.dart';
import '../../utils/pref.dart';
import '../../utils/tmsapi_method.dart';
import '../../utils/tmsapp_api.dart';
import '../../widgets/tost.dart';
import '../../widgets/submit_alert_dialog.dart';
import '../../widgets/custom_loader.dart';
import '../../widgets/tms_button.dart';
import '../../widgets/tms_richtext.dart';

class PRSGenerateController extends GetxController {
  final formKey = GlobalKey<FormState>();
  AppLoader appLoader = AppLoader();

  // Text Controllers
  final manualPrsNoController = TextEditingController();
  final prsDateController = TextEditingController(text: DateFormat('dd MMM yyyy').format(DateTime.now()));
  final mobileNoController = TextEditingController();
  final driverNameController = TextEditingController();
  final loadingSupervisorController = TextEditingController();
  final manualVendorNameController = TextEditingController();
  final manualVehicleNoController = TextEditingController();
  final panNoController = TextEditingController();
  final startKmController = TextEditingController();
  final endKmController = TextEditingController();
  final cnoteNoController = TextEditingController();
  var vehicleNoDigit = 10.obs;

  // Observable Data Lists
  var vendorTypeList = <VendorTypeItem>[].obs;
  var vendorList = <VendorItem>[].obs;
  var vehicleList = <VehicleItem>[].obs;
  var driverList = <DriverListItem>[].obs;
  var availableDockets = <AvailableDocketItem>[].obs;
  var selectedDockets = <AvailableDocketItem>[].obs;

  // Observable Loading States for Dropdowns
  var isLoadingVendorTypes = false.obs;
  var isLoadingVendors = false.obs;
  var isLoadingVehicles = false.obs;
  var isLoadingVehicleDetails = false.obs;
  var isLoadingDrivers = false.obs;
  var isLoadingDriverDetails = false.obs;
  var isLoadingAvailableDockets = false.obs;

  // Selected Values
  var selectedVendorType = Rxn<VendorTypeItem>();
  var selectedVendor = Rxn<VendorItem>();
  var selectedVehicle = Rxn<VehicleItem>();
  var selectedDriver = Rxn<DriverListItem>();

  // Vehicle & Driver Details
  var vehicleDetails = Rxn<VehicleDetailItem>();
  var driverDetails = Rxn<DriverDetailsData>();

  @override
  void onInit() {
    super.onInit();
    loadingSupervisorController.text = Pref().getUserId();
    fetchVendorTypes();
  }

  Future<void> fetchVendorTypes() async {
    isLoadingVendorTypes.value = true;
    try {
      var response = await WebService.tmsPostRequest(
        url: ApiService.getVendorType,
        body: jsonEncode({"routeMode": "M", "moduleID": "4"}),
      );
      if (response.statusCode == 200) {
        var res = vendorTypeResponseFromJson(response.data);
        vendorTypeList.assignAll(res.data.venders);
      }
    } catch (e) {
      WebService.logger.e("Error fetching vendor types: $e");
    } finally {
      isLoadingVendorTypes.value = false;
    }
  }

  Future<void> fetchVendors(String vendorTypeCode) async {
    isLoadingVendors.value = true;
    try {
      var response = await WebService.tmsPostRequest(
        url: ApiService.getVendorsFromVendorType,
        body: jsonEncode({
          "vendor_Type": vendorTypeCode,
          "location": Pref().getBaseLocation(),
          "username": Pref().getUserId(),
          "documentType": "2"
        }),
      );
      if (response.statusCode == 200) {
        var res = vendorListResponseFromJson(response.data);
        vendorList.assignAll(res.data.venderscodes);
      }
    } catch (e) {
      WebService.logger.e("Error fetching vendors: $e");
    } finally {
      isLoadingVendors.value = false;
    }
  }

  Future<void> fetchVehicles(String vendorCode, String vendorTypeCode) async {
    isLoadingVehicles.value = true;
    try {
      var response = await WebService.tmsPostRequest(
        url: ApiService.getVehicleFromVendor,
        body: jsonEncode({
          "vendor_Type": vendorCode,
          "vendor_Type_Code": vendorTypeCode
        }),
      );
      if (response.statusCode == 200) {
        var res = vehicleListResponseFromJson(response.data);
        vehicleList.assignAll(res.data.mvLists);
      }
    } catch (e) {
      WebService.logger.e("Error fetching vehicles: $e");
    } finally {
      isLoadingVehicles.value = false;
    }
  }

  Future<void> fetchVehicleDetails(String vehicleNo) async {
    isLoadingVehicleDetails.value = true;
    try {
      var response = await WebService.tmsPostRequest(
        url: ApiService.getVehicleDetails,
        body: jsonEncode({"vehicleNo": vehicleNo}),
      );
      if (response.statusCode == 200) {
        var res = vehicleDetailsResponseFromJson(response.data);
        if (res.data.getVehicle.isNotEmpty) {
          vehicleDetails.value = res.data.getVehicle.first;
          if (startKmController.text.isEmpty || startKmController.text == "0") {
            startKmController.text = res.data.getVehicle.first.startKM.toString();
          }
        }
      }
    } catch (e) {
      WebService.logger.e("Error fetching vehicle details: $e");
    } finally {
      isLoadingVehicleDetails.value = false;
    }
  }

  Future<void> fetchDrivers(String prefix) async {
    isLoadingDrivers.value = true;
    try {
      var response = await WebService.tmsPostRequest(
        url: "${ApiService.getDriverList}?Prefix=$prefix",
        body: "",
      );
      if (response.statusCode == 200) {
        var res = driverListResponseFromJson(response.data);
        driverList.assignAll(res.data);
      }
    } catch (e) {
      WebService.logger.e("Error fetching drivers: $e");
    } finally {
      isLoadingDrivers.value = false;
    }
  }

  Future<void> fetchDriverDetails(String driverName) async {
    isLoadingDriverDetails.value = true;
    try {
      var response = await WebService.tmsPostRequest(
        url: "${ApiService.getDriverDetails}?DriverName=$driverName",
        body: "",
      );
      if (response.statusCode == 200) {
        var res = driverDetailsResponseFromJson(response.data);
        driverDetails.value = res.data;
        mobileNoController.text = res.data.mobileno;
        driverNameController.text = res.data.driver_Name;
      }
    } catch (e) {
      WebService.logger.e("Error fetching driver details: $e");
    } finally {
      isLoadingDriverDetails.value = false;
    }
  }

  Future<void> fetchAvailableDockets() async {
    isLoadingAvailableDockets.value = true;
    try {
      var body = jsonEncode({
        "fromdt": DateFormat('d MMM yyyy').format(DateTime.now().subtract(const Duration(days: 30))),
        "todt": DateFormat('d MMM yyyy').format(DateTime.now()),
        "dttyp": "1",
        "paybas": "All",
        "trn": "All",
        "bustyp": "All",
        "status": "P",
        "doctyp": "PRS",
        "baseLocationCode": Pref().getBaseLocation(),
        "docketList": "",
        "alloted_To": "All",
        "loadingBy": "",
        "chrgType": "",
        "baseCompanyCode": Pref().getCompanyCode()
      });
      WebService.logger.i("Fetching Available PRS Dockets with body: $body");

      var response = await WebService.tmsPostRequest(
        url: ApiService.avalabledocketinPRSDRS,
        body: body,
      );
      if (response.statusCode == 200) {
        WebService.logger.d("Available PRS Dockets Response: ${response.data}");
        var res = availableDocketResponseFromJson(response.data);
        availableDockets.assignAll(res.data);
      }
    } catch (e) {
      WebService.logger.e("Error fetching available dockets", error: e);
    } finally {
      isLoadingAvailableDockets.value = false;
    }
  }

  var isLoadingSubmit = false.obs;

  Future<void> submitPRS() async {
    if (!(formKey.currentState?.validate() ?? false)) {
      return;
    }

    if (selectedDockets.isEmpty) {
      TmsToast.msg("Please select at least one docket");
      return;
    }

    if (selectedVendorType.value == null) {
      TmsToast.msg("Please select vendor type");
      return;
    }

    if (selectedVendor.value == null) {
      TmsToast.msg("Please select a vendor");
      return;
    }

    var isMarket = selectedVendorType.value?.vendorType_Code == "XX";

    isLoadingSubmit.value = true;
    try {
      DateTime selectedDate = DateFormat('dd MMM yyyy').parse(prsDateController.text);
      DateTime now = DateTime.now();
      DateTime prsDateTime = DateTime(selectedDate.year, selectedDate.month, selectedDate.day, now.hour, now.minute, now.second);
      String apiFormattedDate = "${DateFormat('yyyy-MM-ddTHH:mm:ss.SSS').format(prsDateTime)}Z";

      String getBaseYearValFirst() {
        String finYear = Pref().getFinYear().trim();
        if (finYear.length >= 4 && finYear.startsWith("20")) {
          return finYear.substring(2, 4);
        } else if (finYear.length >= 2) {
          return finYear.substring(0, 2);
        }
        return DateTime.now().year.toString().substring(2);
      }

      var request = PRSDRSSubmitRequest(
        vendorType: selectedVendorType.value?.vendorType_Code ?? "",
        vendor: selectedVendor.value?.vendor_Code ?? (isMarket ? "8888" : ""),
        vendorName: selectedVendor.value?.vendor_Name ?? manualVendorNameController.text.trim(),
        vendorGDNo: manualPrsNoController.text.trim(),
        vehicleNo: isMarket ? manualVehicleNoController.text.trim() : (selectedVehicle.value?.vehno ?? manualVehicleNoController.text.trim()),
        driverName: driverNameController.text.trim(),
        contractAmount: selectedDockets.fold<double>(0.0, (sum, item) => sum + item.contractAmount),
        baseLocationCode: Pref().getBaseLocation(),
        baseCompanyCode: Pref().getCompanyCode(),
        baseYearValFirst: Pref().getFinYear(),
        baseUserName: Pref().getUserId(),
        type: "PRS",
        moduleType: "PRS",
        billingScheduleId: "",
        billingScheduleName: "",
        paymentType: "",
        dockdet: selectedDockets.map((d) => DockDetItem(
          id: 0,
          dockno: d.dockno,
          docksf: d.docksf,
          docketMode: d.docket_Mode,
          bkgDate: d.bkg_Date,
          arrivalDate: "",
          commitedDelyDate: d.commited_Dely_Date,
          orgncd: d.orgncd,
          desTCd: d.desT_CD,
          currLoc: d.curr_Loc,
          pendPkgQty: d.pendPkgQty,
          arrPkgQty: d.arrPkgQty,
          pkgsno: d.pkgsno,
          payBas: d.payBas,
          paybaSStr: d.paybaS_Str,
          atad: apiFormattedDate,
          cdeldt: d.cdeldt.isNotEmpty ? d.cdeldt : apiFormattedDate,
          businesstype: d.businesstype,
          trNMOD: d.trN_MOD,
          actuwt: d.actuwt,
          arrWeightQty: d.arrWeightQty,
          chrgwt: d.chrgwt,
          freight: 0.0,
          dkttot: 1.0,
          handlingchrg: 0.0,
          svctax: d.svctax,
          cnd: d.cnd,
          staffBA: d.staff_BA?.toString() ?? "",
          isEnabled: true,
          rate: 0.0,
          maxLimit: 0.0,
          newRate: 0.0,
          ratetype: "",
          cnt: d.cnt,
          message: d.message,
          eWayBillNo: d.eWayBillNo,
          vendorChargebleWeight: 0.0,
          vendorGDNo: manualPrsNoController.text.trim(),
        )).toList(),
      );

      String requestJson = prsDrsSubmitRequestToJson(request);

      try {
        JsonEncoder encoder = const JsonEncoder.withIndent('  ');
        String prettyJson = encoder.convert(jsonDecode(requestJson));
        print("==================== [PRS SUBMIT API REQUEST] ====================");
        print("URL: ${ApiService.preparePRS}");
        print("REQUEST BODY:\n$prettyJson");
        print("==================================================================");
      } catch (_) {
        print("==================== [PRS SUBMIT API REQUEST] ====================");
        print("URL: ${ApiService.preparePRS}");
        print("REQUEST BODY: $requestJson");
        print("==================================================================");
      }
      WebService.logger.i("Submitting PRS to ${ApiService.preparePRS} with body: $requestJson");


      var response = await WebService.tmsPostRequest(
        url: ApiService.preparePRS,
        body: requestJson,
      );

      print("==================== [PRS SUBMIT API RESPONSE] ====================");
      print("STATUS CODE: ${response.statusCode}");
      print("RESPONSE DATA: ${response.data}");
      print("===================================================================");

      if (response.statusCode == 200) {
        WebService.logger.d("Submit PRS Response: ${response.data}");
        var resData = jsonDecode(response.data);
        bool isSuccess = resData['status'] == 1 ||
            resData['status'] == "1" ||
            resData['status'] == 200 ||
            resData['status'] == "200";

        if (isSuccess) {
          String prsNo = resData['pdcno'] ?? resData['data'] ?? "";
          TmsAlertDialog(
            context: Get.context!,
            title: "PRS Prepared Successfully",
            description: "PRS No: $prsNo",
            onTapText: "OK",
            buttonSize: const Size(100, 40),
            isShowImage: true,
            isPartBShow: resData['isPartBVisible'] == "Y" || resData['isPartBVisible'] == "true",
            partBTap: () {
              updatePartBApi(context: Get.context!, docNo: prsNo);
            },
            onPressed: () {
              Get.back(); // close dialog
              Get.back(); // go back to previous screen
            },
          );
        } else {
          String errorMsg = resData['message'] ?? "Failed to prepare PRS";
          WebService.logger.e("Prepare PRS Error: $errorMsg");
          TmsToast.msg(errorMsg);
        }
      } else {
        print("==================== [PRS SUBMIT SERVER ERROR] ====================");
        print("STATUS CODE: ${response.statusCode}");
        print("STATUS MESSAGE: ${response.statusMessage}");
        print("RESPONSE DATA: ${response.data}");
        print("===================================================================");
        WebService.logger.e("Server Error: ${response.statusCode}");
        TmsToast.msg("Server Error: ${response.statusCode}");
      }
      TmsToast.msg("Request logged to console (API call commented)");
    } catch (e) {
      print("==================== [PRS SUBMIT EXCEPTION] ====================");
      print("ERROR: $e");
      print("================================================================");
      WebService.logger.e("Error preparing PRS", error: e);
      TmsToast.msg("Error preparing PRS: $e");
    } finally {
      isLoadingSubmit.value = false;
    }
  }

  void toggleDocketSelection(AvailableDocketItem docket) {
    if (selectedDockets.contains(docket)) {
      selectedDockets.remove(docket);
    } else {
      selectedDockets.add(docket);
    }
  }

  var isLoadingAddCnote = false.obs;

  Future<void> addCnoteManual() async {
    String cnote = cnoteNoController.text.trim();
    if (cnote.isEmpty) {
      TmsToast.msg("Please enter Cnote No");
      return;
    }

    isLoadingAddCnote.value = true;
    try {
      var body = jsonEncode({
        "fromdt": "1 Jan 1990",
        "todt": DateFormat('d MMM yyyy').format(DateTime.now()),
        "dttyp": "1",
        "paybas": "All",
        "trn": "All",
        "bustyp": "All",
        "status": "P",
        "doctyp": "PRS",
        "baseLocationCode": Pref().getBaseLocation(),
        "docketList": cnote,
        "alloted_To": "All",
        "loadingBy": "",
        "chrgType": "",
        "baseCompanyCode": Pref().getCompanyCode()
      });
      WebService.logger.i("Adding PRS Cnote Manual with body: $body");

      var response = await WebService.tmsPostRequest(
        url: ApiService.avalabledocketinPRSDRS,
        body: body,
      );
      if (response.statusCode == 200) {
        WebService.logger.d("Add Cnote Response: ${response.data}");
        var res = availableDocketResponseFromJson(response.data);
        if (res.data.isNotEmpty) {
          var docket = res.data.first;
          if (!selectedDockets.any((element) => element.dockno == docket.dockno)) {
            selectedDockets.add(docket);
            cnoteNoController.clear();
            TmsToast.msg("Cnote added successfully");
          } else {
            TmsToast.msg("Cnote already added");
          }
        } else {
          TmsToast.msg("Cnote not found or not available");
        }
      } else {
        WebService.logger.e("Server Error while adding Cnote: ${response.statusCode}");
        TmsToast.msg("Server Error: ${response.statusCode}");
      }
    } catch (e) {
      WebService.logger.e("Error adding Cnote", error: e);
      TmsToast.msg("Error adding Cnote: $e");
    } finally {
      isLoadingAddCnote.value = false;
    }
  }

  Future<void> updatePartBApi({required BuildContext context, required String docNo}) async {
    appLoader.show();
    final encodedDocNo = docNo.contains('%') ? docNo : Uri.encodeComponent(docNo);
    final url = "${ApiService.updatePartB}?DocNo=$encodedDocNo";
    try {
      print("==================== [UPDATE PART B API REQUEST] ====================");
      print("URL: $url");
      print("=====================================================================");
      WebService.logger.i("Updating Part B with url: $url");
      final response = await WebService.tmsPostRequest(url: url, body: "");
      appLoader.hide();
      print("==================== [UPDATE PART B API RESPONSE] ===================");
      print("STATUS CODE: ${response.statusCode}");
      print("RESPONSE DATA: ${response.data}");
      print("=====================================================================");
      if (response.statusCode == 200) {
        List<UpdatePartBResponse> resList = updatePartBResponseFromJson(response.data);
        if (resList.isNotEmpty) {
          showPartBDetailsDialog(context, resList, docNo);
        } else {
          TmsToast.msg("No ewaybill found in this document");
        }
      } else {
        TmsToast.msg("Part B Error: ${response.statusMessage}");
      }
    } catch (e) {
      appLoader.hide();
      WebService.logger.e("Error updating Part B: $e");
      TmsToast.msg("Error updating Part B: $e");
    }
  }

  void showPartBDetailsDialog(BuildContext context, List<UpdatePartBResponse> details, String docNo) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(15),
              decoration: const BoxDecoration(
                color: Color(0xff232F34),
                borderRadius: BorderRadius.only(topLeft: Radius.circular(15), topRight: Radius.circular(15)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Part B Details", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  InkWell(onTap: () => Get.back(), child: const Icon(Icons.close, color: Colors.white)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxHeight: Get.height * 0.4),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: details.length,
                        itemBuilder: (context, index) {
                          final item = details[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.grey.withOpacity(0.3)),
                              boxShadow: [
                                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5, offset: const Offset(0, 2))
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TmsRichText(
                                  text: "EWayBill: ",
                                  richText: item.ewayBillNo,
                                  color: const Color(0xff232F34),
                                  fontWeight: FontWeight.bold,
                                ),
                                const SizedBox(height: 4),
                                TmsRichText(text: "Vehicle: ", richText: item.vehicleNo, color: Colors.grey),
                                TmsRichText(
                                  text: "Status: ",
                                  richText: item.statusCode.isNotEmpty ? "${item.statusCode} (${item.errorMsg})" : item.errorMsg,
                                  color: (item.statusCode.toLowerCase() == "success" || item.errorMsg.toLowerCase() == "done")
                                      ? Colors.green
                                      : Colors.red,
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  TmsButton(
                    text: "Generate Consolidated",
                    size: const Size(double.infinity, 45),
                    onPressed: () {
                      Get.back();
                      generateConsolidatedEWayBillsApi(context: context, docNo: docNo);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> generateConsolidatedEWayBillsApi({required BuildContext context, required String docNo}) async {
    appLoader.show();
    final url = "${ApiService.generateConsolidatedEWayBills}?DocNo=$docNo&BaseCompanyCode=${Pref().getCompanyCode()}";
    try {
      final response = await WebService.tmsPostRequest(url: url, body: "");
      appLoader.hide();
      if (response.statusCode == 200) {
        GenerateConsolidatedResponse res = generateConsolidatedResponseFromJson(response.data);
        if (res.status == 200) {
          TmsToast.msg("Done partB");
          showConsolidatedDialog(context, res);
        } else {
          TmsToast.msg(res.message);
        }
      } else {
        TmsToast.msg("Consolidated Error: ${response.statusMessage}");
      }
    } catch (e) {
      appLoader.hide();
      TmsToast.msg("Error generating consolidated EWay Bills");
    }
  }

  void showConsolidatedDialog(BuildContext context, GenerateConsolidatedResponse res) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(15),
              decoration: const BoxDecoration(
                color: Color(0xff232F34),
                borderRadius: BorderRadius.only(topLeft: Radius.circular(15), topRight: Radius.circular(15)),
              ),
              child: const Center(
                child: Text("Consolidated EWay Bills", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  HugeIcon(icon: HugeIcons.strokeRoundedCheckmarkCircle01, color: Colors.green, size: 50),
                  const SizedBox(height: 15),
                  const Text("Done partB", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 20),
                  if (res.data.groups.isNotEmpty) ...{
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: [
                          TmsRichText(text: "Consolidated No: ", richText: res.data.groups[0].cEwaybillNo, color: const Color(0xff232F34)),
                          const SizedBox(height: 5),
                          TmsRichText(text: "Valid Upto: ", richText: res.data.groups[0].cEwaybillVldt, color: Colors.grey, fontSize1: 12),
                        ],
                      ),
                    ),
                    const SizedBox(height: 15),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text("EWay Bills included:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    ),
                    const SizedBox(height: 8),
                    ...res.data.groups[0].ewayBillNumbers.map((no) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle_outline, size: 16, color: Colors.green),
                          const SizedBox(width: 8),
                          Text(no, style: const TextStyle(fontSize: 13)),
                        ],
                      ),
                    )).toList(),
                  },
                  const SizedBox(height: 25),
                  TmsButton(
                    text: "OK",
                    size: const Size(double.infinity, 45),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
