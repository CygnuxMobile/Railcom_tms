// To parse this JSON data, do
//
//     final quickDocketSubmit = quickDocketSubmitFromJson(jsonString);

import 'dart:convert';

QuickDocketSubmit quickDocketSubmitFromJson(String str) =>
    QuickDocketSubmit.fromJson(json.decode(str));

String quickDocketSubmitToJson(QuickDocketSubmit data) => json.encode(data.toJson());

class QuickDocketSubmit {
  final String dockdt;
  final String partYCode;
  final String partyName;
  final String orgncd;
  final String paybas;
  final String currFinYear;
  final String baseCompanyCode;
  final String destcd;
  final String dockno;
  final String baseUserName;
  final String transPortModel;
  final String pincode;
  final String toCity;
  final String volYn;
  final String csgncd;
  final String csgnm;
  final String csgnAdd;
  final String csgnCity;
  final String csgnPincode;
  final String csgecd;
  final String csgenm;
  final String csgeAdd;
  final String csgeCity;
  final String csgePincode;
  final String fromCity;
  final String toPincode;
  final String railwayDesignation;
  final String railwayDepartment;
  final String railwayDivison;
  final String railwayAddr;
  final String railwayMobile;
  final String rcitype;
  final List<DocketInvoiceList> docketInvoiceList;

  QuickDocketSubmit({
    required this.dockdt,
    required this.partYCode,
    required this.partyName,
    required this.orgncd,
    required this.paybas,
    required this.currFinYear,
    required this.baseCompanyCode,
    required this.destcd,
    required this.dockno,
    required this.baseUserName,
    required this.transPortModel,
    required this.pincode,
    required this.toCity,
    required this.volYn,
    required this.csgncd,
    required this.csgnm,
    required this.csgnAdd,
    required this.csgnCity,
    required this.csgnPincode,
    required this.csgecd,
    required this.csgenm,
    required this.csgeAdd,
    required this.csgeCity,
    required this.csgePincode,
    required this.fromCity,
    required this.toPincode,
    required this.railwayDesignation,
    required this.railwayDepartment,
    required this.railwayDivison,
    required this.railwayAddr,
    required this.railwayMobile,
    required this.rcitype,
    required this.docketInvoiceList,
  });

