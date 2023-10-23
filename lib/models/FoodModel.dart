import 'package:fooddelivery/utils/ModalKeys.dart';

class FoodModel {
  String? id;
  String? name;
  String? image;

  FoodModel({
    this.id,
    this.name,
    this.image,
  });

  factory FoodModel.fromJson(Map<String, dynamic> json) {
    return FoodModel(
      id: json[FoodKey.id],
      name: json[FoodKey.name],
      image: json[FoodKey.image],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data[FoodKey.id] = this.id;
    data[FoodKey.name] = this.name;
    data[FoodKey.image] = this.image;
    return data;
  }
}
