import 'package:fooddelivery/utils/ModalKeys.dart';

class OrderItemData {
  String? id;
  String? categoryId;
  String? categoryName;
  String? image;
  String? itemName;
  int? itemPrice;
  int? qty;
  bool? isSuggestedPrice;
  String? restaurantId;
  String? restaurantName;
  String? restaurantLocation;
  String? restaurantAddress;

  OrderItemData({
    this.id,
    this.categoryId,
    this.categoryName,
    this.image,
    this.itemName,
    this.itemPrice,
    this.qty,
    this.isSuggestedPrice,
    this.restaurantId,
    this.restaurantName,
    this.restaurantLocation,
    this.restaurantAddress,
  });

  factory OrderItemData.fromJson(Map<String, dynamic> json) {
    return OrderItemData(
      id: json[CommonKeys.id],
      image: json[CommonKeys.image],
      itemName: json[CommonKeys.itemName],
      itemPrice: json[CommonKeys.itemPrice],
      categoryId: json[CommonKeys.categoryId],
      categoryName: json[CommonKeys.categoryName],
      qty: json[CommonKeys.qty],
      isSuggestedPrice: json[CommonKeys.isSuggesttedPrice],
      restaurantId: json[CommonKeys.restaurantId],
      restaurantLocation: json[RestaurantKeys.restaurantLocation],
      restaurantAddress: json[RestaurantKeys.restaurantAddress],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data[CommonKeys.id] = this.id;
    data[CommonKeys.itemName] = this.itemName;
    data[CommonKeys.image] = this.image;
    data[CommonKeys.itemPrice] = this.itemPrice;
    data[CommonKeys.categoryId] = this.categoryId;
    data[CommonKeys.categoryName] = this.categoryName;
    data[CommonKeys.qty] = this.qty;
    data[CommonKeys.isSuggesttedPrice] = this.isSuggestedPrice;
    data[CommonKeys.restaurantId] = this.restaurantId;
    data[RestaurantKeys.restaurantName] = this.restaurantName;
    data[RestaurantKeys.restaurantLocation] = this.restaurantLocation;
    data[RestaurantKeys.restaurantAddress] = this.restaurantAddress;
    return data;
  }
}