  factory QuickDocketSubmit.fromJson(Map<String, dynamic> json) => QuickDocketSubmit(
        dockdt: json["dockdt"] ?? "",
        partYCode: json["partY_CODE"] ?? "",
        partyName: json["party_name"] ?? "",
        orgncd: json["orgncd"] ?? "",
        paybas: json["paybas"] ?? "",
        currFinYear: json["currFinYear"] ?? "",
        baseCompanyCode: json["baseCompanyCode"] ?? "",
        destcd: json["destcd"] ?? "",
        dockno: json["dockno"] ?? "",
        baseUserName: json["baseUserName"] ?? "",
        transPortModel: json["transPortModel"] ?? "",
        pincode: json["pincode"] ?? "",
        toCity: json["toCity"] ?? "",
        volYn: json["vol_yn"] ?? "",
        csgncd: json["csgncd"] ?? "",
        csgnm: json["csgnm"] ?? "",
        csgnAdd: json["csgnAdd"] ?? "",
        csgnCity: json["csgnCity"] ?? "",
        csgnPincode: json["csgnPincode"] ?? "",
        csgecd: json["csgecd"] ?? "",
        csgenm: json["csgenm"] ?? "",
        csgeAdd: json["csgeAdd"] ?? "",
        csgeCity: json["csgeCity"] ?? "",
        csgePincode: json["csgePincode"] ?? "",
        fromCity: json["fromCity"] ?? "",
        toPincode: json["toPincode"] ?? "",
        railwayDesignation: json["railwayDesignation"] ?? "",
        railwayDepartment: json["railwayDepartment"] ?? "",
        railwayDivison: json["railwayDivison"] ?? "",
        railwayAddr: json["railwayAddr"] ?? "",
        railwayMobile: json["railwayMobile"] ?? "",
        rcitype: json["rcitype"] ?? "",
        docketInvoiceList: json["docketInvoiceList"] == null
            ? []
            : List<DocketInvoiceList>.from(
                json["docketInvoiceList"].map((x) => DocketInvoiceList.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "dockdt": dockdt,
        "partY_CODE": partYCode,
        "party_name": partyName,
        "orgncd": orgncd,
        "paybas": paybas,
        "currFinYear": currFinYear,
        "baseCompanyCode": baseCompanyCode,
        "destcd": destcd,
        "dockno": dockno,
        "baseUserName": baseUserName,
        "transPortModel": transPortModel,
        "pincode": pincode,
        "toCity": toCity,
        "vol_yn": volYn,
        "csgncd": csgncd,
        "csgnm": csgnm,
        "csgnAdd": csgnAdd,
        "csgnCity": csgnCity,
        "csgnPincode": csgnPincode,
        "csgecd": csgecd,
        "csgenm": csgenm,
        "csgeAdd": csgeAdd,
        "csgeCity": csgeCity,
        "csgePincode": csgePincode,
        "fromCity": fromCity,
        "toPincode": toPincode,
        "railwayDesignation": railwayDesignation,
        "railwayDepartment": railwayDepartment,
        "railwayDivison": railwayDivison,
        "railwayAddr": railwayAddr,
        "railwayMobile": railwayMobile,
        "rcitype": rcitype,
        "docketInvoiceList": List<dynamic>.from(docketInvoiceList.map((x) => x.toJson())),
      };
}

class DocketInvoiceList {
  final String invno;
  final String prodcd;
  final String pkgsty;
  final int pkgs;
  final double decval;
  final double actuwt;
  final double chrgwt;
  final String ewbno;
  final double voLL;
  final double voLB;
  final double voLH;
  final double toTCFT;
  String? eWayBillExpiredDate;
  String? eWayBillInvoiceDate;
  final String image;

  DocketInvoiceList({
    required this.invno,
    required this.prodcd,
    required this.pkgsty,
    required this.pkgs,
    required this.decval,
    required this.actuwt,
    required this.chrgwt,
    required this.ewbno,
    required this.voLL,
    required this.voLB,
    required this.voLH,
    this.toTCFT = 0.0,
    this.eWayBillExpiredDate,
    this.eWayBillInvoiceDate,
    required this.image,
  });

  factory DocketInvoiceList.fromJson(Map<String, dynamic> json) => DocketInvoiceList(
        invno: json["invno"] ?? "",
        prodcd: json["prodcd"] ?? "",
        pkgsty: json["pkgsty"] ?? "",
        pkgs: (json["pkgs"] as num?)?.toInt() ?? 0,
        decval: (json["decval"] as num?)?.toDouble() ?? 0.0,
        actuwt: (json["actuwt"] as num?)?.toDouble() ?? 0.0,
        chrgwt: (json["chrgwt"] as num?)?.toDouble() ?? 0.0,
        ewbno: json["ewbno"] ?? "",
        voLL: (json["voL_L"] as num?)?.toDouble() ?? 0.0,
        voLB: (json["voL_B"] as num?)?.toDouble() ?? 0.0,
        voLH: (json["voL_H"] as num?)?.toDouble() ?? 0.0,
        toTCFT: (json["toT_CFT"] as num?)?.toDouble() ?? 0.0,
        eWayBillExpiredDate: json["eWayBillExpiredDate"],
        eWayBillInvoiceDate: json["eWayBillInvoiceDate"],
        image: json["image"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "invno": invno,
        "prodcd": prodcd,
        "pkgsty": pkgsty,
        "pkgs": pkgs,
        "decval": decval,
        "actuwt": actuwt,
        "chrgwt": chrgwt,
        "ewbno": ewbno,
        "voL_L": voLL,
        "voL_B": voLB,
        "voL_H": voLH,
        "toT_CFT": toTCFT,
        "eWayBillExpiredDate": eWayBillExpiredDate,
        "eWayBillInvoiceDate": eWayBillInvoiceDate,
        "image": image,
      };
}
