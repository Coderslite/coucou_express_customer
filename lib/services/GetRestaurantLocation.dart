// import 'dart:convert';

// import 'package:flutter/material.dart';
// import 'package:geocoding/geocoding.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:http/http.dart' as http;
// import 'package:google_maps_webservice/src/places.dart';

// Future<List<Prediction>> searchLocation(
//     BuildContext context, String text) async {
//   if (text.isEmpty) {
//     return [];
//   } else {
//     http.Response response = await http.get(
//       Uri.parse(
//           "http://mvs.bslmeiyu.com/api/v1/config/place-api-autocomplete?search_text=$text"),
//     );
//     var data = jsonDecode(response.body.toString());
//     print(data);
//     List predictions = data['predictions'];
//     return predictions.map((e) => Prediction.fromJson(e)).toList();
//   }
// }
