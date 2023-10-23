import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fooddelivery/models/RestaurantModel.dart';
import 'package:fooddelivery/services/BaseService.dart';
import 'package:fooddelivery/utils/Constants.dart';
import 'package:fooddelivery/utils/ModalKeys.dart';
import 'package:nb_utils/nb_utils.dart';

import '../main.dart';

class RestaurantDBService extends BaseService {
  RestaurantDBService() {
    ref = db.collection(RESTAURANTS);
  }

  Stream<List<RestaurantModel>> allRestaurants({required String searchText}) {
    if (searchText != '') {
      var query = ref.where('foodList', arrayContains: searchText);
      return query.snapshots().map((event) => event.docs.map((e) {
            return RestaurantModel.fromJson(e.data() as Map<String, dynamic>);
          }).toList());
    } else {
      return ref.snapshots().map((event) => event.docs.map((e) {
            return RestaurantModel.fromJson(e.data() as Map<String, dynamic>);
          }).toList());
    }
  }

  Stream<List<RestaurantModel>> restaurants({required String searchText}) {
    return restaurantsQuery(searchText: searchText).snapshots().map((x) => x
        .docs
        .map((y) => RestaurantModel.fromJson(y.data() as Map<String, dynamic>))
        .toList());
  }

  Query restaurantsQuery({String searchText = ''}) {
    return searchText.isNotEmpty
        ? ref
            .where(RestaurantKeys.caseSearch,
                arrayContains: searchText.toLowerCase())
            .where(RestaurantKeys.restaurantCity,
                isEqualTo: getStringAsync(USER_CITY_NAME))
            .where(CommonKeys.isDeleted, isEqualTo: false)
        : ref
            .where(RestaurantKeys.restaurantCity,
                isEqualTo: getStringAsync(USER_CITY_NAME))
            .where(CommonKeys.isDeleted, isEqualTo: false);
  }

  Stream<List<RestaurantModel>> restaurantByDish(String dishName) {
    return FirebaseFirestore.instance
        .collectionGroup(
            'dishes') // Replace 'dishes' with the name of your subcollection
        .where('dishName', isEqualTo: dishName)
        .snapshots()
        .map((x) => x.docs.map((y) {
              print(y);
              return RestaurantModel.fromJson(y.data());
            }).toList());
  }

  Stream<List<RestaurantModel>> restaurantByCategory(String? categoryName,
      {String? searchText, String? cityName}) {
    return ref
        .where(RestaurantKeys.catList, arrayContains: categoryName)
        // .where(RestaurantKeys.restaurantCity, isEqualTo: cityName)
        // .where(CommonKeys.isDeleted, isEqualTo: false)
        .snapshots()
        .map((x) => x.docs
            .map((y) =>
                RestaurantModel.fromJson(y.data() as Map<String, dynamic>))
            .toList());
  }

  Future<List> getFavRestaurantList() async {
    // if (favRestaurantList.isNotEmpty) {
    var email = auth.currentUser!.email;
    Query query = FirebaseFirestore.instance
        .collection("users")
        .where('email', isEqualTo: email);
    return await query.get().then((x) {
      var favs = x.docs.single.data() as Map;
      List favList = favs['favRestaurant'];
      favRestaurantList = favs['favRestaurant'];
      return favList;
    });
  }

  Future<RestaurantModel> getRestaurantById(String? restaurantId) async {
    return await ref
        .where(CommonKeys.restaurantId, isEqualTo: restaurantId)
        .get()
        .then((res) {
      if (res.docs.isEmpty) {
        throw appStore.translate('noRestaurantFound');
      } else {
        return RestaurantModel.fromJson(
            res.docs.first.data() as Map<String, dynamic>);
      }
    }).catchError((error) {
      throw error.toString();
    });
  }
}
