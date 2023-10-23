import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fooddelivery/models/OrderModel.dart';
import 'package:fooddelivery/services/BaseService.dart';
import 'package:fooddelivery/utils/Constants.dart';
import 'package:fooddelivery/utils/ModalKeys.dart';

import '../main.dart';

class MyOrderDBService extends BaseService {
  MyOrderDBService() {
    ref = db.collection(ORDERS);
  }

  Future<OrderModel> getOrderById(String? id) async {
    return await ref.where('id', isEqualTo: id).limit(1).get().then((value) {
      if (value.docs.isNotEmpty) {
        return OrderModel.fromJson(value.docs.first.data() as Map<String, dynamic>);
      } else {
        throw appStore.translate('order_not_found');
      }
    });
  }

  Stream<OrderModel> orderById({String? id}) {
    return ref.where('id', isEqualTo: id).limit(1).snapshots().map((value) {
      if (value.docs.isNotEmpty) {
        return OrderModel.fromJson(value.docs.first.data() as Map<String, dynamic>);
      } else {
        throw appStore.translate('order_not_found');
      }
    });
  }

  Stream<List<OrderModel>> orders({String orderId = ''}) {
    return orderQuery(orderId: orderId).orderBy(CommonKeys.createdAt, descending: false).snapshots().map((x) => x.docs.map((y) => OrderModel.fromJson(y.data() as Map<String, dynamic>)).toList());
  }

  Query orderQuery({String orderId = ''}) {
    if (orderId.isEmpty) {
      return ref.where(OrderKeys.userId, isEqualTo: appStore.userId);
    } else {
      return ref.where(OrderKeys.orderId, isEqualTo: orderId);
    }
  }
}
