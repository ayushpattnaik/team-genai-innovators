import 'package:google_maps_flutter/google_maps_flutter.dart';

class SentimentData {
  final LatLng location;
  final double sentiment; // Range from -1.0 (negative) to 1.0 (positive)
  final String description;

  SentimentData({
    required this.location,
    required this.sentiment,
    required this.description,
  });
}