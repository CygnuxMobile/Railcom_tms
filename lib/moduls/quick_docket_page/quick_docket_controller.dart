import 'dart:convert';

import 'package:dio/dio.dart' as dio;
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:tms_newui/app_routes.dart';
import 'package:tms_newui/model/quick_docket_model/billing_response.dart';
import 'package:tms_newui/model/quick_docket_model/custList_response.dart';
import 'package:tms_newui/model/quick_docket_model/eway_bill_response.dart';
import 'package:tms_newui/model/quick_docket_model/picode.dart';
import 'package:tms_newui/model/quick_docket_model/product.dart';
import 'package:tms_newui/model/quick_docket_model/quick_docket_submit_models/quick_docket_request.dart';
import 'package:tms_newui/model/quick_docket_model/transport_response.dart';
import 'package:tms_newui/moduls/docket_page/docket_controller.dart';
import 'package:tms_newui/moduls/quick_docket_page/quick_docket_screen.dart';
import 'package:tms_newui/utils/logging.dart';
import 'package:tms_newui/utils/pref.dart';
import 'package:tms_newui/utils/tmsapp_api.dart';

import '../../model/dash_board_model/location_master.dart';
import '../../model/drs_model/general_master_response.dart';
import '../../model/quick_docket_model/address.dart';
import '../../model/quick_docket_model/city.dart';
import '../../model/quick_docket_model/city_type.dart';
import '../../model/quick_docket_model/packageType.dart';
import '../../model/quick_docket_model/quick_docket_submit_models/quick_docket_response.dart';
import '../../utils/tmsapi_method.dart';
import '../../widgets/custom_loader.dart';
import '../../widgets/submit_alert_dialog.dart';
import '../../widgets/tost.dart';

enum eWayBillScan { none, first, multiple }

enum docketCheck { none, right, wrong }

class QuickDocketController extends GetxController {
  final log = logger;

  List GeneralMasterTypeList = ["PAYTYP", "TRN"];

  RxList<BillingTypeList> payBasList = <BillingTypeList>[].obs;

  // RxList<BillingTypeList> transportModelList = <BillingTypeList>[].obs;
  RxList<TransportDatum> transportModelList = <TransportDatum>[].obs;
  Rx<eWayBill> eWayBillStatus = eWayBill.none.obs;

  // RxList<TransitMode> transitModeList = <TransitMode>[].obs;
  RxList<CustList> customerList = <CustList>[].obs;
  RxList<CustList> consigneeList = <CustList>[].obs;
  RxList<LocationList> location = <LocationList>[].obs;
  RxList<ProductObject> productList = <ProductObject>[].obs;
  RxList<PackageTypeObject> packageTypeList = <PackageTypeObject>[].obs;
  RxList<CityObject> cityList = <CityObject>[].obs;

  TextEditingController noOfPackageController = TextEditingController();
  TextEditingController actualWeightController = TextEditingController();
  TextEditingController chargeWeightController = TextEditingController();
  TextEditingController invoiceNoController = TextEditingController();
  TextEditingController docketDateController = TextEditingController();
  TextEditingController destinationController = TextEditingController();
  TextEditingController docketNoController = TextEditingController();
  TextEditingController consignorNameController = TextEditingController();
  TextEditingController consigneeAddressController = TextEditingController();
  TextEditingController eWayBillNoController = TextEditingController();
  TextEditingController declaredValueController = TextEditingController();
  TextEditingController valueMetricController = TextEditingController();
  TextEditingController toCityController = TextEditingController();
  TextEditingController fromCityController = TextEditingController();

  AppLoader appLoader = AppLoader();

  FocusNode noOfPackage = FocusNode();
  FocusNode actualWeight = FocusNode();
  FocusNode chargeWeight = FocusNode();
  FocusNode invoiceNumber = FocusNode();
  FocusNode destination = FocusNode();
  FocusNode odaCategory = FocusNode();
  FocusNode docketNumber = FocusNode();
  FocusNode docketFocus = FocusNode();
  FocusNode eWayBillNo = FocusNode();
  FocusNode declaredValue = FocusNode();
  FocusNode valueMetric = FocusNode();
  FocusNode noOfPKG = FocusNode();
  FocusNode length = FocusNode();
  FocusNode breadth = FocusNode();
  FocusNode height = FocusNode();

