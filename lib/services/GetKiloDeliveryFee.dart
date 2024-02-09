import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fooddelivery/models/FixedDeliveryFeeModel.dart';

Future<FixedDeliveryFeeModel> getKiloDeliveryFee() async {
  var result =
      await FirebaseFirestore.instance.collection("fixedDeliveryFee").where('type',isEqualTo: 'kmCharge').get();
  var data = result.docs.first.data();
  return FixedDeliveryFeeModel.fromJson(data);
}
