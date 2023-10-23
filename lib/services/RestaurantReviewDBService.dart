import 'package:fooddelivery/models/RestaturantReviewModel.dart';
import 'package:fooddelivery/services/BaseService.dart';
import 'package:fooddelivery/utils/Constants.dart';
import 'package:fooddelivery/utils/ModalKeys.dart';

import '../main.dart';

class RestaurantReviewsDBService extends BaseService {
  RestaurantReviewsDBService(String? restId) {
    ref = db.collection(RESTAURANT_REVIEWS);
  }

  Stream<List<RestaurantReviewModel>> reviews(String? restaurantId) {
    return ref.where(CommonKeys.restaurantId, isEqualTo: restaurantId).snapshots().map((x) => x.docs.map((y) => RestaurantReviewModel.fromJson(y.data() as Map<String, dynamic>)).toList());
  }
}