  RxList<CityDatum> CityType = <CityDatum>[].obs;
  Rx<DataStatus> payBaseDataStatus = DataStatus.loading.obs;
  Rx<DataStatus> transportModelDataStatus = DataStatus.loading.obs;
  Rx<DataStatus> productDataStatus = DataStatus.loading.obs;
  Rx<DataStatus> packageTypeDataStatus = DataStatus.loading.obs;
  Rx<eWayBillScan> eWayBillScanStatus = eWayBillScan.none.obs;

  RxList<XFile> selectedImages = <XFile>[].obs;
  List<String> base64Images = [];
  RxList<DocketInvoiceList> docketInvoiceList = <DocketInvoiceList>[].obs;
  RxList<PinCodeList> fromPinCodeList = <PinCodeList>[].obs;
  RxList<PinCodeList> toPinCodeList = <PinCodeList>[].obs;
  RxList<AddressList> consigneeAddressList = <AddressList>[].obs;
  RxList<AddressList> consignorAddressList = <AddressList>[].obs;

  List<String> consigneeTypeList = ["Railway", "Company", "Individual"];
  RxString selectConsigneeType = "Railway".obs;

  RxList<GeneralMasterList> designationList = <GeneralMasterList>[].obs;
  RxList<GeneralMasterList> departmentList = <GeneralMasterList>[].obs;
  RxList<GeneralMasterList> divisionList = <GeneralMasterList>[].obs;

  RxString selectDesignation = 'Select Designation'.obs;
  RxString selectDesignationId = ''.obs;
  RxString selectDepartment = 'Select Department'.obs;
  RxString selectDepartmentId = ''.obs;
  RxString selectDivision = 'Select Division'.obs;
  RxString selectDivisionId = ''.obs;

  TextEditingController railwayAddressController = TextEditingController();
  TextEditingController railwayMobileController = TextEditingController();

  FocusNode railwayAddressFocus = FocusNode();
  FocusNode railwayMobileFocus = FocusNode();

  late EwayBillResponse eWayBillResponse;

  void onInit() {
    billingTypeApi();
    consigneeApi();
    // transportModelApi();
    cityApi();
    designationApi();
    departmentApi();
    divisionApi();
    super.onInit();
  }

  String convertDateFormat({required String date}) {
    // Check if the input date is empty or null
    if (date.isEmpty) {
      return "";
    }

    try {
      // Parse the input date string in ISO 8601 format
      DateTime inputDate = DateTime.parse(date);

      // Format the date to 'dd MMM yyyy'
      String formattedDate = DateFormat("dd MMM yyyy").format(inputDate);

      return formattedDate;
    } catch (e) {
      return date;
    }
  }

  String originLocation =
      Pref().getBranchCode() == 'HQTR' ? Pref().getBaseLocation() : Pref().getBranchCode();
  RxString billingType = 'Select Paybase Type'.obs;
  RxString billingId = ''.obs;
  String consignorId = '';
  RxString consignorName = 'Select Billing Party'.obs;
  RxString selectTransportModel = 'Select Transport Mode'.obs;
  RxString selectConsigneeAddress = 'Select Consignee Address'.obs;
  RxString selectConsignorAddress = 'Select Consignor Address'.obs;
  RxString selectConsignee = 'Select Consignee'.obs;
  RxString selectFromPinCode = 'Select From Pincode'.obs;
  RxString selectToPinCode = 'Select To Pincode'.obs;
  RxString selectTransportId = ''.obs;
  RxString selectConsignorId = ''.obs;
  RxString selectConsigneeId = ''.obs;
  RxString selectFromPinCodeId = ''.obs;
  RxString pinCode = 'Select Pincode'.obs;
  String docketNm = "";
  String fromCity = "";
  String selectProduct = "";
  String selectPackage = "";
  String csgncd = '';
  String csgnm = '';
  String csgnAdd = '';
  String csgecd = '';
  String csgenm = '';
  String csgeAdd = '';
  String eWayBillExpiredDate = '';
  String eWayBillInvoiceDate = '';
  int toPincode = 0;
  dynamic area;

  bool isProcessing = false;

  RxBool isEWayNumber = true.obs;
  RxBool isDeclared = true.obs;
  RxBool isInvoice = true.obs;
  RxBool isNumberOfPkg = true.obs;
  RxBool isActualWeight = true.obs;
  RxBool isHeight = true.obs;
  RxBool isBreadth = true.obs;
  RxBool isLength = true.obs;
  RxBool isEWBEmpty = true.obs;
  RxBool transportMode = false.obs;
  RxBool consignee = false.obs;
  RxBool docketDate = true.obs;

