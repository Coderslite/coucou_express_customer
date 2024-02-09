import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';

Future<LatLng> getLatLngFromLocationName(String locationName) async {
  final String apiUrl = 'https://maps.googleapis.com/maps/api/geocode/json';
  var apiKey = 'AIzaSyAIcCd-I5JKJi84dUGWYVRAB5NVpTj0I6A';
  print(locationName);
  final response =
      await http.get(Uri.parse('$apiUrl?address=$locationName&key=$apiKey'));

  if (response.statusCode == 200) {
    final Map<String, dynamic> data = json.decode(response.body);
    final results = data['results'] as List<dynamic>;

    if (results.isNotEmpty) {
      final location = results[0]['geometry']['location'];
      final double latitude = location['lat'];
      final double longitude = location['lng'];

      return LatLng(latitude, longitude);
    }
  } else {
    print('Error occurred: ${response.reasonPhrase}');
  }

  return LatLng(0, 0);
}
