
import 'package:shared_preferences/shared_preferences.dart';
import '../models/event_data.dart';
import 'google_calendar_service.dart';

class CalendarService {
  static const String _weatherApiKey = 'YOUR_WEATHER_API_KEY';
  static const String _baseWeatherUrl = 'https://api.openweathermap.org/data/2.5';

  // Mock data for demonstration - replace with real calendar API integration
  static List<Event> getMockEvents() {
    return [
      Event(
        id: '1',
        title: 'Team Meeting',
        description: 'Weekly team sync',
        startTime: DateTime.now().add(const Duration(hours: 2)),
        endTime: DateTime.now().add(const Duration(hours: 3)),
        location: 'Downtown Office',
        type: EventType.meeting,
        weatherInfo: 'Partly cloudy, 22°C',
        travelInfo: '15 min by car, traffic moderate',
      ),
      Event(
        id: '2',
        title: 'City Festival',
        description: 'Annual city celebration',
        startTime: DateTime.now().add(const Duration(days: 1)),
        endTime: DateTime.now().add(const Duration(days: 1, hours: 4)),
        location: 'Central Park',
        type: EventType.cityEvent,
        weatherInfo: 'Sunny, 25°C',
        travelInfo: '20 min by bus',
      ),
      Event(
        id: '3',
        title: 'Gym Session',
        description: 'Regular workout routine',
        startTime: DateTime.now().add(const Duration(hours: 6)),
        endTime: DateTime.now().add(const Duration(hours: 7)),
        location: 'Fitness Center',
        type: EventType.health,
        weatherInfo: 'Clear, 20°C',
        travelInfo: '10 min walk',
      ),
    ];
  }

  static Future<List<Event>> getEventsForDate(DateTime date) async {
    // Get local events
    final localEvents = getMockEvents();
    print('📅 Local events: ${localEvents.length}');
    
    // Get Google Calendar events for the month
    final startOfMonth = DateTime(date.year, date.month, 1);
    final endOfMonth = DateTime(date.year, date.month + 1, 0);
    
    List<Event> googleEvents = [];
    try {
      // Toggle this line: true = use mock, false = use real Google Calendar
      const bool useMockEvents = true;
      
      if (useMockEvents) {
        googleEvents = await GoogleCalendarService.getMockGoogleCalendarEvents(
          startDate: startOfMonth,
          endDate: endOfMonth,
        );
        print('📅 Mock Google events: ${googleEvents.length}');
      } else {
        googleEvents = await GoogleCalendarService.getGoogleCalendarEvents(
          startDate: startOfMonth,
          endDate: endOfMonth,
        );
      }
    } catch (e) {
      print('Failed to fetch Google Calendar events: $e');
    }

    // Combine local and Google Calendar events
    final allEvents = [...localEvents, ...googleEvents];
    print('📅 Total events: ${allEvents.length}');
    
    final filteredEvents = allEvents.where((event) {
      final isSameDay = event.startTime.year == date.year &&
             event.startTime.month == date.month &&
             event.startTime.day == date.day;
      
      if (isSameDay) {
        print('📅 Event for ${date.day}/${date.month}: ${event.title}');
      }
      
      return isSameDay;
    }).toList();
    
    print('📅 Filtered events for ${date.day}/${date.month}: ${filteredEvents.length}');
    return filteredEvents;
  }

  static Future<List<Event>> getSmartSuggestions() async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    return [
      Event(
        id: 'suggestion_1',
        title: 'Coffee Break',
        description: 'Based on your routine, you usually take a break now',
        startTime: DateTime.now().add(const Duration(minutes: 30)),
        endTime: DateTime.now().add(const Duration(hours: 1)),
        location: 'Local Coffee Shop',
        type: EventType.personal,
        isSmartSuggestion: true,
        weatherInfo: 'Perfect weather for outdoor seating',
      ),
      Event(
        id: 'suggestion_2',
        title: 'Evening Walk',
        description: 'Great weather for your usual evening walk',
        startTime: DateTime.now().add(const Duration(hours: 4)),
        endTime: DateTime.now().add(const Duration(hours: 5)),
        location: 'Riverside Park',
        type: EventType.health,
        isSmartSuggestion: true,
        weatherInfo: 'Clear skies, 18°C - perfect for walking',
      ),
    ];
  }

  static Future<WeatherInfo> getWeatherForLocation(String location) async {
    try {
      await Future.delayed(const Duration(milliseconds: 200));
      
      return WeatherInfo(
        temperature: 22.0,
        condition: 'Partly Cloudy',
        humidity: 65,
        windSpeed: 12.0,
        icon: 'partly-cloudy-day',
      );
    } catch (e) {
      return WeatherInfo(
        temperature: 20.0,
        condition: 'Unknown',
        humidity: 50,
        windSpeed: 0.0,
        icon: 'unknown',
      );
    }
  }

  static Future<TravelInfo> getTravelInfo(String from, String to) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    return TravelInfo(
      mode: 'Car',
      duration: 15,
      distance: 5.2,
      route: 'Via Main Street',
      alert: 'Moderate traffic on Main Street',
    );
  }

  static Future<List<UserInsight>> getUserInsights() async {
    await Future.delayed(const Duration(milliseconds: 400));
    
    return [
      UserInsight(
        title: 'Productivity Peak',
        description: 'You\'re most productive between 9-11 AM',
        type: InsightType.productivity,
        timestamp: DateTime.now(),
        data: {'peak_hours': '9-11 AM', 'productivity_score': 85},
      ),
      UserInsight(
        title: 'Weather Impact',
        description: 'Your mood improves by 20% on sunny days',
        type: InsightType.weather,
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        data: {'mood_improvement': 20, 'weather_condition': 'sunny'},
      ),
      UserInsight(
        title: 'Routine Pattern',
        description: 'You visit the gym 3 times per week on average',
        type: InsightType.routine,
        timestamp: DateTime.now().subtract(const Duration(days: 2)),
        data: {'frequency': 3, 'activity': 'gym'},
      ),
    ];
  }

  static Future<void> saveUserPreference(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is String) {
      await prefs.setString(key, value);
    } else if (value is int) {
      await prefs.setInt(key, value);
    } else if (value is bool) {
      await prefs.setBool(key, value);
    } else if (value is double) {
      await prefs.setDouble(key, value);
    }
  }

  static Future<dynamic> getUserPreference(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.get(key);
  }

  // New method to sync with Google Calendar
  static Future<void> syncWithGoogleCalendar() async {
    try {
      await GoogleCalendarService.initialize();
      // This will trigger a refresh of events
    } catch (e) {
      print('Failed to sync with Google Calendar: $e');
    }
  }

  // New method to add event to Google Calendar
  static Future<bool> addEventToGoogleCalendar(Event event) async {
    try {
      return await GoogleCalendarService.addEventToGoogleCalendar(event);
    } catch (e) {
      print('Failed to add event to Google Calendar: $e');
      return false;
    }
  }
}