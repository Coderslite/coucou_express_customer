import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fooddelivery/models/CategoryModel.dart';
import 'package:fooddelivery/services/BaseService.dart';
import 'package:fooddelivery/utils/Constants.dart';
import 'package:fooddelivery/utils/ModalKeys.dart';

import '../main.dart';

class CategoryDBService extends BaseService {
  CategoryDBService() {
    ref = db.collection(SERVICE_CATEGORIES);
  }

  Stream<List<CategoryModel>> categories(
      {String searchText = '', isDeleted = false}) {
    Query query = ref;

    if (searchText.isNotEmpty) {
      query = query.where(RestaurantKeys.caseSearch,
          arrayContains: searchText.toLowerCase());
    }

    query = query.orderBy('createdAt',
        descending: true); // Sort by createdAt in descending order

    return query.snapshots().map((x) => x.docs
        .map((y) => CategoryModel.fromJson(y.data() as Map<String, dynamic>))
        .toList());
  }
}
