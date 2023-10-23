import 'package:fooddelivery/utils/ModalKeys.dart';

class CategoryModel {
  String? categoryName;
  String? image;
  String? id;

  CategoryModel({
    this.categoryName,
    this.image,
    this.id,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      // id: json[CommonKeys.id],
      categoryName: json[CommonKeys.categoryName],
      image: json[CommonKeys.image],
      // isDeleted: json[CommonKeys.isDeleted],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data[CommonKeys.id] = this.id;
    data[CommonKeys.categoryName] = this.categoryName;
    data[CommonKeys.image] = this.image;
    return data;
  }
}
