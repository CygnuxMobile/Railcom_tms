import 'dart:convert';

List<DrsGenerateResponse> drsGenerateResponseFromJson(String str) =>
    List<DrsGenerateResponse>.from(json.decode(str).map((x) => DrsGenerateResponse.fromJson(x)));

String drsGenerateResponseToJson(List<DrsGenerateResponse> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class DrsGenerateResponse {
  final int id;
  final String dockno;
  final String docksf;
  final String docketMode;
  final String bkgDate;
  final String arrivalDate;
  final String commitedDelyDate;
  final String orgncd;
  final String desTCd;
  final String currLoc;
  final int pendPkgQty;
  final int arrPkgQty;
  final int pkgsno;
  final String payBas;
  final String paybaSStr;
  final String atad;
  final String cdeldt;
  final String businesstype;
  final String trNMod;
  final int actuwt;
  final int arrWeightQty;
  final int chrgwt;
  final double freight;
  final double dkttot;
  final int handlingchrg;
  final int svctax;
  final int cnd;
  final dynamic staffBa;
  final bool isEnabled;
  final int rate;
  final int maxLimit;
  final int newRate;
  final dynamic ratetype;
  final int cnt;
  final String message;
  final String eWayBillNo;
  final int vendorChargebleWeight;
  final dynamic vendorGdNo;

  DrsGenerateResponse({
    required this.id,
    required this.dockno,
    required this.docksf,
    required this.docketMode,
    required this.bkgDate,
    required this.arrivalDate,
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
    required this.trNMod,
    required this.actuwt,
    required this.arrWeightQty,
    required this.chrgwt,
    required this.freight,
    required this.dkttot,
    required this.handlingchrg,
    required this.svctax,
    required this.cnd,
    required this.staffBa,
    required this.isEnabled,
    required this.rate,
    required this.maxLimit,
    required this.newRate,
    required this.ratetype,
    required this.cnt,
    required this.message,
    required this.eWayBillNo,
    required this.vendorChargebleWeight,
    required this.vendorGdNo,
  });

  factory DrsGenerateResponse.fromJson(Map<String, dynamic> json) => DrsGenerateResponse(
        id: json["id"],
        dockno: json["dockno"],
        docksf: json["docksf"],
        docketMode: json["docket_Mode"],
        bkgDate: json["bkg_Date"],
        arrivalDate: json["arrival_Date"],
        commitedDelyDate: json["commited_Dely_Date"],
        orgncd: json["orgncd"],
        desTCd: json["desT_CD"],
        currLoc: json["curr_Loc"],
        pendPkgQty: json["pendPkgQty"],
        arrPkgQty: json["arrPkgQty"],
        pkgsno: json["pkgsno"],
        payBas: json["payBas"],
        paybaSStr: json["paybaS_Str"],
        atad: json["atad"],
        cdeldt: json["cdeldt"],
        businesstype: json["businesstype"],
        trNMod: json["trN_MOD"],
        actuwt: json["actuwt"],
        arrWeightQty: json["arrWeightQty"],
        chrgwt: json["chrgwt"],
        freight: json["freight"]?.toDouble(),
        dkttot: json["dkttot"]?.toDouble(),
        handlingchrg: json["handlingchrg"],
        svctax: json["svctax"],
        cnd: json["cnd"],
        staffBa: json["staff_BA"],
        isEnabled: json["isEnabled"],
        rate: json["rate"],
        maxLimit: json["maxLimit"],
        newRate: json["newRate"],
        ratetype: json["ratetype"],
        cnt: json["cnt"],
        message: json["message"],
        eWayBillNo: json["eWayBillNo"],
        vendorChargebleWeight: json["vendor_Chargeble_Weight"],
        vendorGdNo: json["vendorGDNo"],
      );

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
        "trN_MOD": trNMod,
        "actuwt": actuwt,
        "arrWeightQty": arrWeightQty,
        "chrgwt": chrgwt,
        "freight": freight,
        "dkttot": dkttot,
        "handlingchrg": handlingchrg,
        "svctax": svctax,
        "cnd": cnd,
        "staff_BA": staffBa,
        "isEnabled": isEnabled,
        "rate": rate,
        "maxLimit": maxLimit,
        "newRate": newRate,
        "ratetype": ratetype,
        "cnt": cnt,
        "message": message,
        "eWayBillNo": eWayBillNo,
        "vendor_Chargeble_Weight": vendorChargebleWeight,
        "vendorGDNo": vendorGdNo,
      };
}
