// To parse this JSON data, do
//
//     final pinCode = pinCodeFromJson(jsonString);

import 'dart:convert';

PinCode pinCodeFromJson(String str) => PinCode.fromJson(json.decode(str));

String pinCodeToJson(PinCode data) => json.encode(data.toJson());

class PinCode {
  final int statusCode;
  final int status;
  final List<PinCodeList> pinCodeList;
  final dynamic errors;
  final dynamic metaData;
  final String message;

  PinCode({
    required this.statusCode,
    required this.status,
    required this.pinCodeList,
    required this.errors,
    required this.metaData,
    required this.message,
  });

  factory PinCode.fromJson(Map<String, dynamic> json) => PinCode(
        statusCode: json["statusCode"],
        status: json["status"],
        pinCodeList: List<PinCodeList>.from(json["data"].map((x) => PinCodeList.fromJson(x))),
        errors: json["errors"],
        metaData: json["metaData"],
        message: json["message"],
      );

  Map<String, dynamic> toJson() => {
        "statusCode": statusCode,
        "status": status,
        "data": List<dynamic>.from(pinCodeList.map((x) => x.toJson())),
        "errors": errors,
        "metaData": metaData,
        "message": message,
      };
}

class PinCodeList {
  final int value;
  final String text;

  PinCodeList({
    required this.value,
    required this.text,
  });

  factory PinCodeList.fromJson(Map<String, dynamic> json) => PinCodeList(
        value: json["value"],
        text: json["text"],
      );

  Map<String, dynamic> toJson() => {
        "value": value,
        "text": text,
      };
}
