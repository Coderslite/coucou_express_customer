import 'dart:math';

import 'package:google_maps_flutter/google_maps_flutter.dart';

double calculateDistance(LatLng start, LatLng end) {
  const int radiusOfEarth = 6371; // in kilometers

  double lat1 = degreesToRadians(start.latitude);
  double lon1 = degreesToRadians(start.longitude);
  double lat2 = degreesToRadians(end.latitude);
  double lon2 = degreesToRadians(end.longitude);

  double dLat = lat2 - lat1;
  double dLon = lon2 - lon1;

  double a =
      pow(sin(dLat / 2), 2) + cos(lat1) * cos(lat2) * pow(sin(dLon / 2), 2);
  double c = 2 * atan2(sqrt(a), sqrt(1 - a));

  double distance = radiusOfEarth * c;
  return distance;
}

double degreesToRadians(double degrees) {
  return degrees * (pi / 180);
}