  RxBool isValueMetrics = false.obs;

  textFocus() {
    noOfPackage.unfocus();
    actualWeight.unfocus();
    invoiceNumber.unfocus();
    eWayBillNo.unfocus();
    docketFocus.unfocus();
    height.unfocus();
    breadth.unfocus();
    length.unfocus();
    eWayBillNo.unfocus();
    noOfPKG.unfocus();
    declaredValue.unfocus();
    railwayAddressFocus.unfocus();
    railwayMobileFocus.unfocus();
  }

  ctrlClear() {
    noOfPackageController.clear();
    actualWeightController.clear();
    invoiceNoController.clear();
    docketDateController.clear();
    docketNoController.clear();
    eWayBillNoController.clear();
    destinationController.clear();
    toCityController.clear();
    docketInvoiceList.clear();
    chargeWeightController.clear();
    base64Images.clear();
    selectedImages.clear();
    declaredValueController.clear();
    consignorName = ''.obs;
    fromCity = '';
    consignorId = '';
    consignorName = ''.obs;
    eWayBillExpiredDate = '';
    selectProduct = "";
    docketNm = "";
    selectPackage = "";
    isEWBEmpty.value = true;
    selectConsigneeType.value = "Railway";
    selectConsignee.value = 'Select Consignee';
    selectConsigneeId.value = '';
    selectConsigneeAddress.value = 'Select Consignee Address';
    consigneeAddressList.clear();
    selectDesignation.value = 'Select Designation';
    selectDesignationId.value = '';
    selectDepartment.value = 'Select Department';
    selectDepartmentId.value = '';
    selectDivision.value = 'Select Division';
    selectDivisionId.value = '';
    railwayAddressController.clear();
    railwayMobileController.clear();
    fromCityController.clear();
    selectFromPinCode.value = 'Select From Pincode';
    selectToPinCode.value = 'Select To Pincode';
    selectFromPinCodeId.value = '';
    fromPinCodeList.clear();
    toPinCodeList.clear();
  }

