import 'package:cloud_firestore/cloud_firestore.dart';

class FixedDeliveryFeeModel {
  String? id;
  int? amount;
  String? type;
  Timestamp? updatedAt;

  FixedDeliveryFeeModel({
    this.id,
    this.amount,
    this.type,
    this.updatedAt,
  });

  factory FixedDeliveryFeeModel.fromJson(Map<String, dynamic> json) {
    return FixedDeliveryFeeModel(
      id: json['id'],
      amount: json['amount'],
      type: json['type'],
      updatedAt: json['updatedAt'],
    );
  }
}
