import 'dart:convert';

GenerateConsolidatedResponse generateConsolidatedResponseFromJson(String str) =>
    GenerateConsolidatedResponse.fromJson(json.decode(str));

class GenerateConsolidatedResponse {
  final int statusCode;
  final int status;
  final ConsolidatedData data;
  final dynamic errors;
  final dynamic metaData;
  final String message;

  GenerateConsolidatedResponse({
    required this.statusCode,
    required this.status,
    required this.data,
    this.errors,
    this.metaData,
    required this.message,
  });

  factory GenerateConsolidatedResponse.fromJson(Map<String, dynamic> json) =>
      GenerateConsolidatedResponse(
        statusCode: json["statusCode"] ?? 0,
        status: json["status"] ?? 0,
        data: ConsolidatedData.fromJson(json["data"] ?? {}),
        errors: json["errors"],
        metaData: json["metaData"],
        message: json["message"] ?? "",
      );
}

class ConsolidatedData {
  final bool wasSplitDueToNicMismatch;
  final List<ConsolidatedGroup> groups;

  ConsolidatedData({
    required this.wasSplitDueToNicMismatch,
    required this.groups,
  });

  factory ConsolidatedData.fromJson(Map<String, dynamic> json) => ConsolidatedData(
        wasSplitDueToNicMismatch: json["wasSplitDueToNicMismatch"] ?? false,
        groups: json["groups"] == null
            ? []
            : List<ConsolidatedGroup>.from(json["groups"].map((x) => ConsolidatedGroup.fromJson(x))),
      );
}

class ConsolidatedGroup {
  final bool status;
  final dynamic message;
  final String cEwaybillNo;
  final String cEwaybillVldt;
  final String downlaodurl;
  final List<String> ewayBillNumbers;

  ConsolidatedGroup({
    required this.status,
    this.message,
    required this.cEwaybillNo,
    required this.cEwaybillVldt,
    required this.downlaodurl,
    required this.ewayBillNumbers,
  });

  factory ConsolidatedGroup.fromJson(Map<String, dynamic> json) => ConsolidatedGroup(
        status: json["status"] ?? false,
        message: json["message"],
        cEwaybillNo: json["cEwaybillNo"] ?? "",
        cEwaybillVldt: json["cEwaybillVLDT"] ?? "",
        downlaodurl: json["downlaodurl"] ?? "",
        ewayBillNumbers: json["ewayBillNumbers"] == null
            ? []
            : List<String>.from(json["ewayBillNumbers"].map((x) => x)),
      );
}
