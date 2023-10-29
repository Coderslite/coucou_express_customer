import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fooddelivery/utils/ModalKeys.dart';

import 'OrderItemData.dart';

class OrderModel {
  List<OrderItemData>? listOfOrder;
  int? totalAmount;
  int? totalItem;
  String? userId;
  String? orderStatus;
  DateTime? createdAt;
  DateTime? updatedAt;
  String? orderId;
  String? restaurantId;
  String? restaurantName;
  String? deliveryLocation;
  String? deliveryAddress;
  String? deliveryAddressDescription;
  String? pavilionNo;
  GeoPoint? userLocation;
  String? userAddress;
  GeoPoint? deliveryBoyLocation;
  String? deliveryBoyId;
  String? paymentMethod;
  String? restaurantCity;
  String? paymentStatus;
  String? id;
  int? deliveryCharge;
  bool? taken;
  String? orderType;
  String? orderUrl;
  List? receiptUrl;
  String? otherInformation;

  OrderModel({
    this.listOfOrder,
    this.totalAmount,
    this.totalItem,
    this.userId,
    this.orderStatus,
    this.createdAt,
    this.updatedAt,
    this.orderId,
    this.restaurantId,
    this.restaurantName,
    this.deliveryLocation,
    this.deliveryAddress,
    this.deliveryAddressDescription,
    this.pavilionNo,
    this.userLocation,
    this.userAddress,
    this.deliveryBoyLocation,
    this.deliveryBoyId,
    this.paymentMethod,
    this.restaurantCity,
    this.paymentStatus,
    this.id,
    this.deliveryCharge,
    this.taken = false,
    this.orderType,
    this.orderUrl,
    this.receiptUrl,
    this.otherInformation,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      listOfOrder: json[OrderKeys.listOfOrder] != null
          ? (json[OrderKeys.listOfOrder] as List)
              .map<OrderItemData>((e) => OrderItemData.fromJson(e))
              .toList()
          : null,
      totalAmount: json[OrderKeys.totalAmount],
      totalItem: json[OrderKeys.totalItem],
      userId: json[OrderKeys.userId],
      orderStatus: json[OrderKeys.orderStatus],
      createdAt: json[CommonKeys.createdAt] != null
          ? (json[CommonKeys.createdAt] as Timestamp).toDate()
          : null,
      updatedAt: json[CommonKeys.updatedAt] != null
          ? (json[CommonKeys.updatedAt] as Timestamp).toDate()
          : null,
      orderId: json[OrderKeys.orderId],
      restaurantId: json[CommonKeys.restaurantId],
      restaurantName: json[RestaurantKeys.restaurantName],
      deliveryAddress: json[MenuKeys.deliveryAddress],
      deliveryAddressDescription: json[MenuKeys.deliveryAddressDescription],
      deliveryLocation: json[MenuKeys.deliveryLocation],
      pavilionNo: json[MenuKeys.pavilionNo],
      userLocation: json[OrderKeys.userLocation],
      userAddress: json[OrderKeys.userAddress],
      deliveryBoyLocation: json[OrderKeys.deliveryBoyLocation],
      deliveryBoyId: json[OrderKeys.deliveryBoyId],
      paymentMethod: json[OrderKeys.paymentMethod],
      restaurantCity: json[RestaurantKeys.restaurantCity],
      paymentStatus: json[OrderKeys.paymentStatus],
      deliveryCharge: json[OrderKeys.deliveryCharge],
      id: json[CommonKeys.id],
      taken: json[OrderKeys.taken],
      orderType: json[OrderKeys.orderType],
      orderUrl: json[OrderKeys.orderUrl],
      receiptUrl: json[OrderKeys.receiptUrl],
      otherInformation: json[MenuKeys.otherInformation],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data[OrderKeys.listOfOrder] =
        this.listOfOrder!.map((e) => e.toJson()).toList();

    data[OrderKeys.totalAmount] = this.totalAmount;
    data[OrderKeys.totalItem] = this.totalItem;
    data[OrderKeys.userId] = this.userId;
    data[OrderKeys.orderId] = this.orderId;
    data[OrderKeys.orderStatus] = this.orderStatus;
    data[CommonKeys.createdAt] = this.createdAt;
    data[CommonKeys.updatedAt] = this.updatedAt;
    data[CommonKeys.restaurantId] = this.restaurantId;
    data[RestaurantKeys.restaurantName] = this.restaurantName;
    data[MenuKeys.deliveryLocation] = this.deliveryLocation;
    data[MenuKeys.deliveryAddress] = this.deliveryAddress;
    data[MenuKeys.deliveryAddressDescription] = this.deliveryAddressDescription;
    data[MenuKeys.pavilionNo] = this.pavilionNo;
    data[OrderKeys.userLocation] = this.userLocation;
    data[OrderKeys.userAddress] = this.userAddress;
    data[OrderKeys.deliveryBoyLocation] = this.deliveryBoyLocation;
    data[OrderKeys.deliveryBoyId] = this.deliveryBoyId;
    data[OrderKeys.paymentMethod] = this.paymentMethod;
    data[RestaurantKeys.restaurantCity] = this.restaurantCity;
    data[OrderKeys.paymentStatus] = this.paymentStatus;
    data[CommonKeys.id] = this.id;
    data[OrderKeys.deliveryCharge] = this.deliveryCharge;
    data[OrderKeys.taken] = this.taken;
    data[OrderKeys.orderType] = this.orderType;
    data[OrderKeys.orderUrl] = this.orderUrl;
    data[OrderKeys.receiptUrl] = this.receiptUrl;
    data[MenuKeys.otherInformation] = this.otherInformation;
    return data;
  }
}
