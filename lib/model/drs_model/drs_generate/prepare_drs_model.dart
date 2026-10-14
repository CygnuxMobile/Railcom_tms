import 'dart:convert';

String prsDrsSubmitRequestToJson(PRSDRSSubmitRequest data) => json.encode(data.toJson());
String prepareDRSRequestToJson(PRSDRSSubmitRequest data) => json.encode(data.toJson());

class PRSDRSSubmitRequest {
  String vendorType;
  String vendor;
  String vendorName;
  String vendorGDNo;
  String vehicleNo;
  String driverName;
  double contractAmount;
  String baseLocationCode;
  String baseCompanyCode;
  String baseYearValFirst;
  String baseUserName;
  String type;
  String moduleType;
  String billingScheduleId;
  String billingScheduleName;
  String paymentType;
  List<DockDetItem> dockdet;

  PRSDRSSubmitRequest({
    required this.vendorType,
    required this.vendor,
    required this.vendorName,
    required this.vendorGDNo,
    required this.vehicleNo,
    required this.driverName,
    required this.contractAmount,
    required this.baseLocationCode,
    required this.baseCompanyCode,
    required this.baseYearValFirst,
    required this.baseUserName,
    required this.type,
    required this.moduleType,
    required this.billingScheduleId,
    required this.billingScheduleName,
    required this.paymentType,
    required this.dockdet,
  });

  Map<String, dynamic> toJson() => {
    "vendorType": vendorType,
    "vendor": vendor,
    "vendorName": vendorName,
    "vendorGDNo": vendorGDNo,
    "vehicleNo": vehicleNo,
    "driverName": driverName,
    "contractAmount": contractAmount,
    "baseLocationCode": baseLocationCode,
    "baseCompanyCode": baseCompanyCode,
    "baseYearValFirst": baseYearValFirst,
    "baseUserName": baseUserName,
    "type": type,
    "moduleType": moduleType,
    "billingScheduleId": billingScheduleId,
    "billingScheduleName": billingScheduleName,
    "paymentType": paymentType,
    "dockdet": List<dynamic>.from(dockdet.map((x) => x.toJson())),
  };
}

class DockDetItem {
  int id;
  String dockno;
  String docksf;
  String docketMode;
  String bkgDate;
  String arrivalDate;
  String commitedDelyDate;
  String orgncd;
  String desTCd;
  String currLoc;
  int pendPkgQty;
  double arrPkgQty;
  double pkgsno;
  String payBas;
  String paybaSStr;
  String atad;
  String cdeldt;
  String businesstype;
  String trNMOD;
  double actuwt;
  double arrWeightQty;
  double chrgwt;
  double freight;
  double dkttot;
  double handlingchrg;
  double svctax;
  int cnd;
  String staffBA;
  bool isEnabled;
  double rate;
  double maxLimit;
  double newRate;
  String ratetype;
  int cnt;
  String message;
  String eWayBillNo;
  double vendorChargebleWeight;
  String vendorGDNo;

  DockDetItem({
    this.id = 0,
    required this.dockno,
    required this.docksf,
    required this.docketMode,
    required this.bkgDate,
    this.arrivalDate = "",
    required this.commitedDelyDate,
    required this.orgncd,
    required this.desTCd,
    required this.currLoc,
    required this.pendPkgQty,
    required this.arrPkgQty,
    required this.pkgsno,
    required this.payBas,
    required this.paybaSStr,
    required this.atad,
    required this.cdeldt,
    required this.businesstype,
    required this.trNMOD,
    required this.actuwt,
    required this.arrWeightQty,
    required this.chrgwt,
    this.freight = 0.0,
    this.dkttot = 1.0,
    this.handlingchrg = 0.0,
    required this.svctax,
    required this.cnd,
    required this.staffBA,
    required this.isEnabled,
    this.rate = 0.0,
    this.maxLimit = 0.0,
    this.newRate = 0.0,
    this.ratetype = "",
    required this.cnt,
    required this.message,
    required this.eWayBillNo,
    this.vendorChargebleWeight = 0.0,
    this.vendorGDNo = "",
  });

  Map<String, dynamic> toJson() => {
    "id": id,
    "dockno": dockno,
    "docksf": docksf,
    "docket_Mode": docketMode,
    "bkg_Date": bkgDate,
    "arrival_Date": arrivalDate,
    "commited_Dely_Date": commitedDelyDate,
    "orgncd": orgncd,
    "desT_CD": desTCd,
    "curr_Loc": currLoc,
    "pendPkgQty": pendPkgQty,
    "arrPkgQty": arrPkgQty,
    "pkgsno": pkgsno,
    "payBas": payBas,
    "paybaS_Str": paybaSStr,
    "atad": atad,
    "cdeldt": cdeldt,
    "businesstype": businesstype,
    "trN_MOD": trNMOD,
    "actuwt": actuwt,
    "arrWeightQty": arrWeightQty,
    "chrgwt": chrgwt,
    "freight": freight,
    "dkttot": dkttot,
    "handlingchrg": handlingchrg,
    "svctax": svctax,
    "cnd": cnd,
    "staff_BA": staffBA,
    "isEnabled": isEnabled,
    "rate": rate,
    "maxLimit": maxLimit,
    "newRate": newRate,
    "ratetype": ratetype,
    "cnt": cnt,
    "message": message,
    "eWayBillNo": eWayBillNo,
    "vendor_Chargeble_Weight": vendorChargebleWeight,
    "vendorGDNo": vendorGDNo,
  };
}

// Response Model
class PDCSubmitApiResponse {
  String? status;
  String? message;
  String? pdcno;
  String? type;
  String? isPartBVisible;
  String? isCEWayBillGenerate;

  PDCSubmitApiResponse({
    this.status,
    this.message,
    this.pdcno,
    this.type,
    this.isPartBVisible,
    this.isCEWayBillGenerate,
  });

  factory PDCSubmitApiResponse.fromJson(Map<String, dynamic> json) => PDCSubmitApiResponse(
    status: json["status"]?.toString(),
    message: json["message"]?.toString(),
    pdcno: json["pdcno"]?.toString(),
    type: json["type"]?.toString(),
    isPartBVisible: json["isPartBVisible"]?.toString(),
    isCEWayBillGenerate: json["isCEWayBillGenerate"]?.toString(),
  );
}
