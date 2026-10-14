import 'dart:convert';

List<UpdatePartBResponse> updatePartBResponseFromJson(dynamic data) {
  dynamic jsonData;
  if (data is String) {
    try {
      jsonData = json.decode(data);
    } catch (_) {
      return [];
    }
  } else {
    jsonData = data;
  }

  if (jsonData is List) {
    return List<UpdatePartBResponse>.from(
        jsonData.map((x) => UpdatePartBResponse.fromJson(x is Map<String, dynamic> ? x : Map<String, dynamic>.from(x))));
  } else if (jsonData is Map && jsonData["data"] != null && jsonData["data"] is List) {
    return List<UpdatePartBResponse>.from(
        jsonData["data"].map((x) => UpdatePartBResponse.fromJson(x is Map<String, dynamic> ? x : Map<String, dynamic>.from(x))));
  }
  return [];
}

class UpdatePartBResponse {
  final int srNo;
  final String response;
  final String ewayBillNo;
  final String entryDate;
  final String vehicleNo;
  final String dockno;
  final int status;
  final String errorMsg;
  final dynamic tcno;
  final String downlaodurl;
  final String statusCode;

  UpdatePartBResponse({
    required this.srNo,
    required this.response,
    required this.ewayBillNo,
    required this.entryDate,
    required this.vehicleNo,
    required this.dockno,
    required this.status,
    required this.errorMsg,
    this.tcno,
    this.downlaodurl = "",
    this.statusCode = "",
  });

  factory UpdatePartBResponse.fromJson(Map<String, dynamic> json) => UpdatePartBResponse(
        srNo: json["srNo"] is int ? json["srNo"] : int.tryParse(json["srNo"]?.toString() ?? "0") ?? 0,
        response: json["response"]?.toString() ?? "",
        ewayBillNo: json["ewayBillNo"]?.toString() ?? "",
        entryDate: json["entryDate"]?.toString() ?? "",
        vehicleNo: json["vehicleNo"]?.toString() ?? "",
        dockno: json["dockno"]?.toString() ?? "",
        status: json["status"] is int ? json["status"] : int.tryParse(json["status"]?.toString() ?? "0") ?? 0,
        errorMsg: json["errorMsg"]?.toString() ?? "",
        tcno: json["tcno"],
        downlaodurl: json["downlaodurl"]?.toString() ?? json["downloadurl"]?.toString() ?? "",
        statusCode: json["statusCode"]?.toString() ?? "",
      );
}

class PartBInnerResponse {
  final Results results;

  PartBInnerResponse({required this.results});

  factory PartBInnerResponse.fromJson(Map<String, dynamic> json) => PartBInnerResponse(
        results: Results.fromJson(json["results"]),
      );
}

class Results {
  final Message message;
  final String status;
  final int code;

  Results({required this.message, required this.status, required this.code});

  factory Results.fromJson(Map<String, dynamic> json) => Results(
        message: Message.fromJson(json["message"]),
        status: json["status"],
        code: json["code"],
      );
}

class Message {
  final String vehUpdDate;
  final String validUpto;
  final bool error;
  final String url;

  Message({required this.vehUpdDate, required this.validUpto, required this.error, required this.url});

  factory Message.fromJson(Map<String, dynamic> json) => Message(
        vehUpdDate: json["vehUpdDate"] ?? "",
        validUpto: json["validUpto"] ?? "",
        error: json["error"] ?? false,
        url: json["url"] ?? "",
      );
}
