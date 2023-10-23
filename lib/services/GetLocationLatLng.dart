import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

Future<LatLng> getLatLngFromLocationName(String locationName) async {
  try {
    List<Location> locations = await locationFromAddress(locationName);
    if (locations.isNotEmpty) {
      Location location = locations.first;
      LatLng latLng = LatLng(location.latitude, location.longitude);
      return latLng;
    }
  } catch (e) {
    print('Error occurred: $e');
  }
  return LatLng(0, 0);
}
