// import 'dart:convert';

// import 'package:google_maps_flutter/google_maps_flutter.dart';

// import '../services/GetLocationLatLng.dart';
// import '../utils/Constants.dart';
// import 'package:http/http.dart' as http;

// class SendNotification {
//   static handleSentToAgent(
//     String orderDocId,
//   ) async {
//     print(orderDocId);

//     LatLng restaurantLocation = UCAD_LOCATION;
//     print(restaurantLocation);
//     var response = await http.post(Uri.parse("$FIREBASE_URL/assign-to-agent"),
//         headers: <String, String>{
//           'Content-Type': 'application/json',
//         },
//         body: jsonEncode(<String, dynamic>{
//           "restaurantLatitude": restaurantLocation.latitude,
//           "restaurantLongitude": restaurantLocation.longitude,
//           "id": orderDocId,
//         }));
//     print(response.body);
//   }
// }
