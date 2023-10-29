import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fooddelivery/function/send_push_notification.dart';

void availableDrivers(String orderId) async {
  List tokens = [];
  FirebaseFirestore.instance
      .collection("users")
      .where('role', isEqualTo: 'DeliveryBoy')
      .where('availabilityStatus', isEqualTo: true)
      .get()
      .then((value) {
    for (var driver in value.docs) {
      var token = driver.data()['oneSignalPlayerId'];
      print(token);
      tokens.add(token);
      sendNotification(tokens,"New Order Available","A new order has been placed by a customer",orderId);
    }
  });
}
