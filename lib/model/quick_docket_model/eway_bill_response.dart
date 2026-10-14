import 'dart:convert';

EwayBillResponse ewayBillResponseFromJson(String str) => EwayBillResponse.fromJson(json.decode(str));

class EwayBillResponse {
  final int statusCode;
  final int status;
  final Data data;
  final dynamic errors;
  final dynamic metaData;
  final String message;

  EwayBillResponse({
    required this.statusCode,
    required this.status,
    required this.data,
    required this.errors,
    required this.metaData,
    required this.message,
  });

  factory EwayBillResponse.fromJson(Map<String, dynamic> json) => EwayBillResponse(
    statusCode: int.tryParse(json["statusCode"]?.toString() ?? '0') ?? 0,
    status: int.tryParse(json["status"]?.toString() ?? '0') ?? 0,
    data: json["data"] != null && json["data"] is Map<String, dynamic>
        ? Data.fromJson(json["data"])
        : Data.empty(),
    errors: json["errors"],
    metaData: json["metaData"],
    message: json["message"]?.toString() ?? '',
  );
}

class Data {
  final int status;
  final String message;
  final String partyCode;
  final String partyName;
  final String invno;
  final String invdt;
  final double decval;
  final String eWayBillExpiredDate;
  final double eWayInvoicevalue;
  final String eWayBillInvoiceDate;
  final String fromCity;
  final String toCity;
  final String paybas;
  final String ewaybillNo;
  final int pincode;
  final String odaCategory;
  final String destcd;
  final String transMode;
  final String volYn;
  final String csgncd;
  final String csgnm;
  final String csgnAdd;
  final String csgecd;
  final String csgenm;
  final String csgeAdd;
  final int toPincode;
  final dynamic area;

  Data({
    required this.status,
    required this.message,
    required this.partyCode,
    required this.partyName,
    required this.invno,
    required this.invdt,
    required this.decval,
    required this.eWayBillExpiredDate,
    required this.eWayInvoicevalue,
    required this.eWayBillInvoiceDate,
    required this.fromCity,
    required this.toCity,
    required this.paybas,
    required this.ewaybillNo,
    required this.pincode,
    required this.odaCategory,
    required this.destcd,
    required this.transMode,
    required this.volYn,
    required this.csgncd,
    required this.csgnm,
    required this.csgnAdd,
    required this.csgecd,
    required this.csgenm,
    required this.csgeAdd,
    required this.toPincode,
    required this.area,
  });

  factory Data.empty() => Data(
    status: 0,
    message: '',
    partyCode: '',
    partyName: '',
    invno: '',
    invdt: '',
    decval: 0.0,
    eWayBillExpiredDate: '',
    eWayInvoicevalue: 0.0,
    eWayBillInvoiceDate: '',
    fromCity: '',
    toCity: '',
    paybas: '',
    ewaybillNo: '',
    pincode: 0,
    odaCategory: '',
    destcd: '',
    transMode: '',
    volYn: '',
    csgncd: '',
    csgnm: '',
    csgnAdd: '',
    csgecd: '',
    csgenm: '',
    csgeAdd: '',
    toPincode: 0,
    area: null,
  );

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    status: int.tryParse(json["status"]?.toString() ?? '0') ?? 0,
    message: json["message"]?.toString() ?? '',
    partyCode: json["partyCode"]?.toString() ?? '',
    partyName: json["partyName"]?.toString() ?? '',
    invno: json["invno"]?.toString() ?? '',
    invdt: json["invdt"]?.toString() ?? '',
    decval: double.tryParse(json["decval"]?.toString() ?? '0') ?? 0.0,
    eWayBillExpiredDate: json["eWayBillExpiredDate"]?.toString() ?? '',
    eWayInvoicevalue: double.tryParse(json["eWayInvoicevalue"]?.toString() ?? '0') ?? 0.0,
    eWayBillInvoiceDate: json["eWayBillInvoiceDate"]?.toString() ?? '',
    fromCity: json["fromCity"]?.toString() ?? '',
    toCity: json["toCity"]?.toString() ?? '',
    paybas: json["paybas"]?.toString() ?? '',
    ewaybillNo: json["ewaybillNo"]?.toString() ?? '',
    pincode: int.tryParse(json["pincode"]?.toString() ?? '0') ?? 0,
    odaCategory: json["odaCategory"]?.toString() ?? '',
    destcd: json["destcd"]?.toString() ?? '',
    transMode: json["transMode"]?.toString() ?? '',
    volYn: json["vol_yn"]?.toString() ?? '',
    csgncd: json["csgncd"]?.toString() ?? '',
    csgnm: json["csgnm"]?.toString() ?? '',
    csgnAdd: json["csgnAdd"]?.toString() ?? '',
    csgecd: json["csgecd"]?.toString() ?? '',
    csgenm: json["csgenm"]?.toString() ?? '',
    csgeAdd: json["csgeAdd"]?.toString() ?? '',
    toPincode: int.tryParse(json["toPincode"]?.toString() ?? '0') ?? 0,
    area: json["area"],
  );
}
