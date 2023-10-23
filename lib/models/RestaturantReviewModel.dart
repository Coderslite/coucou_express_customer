import 'package:fooddelivery/utils/ModalKeys.dart';

class RestaurantReviewModel {
  String? id;
  String? review;
  int? rating;
  String? reviewerId;
  String? reviewerName;
  String? reviewerImage;
  String? reviewerLocation;
  List<String>? reviewTags;
  String? restaurantId;

  RestaurantReviewModel({this.id, this.restaurantId, this.review, this.rating, this.reviewerId, this.reviewerName, this.reviewerImage, this.reviewerLocation, this.reviewTags});

  factory RestaurantReviewModel.fromJson(Map<String, dynamic> json) {
    return RestaurantReviewModel(
      id: json[CommonKeys.id],
      review: json[CommonKeys.review],
      rating: json[CommonKeys.rating],
      reviewerId: json[RestaurantReviewKeys.reviewerId],
      reviewerName: json[RestaurantReviewKeys.reviewerName],
      reviewerImage: json[RestaurantReviewKeys.reviewerImage],
      reviewerLocation: json[RestaurantReviewKeys.reviewerLocation],
      restaurantId: json[CommonKeys.restaurantId],
      reviewTags: json[CommonKeys.reviewTags] != null ? List<String>.from(json[CommonKeys.reviewTags]) : [],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data[CommonKeys.id] = this.id;
    data[CommonKeys.review] = this.review;
    data[CommonKeys.rating] = this.rating;
    data[RestaurantReviewKeys.reviewerId] = this.reviewerId;
    data[RestaurantReviewKeys.reviewerName] = this.reviewerName;
    data[RestaurantReviewKeys.reviewerImage] = this.reviewerImage;
    data[RestaurantReviewKeys.reviewerLocation] = this.reviewerLocation;
    data[CommonKeys.reviewTags] = this.reviewTags;
    data[CommonKeys.restaurantId] = this.restaurantId;
    return data;
  }
}
