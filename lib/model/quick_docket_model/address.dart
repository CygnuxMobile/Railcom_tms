import 'dart:convert';

Address addressFromJson(String str) => Address.fromJson(json.decode(str));

String addressToJson(Address data) => json.encode(data.toJson());

class Address {
  final int statusCode;
  final int status;
  final List<AddressList> addressList;
  final dynamic errors;
  final dynamic metaData;
  final String message;

  Address({
    required this.statusCode,
    required this.status,
    required this.addressList,
    required this.errors,
    required this.metaData,
    required this.message,
  });

  factory Address.fromJson(Map<String, dynamic> json) => Address(
        statusCode: json["statusCode"],
        status: json["status"],
        addressList: List<AddressList>.from(json["data"].map((x) => AddressList.fromJson(x))),
        errors: json["errors"],
        metaData: json["metaData"],
        message: json["message"],
      );

  Map<String, dynamic> toJson() => {
        "statusCode": statusCode,
        "status": status,
        "data": List<dynamic>.from(addressList.map((x) => x.toJson())),
        "errors": errors,
        "metaData": metaData,
        "message": message,
      };
}

class AddressList {
  final String address;
  final dynamic srNo;

  AddressList({
    required this.address,
    required this.srNo,
  });

  factory AddressList.fromJson(Map<String, dynamic> json) => AddressList(
        address: json["address"],
        srNo: json["srNo"],
      );

  Map<String, dynamic> toJson() => {
        "address": address,
        "srNo": srNo,
      };
}
