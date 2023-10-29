import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fooddelivery/utils/ModalKeys.dart';

class MenuModel {
  String? id;
  String? itemName;
  List<String>? ingredientsTags;
  int? itemPrice;
  bool? inStock;
  String? categoryId;
  String? restaurantId;
  String? restaurantName;
  String? restaurantLatitude;
  String? restaurantLongitude;
  String? categoryName;
  bool? isSuggestedPrice;
  String? image;
  String? description;
  String? pavilionNo;
  String? deliveryAddress;
  String? deliveryLocation;
  DateTime? createdAt;
  bool? ownedByUs;
  // DateTime? updatedAt;
  bool? isDeleted;
  bool? onGoogle;

  //local
  int? qty;
  bool? isCheck;
  String? otherInformation;

  MenuModel({
    this.itemName,
    this.id,
    this.ingredientsTags,
    this.image,
    this.itemPrice,
    this.inStock,
    this.categoryId,
    this.categoryName,
    required this.isSuggestedPrice,
    this.description,
    this.createdAt,
    // this.updatedAt,
    this.restaurantId,
    this.restaurantName,
    this.restaurantLatitude,
    this.restaurantLongitude,
    this.qty = 1,
    this.isDeleted,
    this.ownedByUs,
    this.onGoogle,
    this.isCheck = false,
    this.deliveryLocation,
    this.deliveryAddress,
    this.pavilionNo,
    this.otherInformation,
  });

  factory MenuModel.fromJson(Map<String, dynamic> json) {
    return MenuModel(
      id: json[CommonKeys.id],
      itemName: json[MenuKeys.dishName],
      image: json[MenuKeys.dishImage],
      itemPrice: json[MenuKeys.dishPrice],
      inStock: json[MenuKeys.inStock],
      categoryId: json[CommonKeys.categoryId],
      categoryName: json[MenuKeys.dishCategory],
      isSuggestedPrice: json[CommonKeys.isSuggesttedPrice],
      description: json[MenuKeys.description],
      restaurantId: json[MenuKeys.restaurantId],
      qty: json['qty'] != null ? json['qty'] : 1,
      restaurantName: json[RestaurantKeys.restaurantName],
      restaurantLatitude: json[RestaurantKeys.restaurantLatitude],
      restaurantLongitude: json[RestaurantKeys.restaurantLongitude],
      ingredientsTags: json[MenuKeys.ingredientsTags] != null
          ? List<String>.from(json[MenuKeys.ingredientsTags])
          : [],
      createdAt: json[CommonKeys.createdAt] != null
          ? (json[CommonKeys.createdAt] as Timestamp).toDate()
          : null,
      // updatedAt: json[CommonKeys.updatedAt] != null
      //     ? (json[CommonKeys.updatedAt] as Timestamp).toDate()
      //     : null,
      isDeleted: json[CommonKeys.isDeleted],
      onGoogle: json[MenuKeys.onGoogle],
      deliveryLocation: json[MenuKeys.deliveryLocation],
      deliveryAddress: json[MenuKeys.deliveryAddress],
      pavilionNo: json[MenuKeys.pavilionNo],
      otherInformation: json[MenuKeys.otherInformation],
      ownedByUs: json[RestaurantKeys.ownedByUs],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data[CommonKeys.id] = this.id;
    data[MenuKeys.dishName] = this.itemName;
    data[MenuKeys.dishImage] = this.image;
    data[CommonKeys.createdAt] = this.createdAt;
    // data[CommonKeys.updatedAt] = this.updatedAt;
    data[MenuKeys.dishPrice] = this.itemPrice;
    data[MenuKeys.inStock] = this.inStock;
    data[MenuKeys.dishCategory] = this.categoryId;
    data[MenuKeys.dishCategory] = this.categoryName;
    data[CommonKeys.isSuggesttedPrice] = this.isSuggestedPrice;
    data[MenuKeys.ingredientsTags] = this.ingredientsTags;
    data[MenuKeys.description] = this.description;
    data[MenuKeys.restaurantId] = this.restaurantId;
    data[RestaurantKeys.restaurantName] = this.restaurantName;
    data[RestaurantKeys.restaurantLatitude] = this.restaurantLatitude;
    data[RestaurantKeys.restaurantLongitude] = this.restaurantLongitude;
    data[CommonKeys.isDeleted] = this.isDeleted;
    data[MenuKeys.onGoogle] = this.onGoogle;
    data[MenuKeys.deliveryLocation] = this.deliveryLocation;
    data[MenuKeys.deliveryAddress] = this.deliveryAddress;
    data[MenuKeys.pavilionNo] = this.pavilionNo;
    data['qty'] = this.qty;
    data[MenuKeys.otherInformation] = this.otherInformation;
    data[RestaurantKeys.ownedByUs] = this.ownedByUs;
    return data;
  }
}
