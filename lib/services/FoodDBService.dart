import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fooddelivery/services/BaseService.dart';
import 'package:fooddelivery/utils/Constants.dart';
import 'package:fooddelivery/utils/ModalKeys.dart';

import '../main.dart';
import '../models/FoodModel.dart';

class FoodDBService extends BaseService {
  FoodDBService() {
    ref = db.collection(FOOD_CATEGORIES);
  }

  Stream<List<FoodModel>> categories(
      {String searchText = '', isDeleted = false}) {
    Query query = ref;

    if (searchText.isNotEmpty) {
      query = query.where(RestaurantKeys.caseSearch,
          arrayContains: searchText.toLowerCase());
    }

    query = query.orderBy('createdAt',
        descending: true); // Sort by createdAt in descending order

    return query.snapshots().map((x) => x.docs
        .map(
            (y) => FoodModel.fromJson(y.data() as Map<String, dynamic>))
        .toList());
  }
}
