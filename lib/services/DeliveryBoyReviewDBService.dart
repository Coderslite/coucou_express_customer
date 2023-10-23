import 'package:fooddelivery/utils/Constants.dart';
import 'package:fooddelivery/utils/ModalKeys.dart';

import '../main.dart';
import 'BaseService.dart';

class DeliveryBoyReviewsDBService extends BaseService {
  DeliveryBoyReviewsDBService({String? restId}) {
    ref = db.collection(DELIVERY_BOY_REVIEWS);
  }

  /*Future<bool> deliveryBoyReviews({String? orderID}) async {
    Query query = ref.limit(1).where(OrderKeys.orderId, isEqualTo: orderID);
    var res = await query.get();
    if (res.docs.isNotEmpty) {
      return res.docs.length == 1;
    } else {
      return false;
    }
  }*/
  Stream<bool> deliveryBoyReviews({String? orderID}) {
    return ref.where(OrderKeys.orderId, isEqualTo: orderID).limit(1).snapshots().map((value) {
      if (value.docs.isNotEmpty) {
        return true;
      } else {
        return false;
      }
    });
  }
}
