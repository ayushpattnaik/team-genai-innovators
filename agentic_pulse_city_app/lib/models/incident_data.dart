import 'package:google_maps_flutter/google_maps_flutter.dart';

class IncidentData {
  final LatLng location;
  final String type; // e.g., 'traffic', 'event', 'hazard'
  final String description;
  final String source; // 'user', 'reddit', 'twitter'
  final DateTime timestamp;

  IncidentData({
    required this.location,
    required this.type,
    required this.description,
    required this.source,
    required this.timestamp,
  });
}