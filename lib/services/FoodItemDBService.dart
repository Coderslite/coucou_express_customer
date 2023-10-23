import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fooddelivery/models/MenuModel.dart';
import 'package:fooddelivery/services/BaseService.dart';
import 'package:fooddelivery/utils/Constants.dart';
import 'package:fooddelivery/utils/ModalKeys.dart';

import '../main.dart';

class FoodItemDBService extends BaseService {
  FoodItemDBService() {
    ref = db.collection(RESTAURANTS);
  }

  Stream<List<MenuModel>> foodMenuByRestaurant(String restaurantId,
      {String? searchText}) {
    return restaurantsFoodMenuQuery(restaurantId, searchText: searchText)
        .snapshots()
        .map((x) => x.docs
            .map((y) => MenuModel.fromJson(y.data() as Map<String, dynamic>))
            .toList());
  }

  Query restaurantsFoodMenuQuery(String restaurantId, {String? searchText}) {
    print(restaurantId);
    Query menu = ref.doc(restaurantId).collection("dishes");
    menu.get().then((value) {
      print(value.size);
    });
    return menu;
  }

  Stream<List<MenuModel>> foodMenuByCategory(String? catId,
      {String? searchText}) {
    return ref.where(CommonKeys.categoryId, isEqualTo: catId).snapshots().map(
        (x) => x.docs
            .map((y) => MenuModel.fromJson(y.data() as Map<String, dynamic>))
            .toList());
  }
}
