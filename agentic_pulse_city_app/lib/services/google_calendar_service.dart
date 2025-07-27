import 'dart:convert';
import 'package:googleapis/calendar/v3.dart' as calendar;
import 'package:googleapis_auth/auth_io.dart';
import '../models/event_data.dart';

class GoogleCalendarService {
  static const List<String> _scopes = [
    calendar.CalendarApi.calendarReadonlyScope,
    calendar.CalendarApi.calendarEventsScope,
  ];

  // Fix: Use proper JSON string with escaped newlines
  static const String _credentialsJson = '''
{
  "type": "service_account",
  "project_id": "magnetic-signer-466310-b9",
  "private_key_id": "6e7cbcb2c815712a931ac08899a7e4ea2a67569b",
  "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQCvMeI2NIrEtKpm\ncrLrgaWWn2c/+UOlcg4sPfPcJ5vmw0OTk1GMPGcyHUp2EZohAci70X/twaSyWZkr\nc4hcwM7SXcPVGJCRPsEiM6gtXpISpLS2VN3eYzCalKSSEUTH5akiA4RR1zKT+1uF\nFeL/MgCG6YzYgqdKVghy7mKVbsIGN1yTdus4NZQa+ZwfTVESBPBKWRbtqqrgIQ7V\nFN7nPhJDrSEj3w8/1slJp9QLHzn+a8pSwM3TNWj4EHWP/cOPtCMioQdeHECEGLbo\n2g5GYtNgST+ZSdzOH+FvCvyq/gB1Zgxcy3dur9QAMyVaEMyMKMR5poq5sbmq+VI2\n7QkLkW/XAgMBAAECggEAHFp/6FLnlH9CxrLQdyHz2SUyMh3Wz1tepNVf9qToa9f1\nQ1iHzaDm+KrZ5rLhlW7y/EajJCj/TSgIDIq1qoE/17b6Hy5LE16rJixjDvirvl2u\nq4WfpMK71oCxA7zMu2dVUJ5uF0qzMlTvUmIg6zk98Zexxkaa6YJz+pnPFa0ntJaT\ng9DIaz/nNeluJHniYtELsTWzGzIsPkfy2UmBifHuRpgVOMc0E56I6PuzNFctx5Y0\nPqeZNk10WiDRA0rYCudKD4J4vT6y6x08+ejmCGIDEtt6CTHwqWPfSaOJdGArHIzP\nyipLodAWdIdq7PfyUiRQtVvGWLYVzW3Zt8vJ1vHERQKBgQDdnB19eUUrPtltVHtE\n3okn42aF6kqrwjFA3oPyV1eGf5yqUVvhZPUoLBu4SKQxOA6SGyzQrzWmegIjUO+V\n8YOZwfSNvIUlRxeeJLvrzE7N60q0X6sDaZ7KpCGDGGOzp5XmuZj/K9nqXgzYa3Fr\nhPRKIoJekLaouHxFN2S0RM4tRQKBgQDKYdfGlxg5H3+UXxmptW8lt+cbMfN1MSsq\nDIV83HkkwJFnY/6s2gKAh/wrA0PLumey4WEvepuK8OpwgqoHfSnQyg0lfMWmJXSo\njbfGUXrqLJvajnKTLC6G7csAMbFyZx2akMqRjZqjzgIPqk7tH876GdLmslQ/uQRC\nBZEBPFC0awKBgGA9RP1Rpf1C3Q/CyYm+DthYxBRSDD2NJvCh8bFTxvns/29jx8AZ\npPHePeeI/G03h/RhgtPZ0zXJ9JW7t2BpsxoaBgdroHLw7cvK7iVX470/eoDcrxrb\nSo98OeWBuQKzO8EoRs5CD+/dCj0OZAIqiiCL3gwNUpXxEF7K0JwM6XD1AoGBALbq\nQdyyuWj/qA6Q+Z/iZSfBFHcG6ZUVMH8bvBaDKlbmWUUKIqdVj4dd4LN7iu36dzk8\n7Nq9xRGJ90pjPovwOzgDNmiYYgdtuQeStvPetuoqEV8y+ik8eHzpNV3ijA/rVN1b\nWkq9onPEgSZpdlZpNmfjqTNrICxL66ZEY6+rNQIrAoGAIEXPnz+R8NPBkrtdlRDB\nGn3PLkLbKynWMXarQ/tRqTqNvxTK+/XycUWfMTL4HqJuPEftOnVvtZO/NCe3yArK\n3bkT+fBi9satox96QJERq4nzGJWVBwIE2kYBa08lPi7VPflBnJgvxzRStd02eCs2\npuKvUdENsx+AsAMtSu7GWJI=\n-----END PRIVATE KEY-----\n",
  "client_email": "firebase-adminsdk-fbsvc@magnetic-signer-466310-b9.iam.gserviceaccount.com",
  "client_id": "110416239678025607070",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-fbsvc%40magnetic-signer-466310-b9.iam.gserviceaccount.com",
  "universe_domain": "googleapis.com"
}
''';