  eWayBillApi(
      {required String eWayNumber,
      required bool isQrScan,
      required isMenuScreen,
      required BuildContext context}) async {
    if (isQrScan == true) {
      Get.back();
    }

    AppLoader().show();
    isProcessing = true;
    var data = {
      "lsno": eWayNumber,
    };

    try {
      final response = await WebService.tmsPostRequest(
        url: ApiService.eWayBill,
        body: json.encode(data),
      );
      AppLoader().hide();

      if (response.statusCode == 200) {
        eWayBillResponse = ewayBillResponseFromJson(response.data);
        if (eWayBillResponse.data.status == 1) {
          if (docketInvoiceList.length <= 1) {
            if (eWayBillStatus.value == eWayBill.withEWayBill) {
              destinationController.text = eWayBillResponse.data.destcd;
              toCityController.text = eWayBillResponse.data.toCity;
              csgecd = eWayBillResponse.data.csgecd;
              eWayBillExpiredDate = eWayBillResponse.data.eWayBillExpiredDate;
              eWayBillInvoiceDate = eWayBillResponse.data.eWayBillInvoiceDate;
              docketDateController.text =
                  convertDateFormat(date: eWayBillResponse.data.eWayBillInvoiceDate);
              docketDate.value = false;
              csgenm = eWayBillResponse.data.csgenm;
              csgnAdd = eWayBillResponse.data.csgnAdd;
              csgeAdd = eWayBillResponse.data.csgeAdd;
              csgnm = eWayBillResponse.data.csgnm;
              area = eWayBillResponse.data.area;
              toPincode = eWayBillResponse.data.toPincode;
              csgncd = eWayBillResponse.data.csgncd;
              fromCity = eWayBillResponse.data.fromCity;
              fromCityController.text = eWayBillResponse.data.fromCity;
              toCityController.text = eWayBillResponse.data.toCity;
              if (eWayBillResponse.data.fromCity.isNotEmpty) {
                fromPinCodeList.value = await pinCodeApi(eWayBillResponse.data.fromCity);
              }
              if (eWayBillResponse.data.toCity.isNotEmpty) {
                toPinCodeList.value = await pinCodeApi(eWayBillResponse.data.toCity);
              }
              if (eWayBillResponse.data.pincode != 0) {
                String fromPin = eWayBillResponse.data.pincode.toString();
                selectFromPinCode.value = fromPin;
                selectFromPinCodeId.value = fromPin;
                if (fromPinCodeList.every((e) => e.text != fromPin)) {
                  fromPinCodeList.add(PinCodeList(value: eWayBillResponse.data.pincode, text: fromPin));
                }
              }
              if (eWayBillResponse.data.toPincode != 0) {
                String toPin = eWayBillResponse.data.toPincode.toString();
                selectToPinCode.value = toPin;
                if (toPinCodeList.every((e) => e.text != toPin)) {
                  toPinCodeList.add(PinCodeList(value: eWayBillResponse.data.toPincode, text: toPin));
                }
              }
              pinCode.value = eWayBillResponse.data.pincode.toString();
              isValueMetrics.value = eWayBillResponse.data.volYn == "Y";
              isEWayNumber.value = false;
              isEWBEmpty.value = true;
              isInvoice.value = true;
              isDeclared.value = true;
              isNumberOfPkg.value = true;
              isActualWeight.value = true;
              isHeight.value = true;
              isBreadth.value = true;
              isLength.value = true;
              for (var data in payBasList) {
                if (data.codeId == eWayBillResponse.data.paybas) {
                  billingType.value = data.codeDesc;
                }
              }
              billingId.value = eWayBillResponse.data.paybas;
              for (var data in transportModelList) {
                if (data.codeId == eWayBillResponse.data.transMode) {
                  selectTransportModel.value = data.codeDesc;
                  print(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>${selectTransportModel.value}");
                }
              }
              selectTransportId.value = eWayBillResponse.data.transMode;
              consignorName.value = eWayBillResponse.data.partyName;
              consignorId = eWayBillResponse.data.partyCode;
              eWayBillNoController.text = eWayBillResponse.data.ewaybillNo;
              invoiceNoController.text = eWayBillResponse.data.invno;
              declaredValueController.text = eWayBillResponse.data.decval.toString();
            } else {
              eWayBillNoController.text = eWayBillResponse.data.ewaybillNo;
              invoiceNoController.text = eWayBillResponse.data.invno;
              eWayBillExpiredDate = eWayBillResponse.data.eWayBillExpiredDate;
              eWayBillInvoiceDate = eWayBillResponse.data.eWayBillInvoiceDate;
              declaredValueController.text = eWayBillResponse.data.decval.toString();
              isNumberOfPkg.value = true;
              isActualWeight.value = true;
              isHeight.value = true;
              isBreadth.value = true;
              isLength.value = true;
              isEWBEmpty.value = true;
              isDeclared.value = true;
              isInvoice.value = true;
              docketDate.value = true;
            }
          } else {
            if (consignorId == eWayBillResponse.data.partyCode) {
              eWayBillNoController.text = eWayBillResponse.data.ewaybillNo;
              invoiceNoController.text = eWayBillResponse.data.invno;
              eWayBillExpiredDate = eWayBillResponse.data.eWayBillExpiredDate;
              eWayBillInvoiceDate = eWayBillResponse.data.eWayBillInvoiceDate;
              declaredValueController.text = eWayBillResponse.data.decval.toString();
              isNumberOfPkg.value = true;
              isActualWeight.value = true;
              isHeight.value = true;
              isBreadth.value = true;
              isLength.value = true;
              isEWBEmpty.value = true;
              docketDate.value = true;
            } else {
              TmsToast.msg("EWayBill not match");
            }
          }

          if (isMenuScreen == true) {
            Get.toNamed(AppRoutes.quickDocketScreen);
            custListApi(context: context);
          }
        } else {
          TmsToast.msg(eWayBillResponse.data.message.isNotEmpty
              ? eWayBillResponse.data.message
              : "Data not found");
          eWayBillNoController.clear();
        }
      } else {
        TmsToast.msg("Data not found");
        eWayBillNoController.clear();
      }
    } catch (error, stackTrace) {
      AppLoader().hide();
      print("eWayBillApi error: $error");
      print("eWayBillApi stackTrace: $stackTrace");
      TmsToast.msg("Data not found");
      eWayBillNoController.clear();
    } finally {
      isProcessing = false;
    }
  }

  ///Billing Type
  Future<void> billingTypeApi() async {
    payBaseDataStatus.value = DataStatus.loading;
    String url = "${ApiService.baseUrl}V1/Master/GetGeneralMasterData?CodeType=PAYTYP";
    try {
      final dio.Response response = await WebService.tmsGetRequest(url);
      if (response.statusCode == 200) {
        log.i(jsonDecode(response.data), error: "Billing Type Api ${response.statusMessage}");
        BillingTypeResponse billingTypeResponse = billingTypeResponseFromJson(response.data);
        billingTypeResponse.removeCodeId("P01");
        payBasList.value = billingTypeResponse.billingTypeList;
        payBaseDataStatus.value = DataStatus.completed;
      } else {
        payBaseDataStatus.value = DataStatus.error;
        log.e(jsonDecode(response.data), error: "Billing Type Api ${response.statusMessage}");
        if (kDebugMode) {
          print(response.statusMessage);
        }
      }
    } catch (error) {
      payBaseDataStatus.value = DataStatus.error;
      log.e(error, error: "Billing Type Api Error");
      if (kDebugMode) {
        print(error.reactive);
      }
    }
  }

  Future<void> consigneeApi() async {
    try {
      final dio.Response response = await WebService.tmsGetRequest(ApiService.Consignee);
      if (response.statusCode == 200) {
        CustListResponse custListResponse = custListResponseFromJson(response.data);

        consigneeList.value = custListResponse.custList;
      } else {
        if (kDebugMode) {
          print(response.statusMessage);
        }
      }
    } catch (error) {
      if (kDebugMode) {
        print(error.reactive);
      }
    }
  }

  Future<void> designationApi() async {
    String url = "${ApiService.GeneralMasterData}?CodeType=CSTDESC";
    try {
      final dio.Response response = await WebService.tmsGetRequest(url);
      if (response.statusCode == 200) {
        GeneralMasterResponse generalMasterResponse =
            generalMasterResponseFromJson(response.data);
        designationList.value = generalMasterResponse.generalMasterList;
      } else {
        if (kDebugMode) {
          print(response.statusMessage);
        }
      }
    } catch (error) {
      if (kDebugMode) {
        print(error.reactive);
      }
    }
  }

  Future<void> departmentApi() async {
    String url = "${ApiService.GeneralMasterData}?CodeType=DEPART";
    try {
      final dio.Response response = await WebService.tmsGetRequest(url);
      if (response.statusCode == 200) {
        GeneralMasterResponse generalMasterResponse =
            generalMasterResponseFromJson(response.data);
        departmentList.value = generalMasterResponse.generalMasterList;
      } else {
        if (kDebugMode) {
          print(response.statusMessage);
        }
      }
    } catch (error) {
      if (kDebugMode) {
        print(error.reactive);
      }
    }
  }

  Future<void> divisionApi() async {
    String url = "${ApiService.GeneralMasterData}?CodeType=DIVISON";
    try {
      final dio.Response response = await WebService.tmsGetRequest(url);
      if (response.statusCode == 200) {
        GeneralMasterResponse generalMasterResponse =
            generalMasterResponseFromJson(response.data);
        divisionList.value = generalMasterResponse.generalMasterList;
      } else {
        if (kDebugMode) {
          print(response.statusMessage);
        }
      }
    } catch (error) {
      if (kDebugMode) {
        print(error.reactive);
      }
    }
  }

  Future<void> transportModelApi({
    required String Custcode,
    required String Paybas,
  }) async {
    AppLoader().show();
    try {
      final dio.Response response = await WebService.tmsGetRequest(
          "${ApiService.GetTransportMode}?Custcode=$Custcode&Paybas=$Paybas");
      AppLoader().hide();
      if (response.statusCode == 200) {
        TransportResponseModel transportModelResponse =
            transportResponseModelFromJson(response.data);
        transportModelList.value = transportModelResponse.transportData;
        transportMode.value = true;
      } else {
        if (kDebugMode) {
          print(response.statusMessage);
          transportMode.value = false;
        }
      }
    } catch (error) {
      if (kDebugMode) {
        print(error.reactive);
        transportMode.value = false;
      }
    }
  }

  Future<void> cityApi() async {
    try {
      final dio.Response response = await WebService.tmsGetRequest(ApiService.GetFromToCity);
      if (response.statusCode == 200) {
        CityResponse cityResponse = cityResponseFromJson(response.data);
        cityList.value = cityResponse.cityList;
      } else {
        if (kDebugMode) {
          print(response.statusMessage);
        }
      }
    } catch (error) {
      if (kDebugMode) {
        print(error.reactive);
      }
    }
  }

  Future<List<PinCodeList>> pinCodeApi(city) async {
    try {
      final dio.Response response =
          await WebService.tmsGetRequest(ApiService.GetPinCode + "?City=$city&Type=C");
      if (response.statusCode == 200) {
        PinCode pinCode = pinCodeFromJson(response.data);
        return pinCode.pinCodeList;
      } else {
        if (kDebugMode) {
          print(response.statusMessage);
        }
      }
    } catch (error) {
      if (kDebugMode) {
        print(error.reactive);
      }
    }
    return [];
  }

  Future<List<AddressList>> AddressApi({required String id, required String city}) async {
    try {
      final dio.Response response = await WebService.tmsGetRequest(ApiService.GetAddress +
          "?Consignee=${id}&City=${city}&BaseUserName=${Pref().getBaseLocation()}");
      if (response.statusCode == 200) {
        Address address = addressFromJson(response.data);
        return address.addressList;
      } else {
        if (kDebugMode) {
          print(response.statusMessage);
        }
      }
    } catch (error) {
      if (kDebugMode) {
        print(error.reactive);
      }
    }
    return [];
  }

  Future<void> custListApi({required BuildContext context}) async {
    String paybasParam = billingId.value.isNotEmpty ? billingId.value : billingType.value;
    String url =
        "${ApiService.baseUrl}V1/Master/GetCustomerList?Search=%&Location=${Pref().getBaseLocation()}&Paybas=$paybasParam";
    print(url);
    try {
      final dio.Response response = await WebService.tmsGetRequest(url);

      if (response.statusCode == 200) {
        log.i(jsonDecode(response.data), error: "Customer List Api ${response.statusMessage}");

        CustListResponse custListResponse = custListResponseFromJson(response.data);

        customerList.value = custListResponse.custList;
      } else {
        customerList.clear();
        log.e(jsonDecode(response.data), error: "Customer List Api ${response.statusMessage}");
        TmsToast.msg('Docket check error ${response.statusMessage}');
        if (kDebugMode) {
          print(response.statusMessage);
        }
      }
    } catch (error) {
      customerList.clear();
      log.e(error, error: "Customer List Api Error");
      TmsToast.msg('No Data Found');
    }
  }

  Future<void> getFromToCityType({required String locationID}) async {
    try {
      final dio.Response response =
          await WebService.tmsGetRequest("${ApiService.GetFromToCity}?type=$locationID");
      if (response.statusCode == 200) {
        dynamic responseData = response.data;
        CityTypeResponseModel cityTypeResponseModel = cityTypeResponseModelFromJson(responseData);
        CityType.value = cityTypeResponseModel.cityData;
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

  Future<String> getLocationCode(String value) async {
    String locationName = value;
    String locationCode = locationName.split("-")[0].replaceAll(" ", '');
    return locationCode;
  }

  /// Billing Type
  billingSelectType(String value) {
    for (var data in payBasList) {
      if (data.codeDesc == value) {
        billingType.value = data.codeId;
        print(
            "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<${billingType}");
      }
    }
  }

  /// Consignor Name
  consignorSelectName(String value) {
    consignorName.value = value;
    consignorId =
        customerList.where((innerValue) => innerValue.custnm.contains(value)).first.custcd;
  }

  parseInputToDouble(String input) {
    if (input.isEmpty) {
      return 0.0;
    }
    return double.tryParse(input) ?? 0.0;
  }

  parseInputToInt(String input) {
    if (input.isEmpty) {
      return 0;
    }
    return int.tryParse(input) ?? 0;
  }

  ///Quick Docket Submit Request
  quickDocketApiRequest() {
    String csgeCode = '';
    String csgeName = '';
    String csgeAddress = '';

    if (selectConsigneeType.value.toLowerCase() == 'railway') {
      csgeCode = selectDesignationId.value.isNotEmpty
          ? selectDesignationId.value
          : selectDepartmentId.value;
      csgeName = selectDesignation.value;
      csgeAddress = railwayAddressController.text;
    } else {
      csgeCode = selectConsigneeId.value;
      csgeName = selectConsignee.value;
      csgeAddress = selectConsigneeAddress.value;
    }

    QuickDocketSubmit quickDocketSubmitRequest = QuickDocketSubmit(
      dockdt: docketDateController.text,
      partYCode: consignorId,
      partyName: consignorName.value,
      orgncd: "${Pref().getBaseLocation()}",
      destcd: destinationController.text,
      paybas: billingType.value,
      currFinYear: Pref().getFinYear(),
      baseCompanyCode: Pref().getCompanyCode(),
      toCity: toCityController.text,
      transPortModel: selectTransportId.value,
      dockno: docketNoController.text,
      pincode: selectFromPinCode.value != 'Select From Pincode' ? selectFromPinCode.value : "",
      baseUserName: Pref().getUserId(),
      volYn: isValueMetrics.isTrue ? "Y" : "N",
      csgeAdd: csgeAddress,
      csgecd: csgeCode,
      csgenm: csgeName,
      csgnAdd: selectConsignorAddress.value,
      csgncd: consignorId,
      csgnm: consignorName.value,
      fromCity: fromCityController.text,
      toPincode: selectToPinCode.value != 'Select To Pincode' ? selectToPinCode.value : "",
      csgeCity: toCityController.text,
      csgePincode: selectToPinCode.value != 'Select To Pincode' ? selectToPinCode.value : "",
      csgnCity: fromCityController.text,
      csgnPincode: selectFromPinCode.value != 'Select From Pincode' ? selectFromPinCode.value : "",
      railwayDesignation: selectConsigneeType.value.toLowerCase() == 'railway'
          ? selectDesignationId.value
          : "",
      railwayDepartment: selectConsigneeType.value.toLowerCase() == 'railway'
          ? selectDepartmentId.value
          : "",
      railwayDivison: selectConsigneeType.value.toLowerCase() == 'railway'
          ? selectDivisionId.value
          : "",
      railwayAddr: selectConsigneeType.value.toLowerCase() == 'railway'
          ? railwayAddressController.text
          : "",
      railwayMobile: selectConsigneeType.value.toLowerCase() == 'railway'
          ? railwayMobileController.text
          : "",
      rcitype: selectConsigneeType.value,
      docketInvoiceList: docketInvoiceList,
    );
    return quickDocketSubmitRequest;
  }

  ///Quick Docket
  Future<void> quickDocketSubmitApi({required BuildContext context}) async {
    quickDocketSubmitToJson(quickDocketApiRequest());
    appLoader.show();
    var response = await WebService.tmsPostRequest(
      url: ApiService.quickDocketAPI,
      body: quickDocketSubmitToJson(quickDocketApiRequest()),
    );
    appLoader.hide();
    try {
      if (response.statusCode == 200) {
        QuickDocketSubmitResponse quickDocketSubmitResponse =
            quickDocketSubmitResponseFromJson(response.data);
        if (quickDocketSubmitResponse.status == 200) {
          log.i(jsonDecode(response.data),
              error: "Quick Docket Submit Api ${quickDocketSubmitResponse.message}");
          docketNm = quickDocketSubmitResponse.data.docketno;
          ctrlClear();
          submitAlertDialog(
            context: context,
            isPrintShow: true,
            title: '${quickDocketSubmitResponse.data.docketno}\nDocket number create successfully',
            onTap: () {
              Get.toNamed(AppRoutes.dashboardScreen);
              ctrlClear();
            },
            printerTap: () {
              Get.back();
              Get.toNamed(AppRoutes.docketDetails,
                  arguments: quickDocketSubmitResponse.data.docketno);
            },
            onTapText: 'Done',
            image: 'assets/images/dashboardimages/succes.png',
          );
        } else {
          log.e(jsonDecode(response.data),
              error: "Quick Docket Submit Api ${quickDocketSubmitResponse.message}");
          TmsToast.msg(quickDocketSubmitResponse.message);
        }
      } else {
        TmsToast.msg("Quick Docket submit ${response.statusMessage}");
      }
    } catch (error) {
      TmsToast.msg('Quick Docket Submit error ${error.toString()}');
    }
  }

  submitValidator({
    required GlobalKey<FormState> billingTypeFromKey,
    required GlobalKey<FormState> billingPartyFromKey,
    required GlobalKey<FormState> transportModelFromKey,
    required GlobalKey<FormState> fromCityFromKey,
    required GlobalKey<FormState> toCityFromKey,
    required GlobalKey<FormState> fromPinCodeFromKey,
    required GlobalKey<FormState> toPinCodeFromKey,
    required GlobalKey<FormState> invoiceNoFromKey,
    required GlobalKey<FormState> numberPkgFromKey,
    required GlobalKey<FormState> docketDateFromKey,
    required GlobalKey<FormState> declaredValueFromKey,
    required GlobalKey<FormState> actualWeightFromKey,
    required GlobalKey<FormState> chargeWeightFromKey,
    required GlobalKey<FormState> consigneeFromKey,
    required GlobalKey<FormState> consigneeAddressFromKey,
    required GlobalKey<FormState> consigneeTypeFromKey,
    required GlobalKey<FormState> designationFromKey,
    required GlobalKey<FormState> departmentFromKey,
    required GlobalKey<FormState> railwayAddressFromKey,
    required GlobalKey<FormState> divisionFromKey,
    required GlobalKey<FormState> railwayMobileFromKey,
  }) {
    bool isBillingValid = (eWayBillStatus.value == eWayBill.withoutEWayBill)
        ? ((billingTypeFromKey.currentState?.validate() ?? false) &&
            (billingPartyFromKey.currentState?.validate() ?? false))
        : true;

    bool isTransportValid =
        transportMode.isTrue ? (transportModelFromKey.currentState?.validate() ?? false) : true;

    bool isConsigneeTypeValid = consigneeTypeFromKey.currentState?.validate() ?? false;

    bool isConsigneeValid = false;
    if (selectConsigneeType.value.toLowerCase() == 'railway') {
      bool isDesig = designationFromKey.currentState?.validate() ?? false;
      bool isDept = departmentFromKey.currentState?.validate() ?? false;
      bool isAddr = railwayAddressFromKey.currentState?.validate() ?? false;
      bool isDiv = divisionFromKey.currentState?.validate() ?? false;
      bool isMob = railwayMobileFromKey.currentState?.validate() ?? false;
      isConsigneeValid = isDesig && isDept && isAddr && isDiv && isMob;
    } else {
      bool isCsg = consigneeFromKey.currentState?.validate() ?? false;
      bool isCsgAdd = consigneeAddressFromKey.currentState?.validate() ?? false;
      isConsigneeValid = isCsg && isCsgAdd;
    }

    bool isFromCityValid = fromCityFromKey.currentState?.validate() ?? false;
    bool isToCityValid = toCityFromKey.currentState?.validate() ?? false;
    bool isFromPinCodeValid = (fromPinCodeFromKey.currentState?.validate() ?? false) &&
        selectFromPinCode.value.isNotEmpty &&
        selectFromPinCode.value != 'Select From Pincode';
    bool isToPinCodeValid = (toPinCodeFromKey.currentState?.validate() ?? false) &&
        selectToPinCode.value.isNotEmpty &&
        selectToPinCode.value != 'Select To Pincode';
    bool isInvoiceValid = invoiceNoFromKey.currentState?.validate() ?? false;
    bool isPkgValid = numberPkgFromKey.currentState?.validate() ?? false;
    bool isDeclaredValid = declaredValueFromKey.currentState?.validate() ?? false;
    bool isActualWeightValid = actualWeightFromKey.currentState?.validate() ?? false;
    bool isChargeWeightValid = chargeWeightFromKey.currentState?.validate() ?? false;

    if (!isFromPinCodeValid && isFromCityValid) {
      TmsToast.msg('Please select From Pincode');
    } else if (!isToPinCodeValid && isToCityValid) {
      TmsToast.msg('Please select To Pincode');
    }

    bool isOtherValid = isFromCityValid &&
        isToCityValid &&
        isFromPinCodeValid &&
        isToPinCodeValid &&
        isInvoiceValid &&
        isPkgValid &&
        isDeclaredValid &&
        isActualWeightValid &&
        isChargeWeightValid;

    if (isBillingValid && isTransportValid && isConsigneeTypeValid && isConsigneeValid && isOtherValid) {
      docketInvoiceList.add(
        DocketInvoiceList(
          invno: invoiceNoController.text,
          prodcd: "",
          pkgsty: "",
          pkgs: parseInputToInt(noOfPackageController.text),
          decval: parseInputToDouble(declaredValueController.text),
          actuwt: parseInputToDouble(actualWeightController.text),
          chrgwt: parseInputToDouble(chargeWeightController.text),
          ewbno: eWayBillNoController.text,
          voLL: 0.0,
          voLB: 0.0,
          voLH: 0.0,
          toTCFT: 0.0,
          eWayBillExpiredDate: eWayBillExpiredDate.isEmpty ? null : eWayBillExpiredDate,
          eWayBillInvoiceDate: eWayBillInvoiceDate.isEmpty ? null : eWayBillInvoiceDate,
          image: base64Images.isNotEmpty ? base64Images[0] : "",
        ),
      );

      isEWayNumber.value = true;
      isDeclared.value = true;
      isInvoice.value = true;
      invoiceNoController.clear();
      noOfPackageController.clear();

      declaredValueController.clear();

      actualWeightController.clear();

      chargeWeightController.clear();
      eWayBillNoController.clear();
      quickDocketSubmitApi(context: Get.context!);
    }
  }
}
