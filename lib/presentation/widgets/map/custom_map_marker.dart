// lib/presentation/widgets/map/custom_map_marker.dart
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class CustomMapMarker {
  static Future<BitmapDescriptor> createCustomMarker({
    required String title,
    required Color color,
    required IconData icon,
  }) async {
    // For custom PNG markers, return BitmapDescriptor.fromAssetImage()
    // For now using default colored markers
    switch (color) {
      case Colors.blue:
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
      case Colors.purple:
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue);
      case Colors.orange:
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange);
      case Colors.red:
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet);
      default:
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow);
    }
  }
}