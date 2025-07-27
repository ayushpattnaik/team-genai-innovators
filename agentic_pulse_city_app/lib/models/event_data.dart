 import 'package:intl/intl.dart';

class Event {
  final String id;
  final String title;
  final String description;
  final DateTime startTime;
  final DateTime endTime;
  final String location;
  final String? weatherInfo;
  final String? travelInfo;
  final EventType type;
  final bool isSmartSuggestion;

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.startTime,
    required this.endTime,
    required this.location,
    this.weatherInfo,
    this.travelInfo,
    required this.type,
    this.isSmartSuggestion = false,
  });

  String get formattedStartTime => DateFormat('HH:mm').format(startTime);
  String get formattedEndTime => DateFormat('HH:mm').format(endTime);
  String get formattedDate => DateFormat('MMM dd, yyyy').format(startTime);
  String get dayOfWeek => DateFormat('EEEE').format(startTime);
}

enum EventType {
  meeting,
  travel,
  weather,
  cityEvent,
  personal,
  work,
  health,
  entertainment,
}

class WeatherInfo {
  final double temperature;
  final String condition;
  final int humidity;
  final double windSpeed;
  final String icon;

  WeatherInfo({
    required this.temperature,
    required this.condition,
    required this.humidity,
    required this.windSpeed,
    required this.icon,
  });
}

class TravelInfo {
  final String mode;
  final int duration;
  final double distance;
  final String route;
  final String? alert;

  TravelInfo({
    required this.mode,
    required this.duration,
    required this.distance,
    required this.route,
    this.alert,
  });
}

class UserInsight {
  final String title;
  final String description;
  final InsightType type;
  final DateTime timestamp;
  final Map<String, dynamic> data;

  UserInsight({
    required this.title,
    required this.description,
    required this.type,
    required this.timestamp,
    required this.data,
  });
}

enum InsightType {
  weather,
  traffic,
  event,
  routine,
  health,
  productivity,
}