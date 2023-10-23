import 'package:fooddelivery/utils/ModalKeys.dart';

class AdModel {
  String? id;
  String? type;
  String? title;
  String? description;
  String? image;
  String? buttonColor;
  String? buttonText;
  String? buttonTextColor;
  String? textColor;
  String? restuarantId;

  AdModel({
    this.id,
    this.type,
    this.title,
    this.description,
    this.image,
    this.buttonColor,
    this.buttonText,
    this.buttonTextColor,
    this.textColor,
    this.restuarantId,
  });

  factory AdModel.fromJson(Map<String, dynamic> json) {
    return AdModel(
      id: json[AdKeys.id],
      type: json[AdKeys.type],
      title: json[AdKeys.title],
      description: json[AdKeys.description],
      image: json[AdKeys.image],
      buttonColor: json[AdKeys.buttonColor],
      buttonText: json[AdKeys.buttonText],
      buttonTextColor: json[AdKeys.buttonTextColor],
      textColor: json[AdKeys.textColor],
      restuarantId: json[AdKeys.restuarantId],
    );
  }
}