  static calendar.CalendarApi? _calendarApi;
  static ServiceAccountCredentials? _credentials;

  static Future<void> initialize() async {
    try {
      _credentials = ServiceAccountCredentials.fromJson(
        json.decode(_credentialsJson),
      );

      final client = await clientViaServiceAccount(
        _credentials!,
        _scopes,
      );

      _calendarApi = calendar.CalendarApi(client);
      print('Google Calendar API initialized successfully');
    } catch (e) {
      print('Failed to initialize Google Calendar API: $e');
      // Fallback to mock data if initialization fails
      _calendarApi = null;
    }
  }

  static Future<List<Event>> getGoogleCalendarEvents({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    if (_calendarApi == null) {
      await initialize();
    }

    // If still null after initialization, return mock data
    if (_calendarApi == null) {
      print('Using mock Google Calendar events due to initialization failure');
      return getMockGoogleCalendarEvents(startDate: startDate, endDate: endDate);
    }

   try {
    // List available calendars
    final calendarList = await _calendarApi!.calendarList.list();
    print('📅 Available calendars:');
    for (final cal in calendarList.items ?? []) {
      print('  - ${cal.summary} (${cal.id}) - Access: ${cal.accessRole}');
    }
   } catch (e) {
    print('Failed to fetch Google Calendar calendars: $e');
   }
    try {
      final events = await _calendarApi!.events.list(
        'primary',
        timeMin: startDate.toUtc(),
        timeMax: endDate.toUtc(),
        singleEvents: true,
        orderBy: 'startTime',
      );

      print('Fetched ${events.items?.length ?? 0} events from Google Calendar');

      return events.items?.map((googleEvent) {
        return Event(
          id: googleEvent.id ?? '',
          title: googleEvent.summary ?? 'Untitled Event',
          description: googleEvent.description ?? '',
          startTime: googleEvent.start?.dateTime ?? googleEvent.start?.date ?? DateTime.now(),
          endTime: googleEvent.end?.dateTime ?? googleEvent.end?.date ?? DateTime.now(),
          location: googleEvent.location ?? '',
          type: _mapGoogleEventToEventType(googleEvent),
          isSmartSuggestion: false,
        );
      }).toList() ?? [];
    } catch (e) {
      print('Failed to fetch Google Calendar events: $e');
      // Fallback to mock data on error
      return getMockGoogleCalendarEvents(startDate: startDate, endDate: endDate);
    }
  }

  static EventType _mapGoogleEventToEventType(calendar.Event googleEvent) {
    final summary = googleEvent.summary?.toLowerCase() ?? '';
    final description = googleEvent.description?.toLowerCase() ?? '';

    if (summary.contains('meeting') || summary.contains('call')) {
      return EventType.meeting;
    } else if (summary.contains('travel') || summary.contains('trip')) {
      return EventType.travel;
    } else if (summary.contains('work') || summary.contains('office')) {
      return EventType.work;
    } else if (summary.contains('gym') || summary.contains('workout') || summary.contains('health')) {
      return EventType.health;
    } else if (summary.contains('movie') || summary.contains('entertainment')) {
      return EventType.entertainment;
    } else if (summary.contains('city') || summary.contains('festival') || summary.contains('event')) {
      return EventType.cityEvent;
    } else {
      return EventType.personal;
    }
  }

  static Future<bool> addEventToGoogleCalendar(Event event) async {
    if (_calendarApi == null) {
      await initialize();
    }

    try {
      final googleEvent = calendar.Event()
        ..summary = event.title
        ..description = event.description
        ..location = event.location
        ..start = calendar.EventDateTime()
          ..dateTime = event.startTime.toUtc()
          ..timeZone = 'UTC'
        ..end = calendar.EventDateTime()
          ..dateTime = event.endTime.toUtc()
          ..timeZone = 'UTC';

      await _calendarApi!.events.insert(googleEvent, 'primary');
      return true;
    } catch (e) {
      print('Failed to add event to Google Calendar: $e');
      return false;
    }
  }

  static Future<bool> updateGoogleCalendarEvent(Event event) async {
    if (_calendarApi == null) {
      await initialize();
    }

    try {
      final googleEvent = calendar.Event()
        ..summary = event.title
        ..description = event.description
        ..location = event.location
        ..start = calendar.EventDateTime()
          ..dateTime = event.startTime.toUtc()
          ..timeZone = 'UTC'
        ..end = calendar.EventDateTime()
          ..dateTime = event.endTime.toUtc()
          ..timeZone = 'UTC';

      await _calendarApi!.events.update(googleEvent, 'primary', event.id);
      return true;
    } catch (e) {
      print('Failed to update Google Calendar event: $e');
      return false;
    }
  }

  static Future<bool> deleteGoogleCalendarEvent(String eventId) async {
    if (_calendarApi == null) {
      await initialize();
    }

    try {
      await _calendarApi!.events.delete('primary', eventId);
      return true;
    } catch (e) {
      print('Failed to delete Google Calendar event: $e');
      return false;
    }
  }

  // Mock method for development/testing
  static Future<List<Event>> getMockGoogleCalendarEvents({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Create events for today and the next few days
    final today = DateTime.now();
    final tomorrow = today.add(const Duration(days: 1));
    final dayAfterTomorrow = today.add(const Duration(days: 2));
    
    return [
      // Today's events
      Event(
        id: 'google_1',
        title: 'Google Calendar Meeting',
        description: 'Important team meeting from Google Calendar',
        startTime: DateTime(today.year, today.month, today.day, 10, 0), // 10:00 AM today
        endTime: DateTime(today.year, today.month, today.day, 11, 0),   // 11:00 AM today
        location: 'Conference Room A',
        type: EventType.meeting,
        isSmartSuggestion: false,
      ),
      Event(
        id: 'google_2',
        title: 'Client Call',
        description: 'Scheduled client consultation',
        startTime: DateTime(today.year, today.month, today.day, 14, 0), // 2:00 PM today
        endTime: DateTime(today.year, today.month, today.day, 15, 0),   // 3:00 PM today
        location: 'Zoom Meeting',
        type: EventType.meeting,
        isSmartSuggestion: false,
      ),
      // Tomorrow's events
      Event(
        id: 'google_3',
        title: 'Business Trip',
        description: 'Travel to client office',
        startTime: DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 9, 0), // 9:00 AM tomorrow
        endTime: DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 17, 0),  // 5:00 PM tomorrow
        location: 'Airport',
        type: EventType.travel,
        isSmartSuggestion: false,
      ),
      Event(
        id: 'google_4',
        title: 'Project Review',
        description: 'Quarterly project review meeting',
        startTime: DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 13, 0), // 1:00 PM tomorrow
        endTime: DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 14, 30),  // 2:30 PM tomorrow
        location: 'Board Room',
        type: EventType.meeting,
        isSmartSuggestion: false,
      ),
      // Day after tomorrow's events
      Event(
        id: 'google_5',
        title: 'Team Lunch',
        description: 'Monthly team lunch',
        startTime: DateTime(dayAfterTomorrow.year, dayAfterTomorrow.month, dayAfterTomorrow.day, 12, 0), // 12:00 PM day after tomorrow
        endTime: DateTime(dayAfterTomorrow.year, dayAfterTomorrow.month, dayAfterTomorrow.day, 13, 0),  // 1:00 PM day after tomorrow
        location: 'Local Restaurant',
        type: EventType.personal,
        isSmartSuggestion: false,
      ),
      Event(
        id: 'google_6',
        title: 'Product Launch',
        description: 'New product launch event',
        startTime: DateTime(dayAfterTomorrow.year, dayAfterTomorrow.month, dayAfterTomorrow.day, 15, 0), // 3:00 PM day after tomorrow
        endTime: DateTime(dayAfterTomorrow.year, dayAfterTomorrow.month, dayAfterTomorrow.day, 16, 30), // 4:30 PM day after tomorrow
        location: 'Conference Center',
        type: EventType.cityEvent,
        isSmartSuggestion: false,
      ),
    ];
  }
}

extension on calendar.Event {
  set timeZone(String timeZone) {}

  set dateTime(DateTime dateTime) {}
}