import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fooddelivery/utils/ModalKeys.dart';

class AddressModel {
  String? address;
  String? otherDetails;
  GeoPoint? userLocation;
  String? pavilionNo;
  String? addressLocation;

  AddressModel({
    this.address,
    this.otherDetails,
    this.userLocation,
    this.addressLocation,
    this.pavilionNo,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      address: json[AddressKeys.address],
      otherDetails: json[AddressKeys.details],
      userLocation: json[AddressKeys.userLocation],
      addressLocation: json[AddressKeys.addressLocation],
      pavilionNo: json[AddressKeys.pavilionNo],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data[AddressKeys.address] = this.address;
    data[AddressKeys.details] = this.otherDetails;
    data[AddressKeys.userLocation] = this.userLocation;
    data[AddressKeys.addressLocation] = this.addressLocation;
    data[AddressKeys.pavilionNo] = this.pavilionNo;
    return data;
  }
}
