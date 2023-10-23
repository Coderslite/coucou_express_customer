import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fooddelivery/models/AdModel.dart';
import 'package:fooddelivery/services/BaseService.dart';
import 'package:fooddelivery/utils/Constants.dart';

import '../main.dart';
import '../models/FoodModel.dart';

class AdvertDBService extends BaseService {
  AdvertDBService() {
    ref = db.collection(ADVERTS);
  }

  Stream<List<AdModel>> adverts() {
    Query query = ref;


    query = query.orderBy('createdAt',
        descending: true); // Sort by createdAt in descending order

    return query.snapshots().map((x) => x.docs
        .map((y) => AdModel.fromJson(y.data() as Map<String, dynamic>))
        .toList());
  }
}
