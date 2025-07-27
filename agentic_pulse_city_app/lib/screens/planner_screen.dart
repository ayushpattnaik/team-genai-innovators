import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../models/event_data.dart';
import '../services/calendar_service.dart';
import '../services/google_calendar_service.dart'; // Add this import

class PlannerScreen extends StatefulWidget {
  const PlannerScreen({super.key});

  @override
  State<PlannerScreen> createState() => _PlannerScreenState();
}

class _PlannerScreenState extends State<PlannerScreen> {
  late DateTime _focusedDay;
  late DateTime _selectedDay;
  late CalendarFormat _calendarFormat;
  Map<DateTime, List<Event>> _events = {};
  List<Event> _selectedEvents = [];
  List<UserInsight> _insights = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _selectedDay = DateTime.now();
    _calendarFormat = CalendarFormat.month;
    _loadData();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    
    setState(() => _isLoading = true);
    
    try {
      // Load events for the current month
      await _loadEventsForMonth(_focusedDay);
      
      // Load insights
      final insights = await CalendarService.getUserInsights();
      
      if (mounted) {
        setState(() {
          _insights = insights;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      print('Error loading data: $e');
    }
  }

  Future<void> _loadEventsForMonth(DateTime month) async {
    if (!mounted) return;
    
    try {
      // Load events for the entire month, not just one day
      final startOfMonth = DateTime(month.year, month.month, 1);
      final endOfMonth = DateTime(month.year, month.month + 1, 0);
      
      // Get all events for the month
      final allEvents = <Event>[];
      
      // Get local events
      final localEvents = CalendarService.getMockEvents();
      allEvents.addAll(localEvents);
      
      // Get Google Calendar events
      final googleEvents = await GoogleCalendarService.getMockGoogleCalendarEvents(
        startDate: startOfMonth,
        endDate: endOfMonth,
      );
      allEvents.addAll(googleEvents);
      
      // Get smart suggestions
      final smartSuggestions = await CalendarService.getSmartSuggestions();
      allEvents.addAll(smartSuggestions);
      
      if (mounted) {
        setState(() {
          _events = {};
          for (final event in allEvents) {
            // Normalize the date key to remove time components
            final date = DateTime(event.startTime.year, event.startTime.month, event.startTime.day);
            if (_events[date] == null) _events[date] = [];
            _events[date]!.add(event);
          }
          
          // Normalize the selected day as well
          final normalizedSelectedDay = DateTime(_selectedDay.year, _selectedDay.month, _selectedDay.day);
          _selectedEvents = _getEventsForDay(normalizedSelectedDay);
          
          // Debug: Print events for current day
          print('📅 Events for ${_selectedDay.day}/${_selectedDay.month}: ${_selectedEvents.length}');
          print('📅 Normalized selected day: ${normalizedSelectedDay.day}/${normalizedSelectedDay.month}');
          for (final event in _selectedEvents) {
            print('  - ${event.title} (${event.startTime.hour}:${event.startTime.minute})');
          }
          
          // Debug: Print all events in the map
          print('📅 All events in map:');
          _events.forEach((date, events) {
            print('  ${date.day}/${date.month}: ${events.length} events');
          });
        });
      }
    } catch (e) {
      print('Error loading events for month: $e');
    }
  }

  List<Event> _getEventsForDay(DateTime day) {
    // Normalize the day to remove time components
    final normalizedDay = DateTime(day.year, day.month, day.day);
    final events = _events[normalizedDay] ?? [];
    print('📅 _getEventsForDay called for ${day.day}/${day.month} -> ${normalizedDay.day}/${normalizedDay.month}: ${events.length} events');
    return events;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white.withOpacity(0.95),
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4299E1), Color(0xFF3182CE)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.calendar_today, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Text(
              'Smart Planner',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: const Color(0xFF2D3748),
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF4299E1).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.insights, color: Color(0xFF4299E1)),
              onPressed: () => _showInsightsModal(context),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF4299E1).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.settings, color: Color(0xFF4299E1)),
              onPressed: () => _showSettingsModal(context),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF4299E1),
              ),
            )
          : Column(
              children: [
                _buildCalendar(),
                _buildTodaySummary(),
                Expanded(child: _buildEventsList()),
              ],
            ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF4299E1), Color(0xFF3182CE)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF4299E1).withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () => _showAddEventModal(context),
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildCalendar() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TableCalendar<Event>(
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: _focusedDay,
        calendarFormat: _calendarFormat,
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        eventLoader: _getEventsForDay,
        onDaySelected: (selectedDay, focusedDay) {
          if (mounted) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
              final normalizedSelectedDay = DateTime(selectedDay.year, selectedDay.month, selectedDay.day);
              _selectedEvents = _getEventsForDay(normalizedSelectedDay);
            });
          }
        },
        onFormatChanged: (format) {
          if (mounted) {
            setState(() {
              _calendarFormat = format;
            });
          }
        },
        onPageChanged: (focusedDay) {
          _focusedDay = focusedDay;
          _loadEventsForMonth(focusedDay);
        },
        calendarStyle: CalendarStyle(
          markersMaxCount: 2, // Reduced from 3
          markerDecoration: const BoxDecoration(
            color: Color(0xFF4299E1),
            shape: BoxShape.circle,
          ),
          selectedDecoration: const BoxDecoration(
            color: Color(0xFF4299E1),
            shape: BoxShape.circle,
          ),
          todayDecoration: BoxDecoration(
            color: const Color(0xFF4299E1).withOpacity(0.3),
            shape: BoxShape.circle,
          ),
          weekendTextStyle: const TextStyle(color: Color(0xFF4299E1)),
          // Even smaller cell margin
          cellMargin: const EdgeInsets.all(1),
          // Minimal header margin
          markerMargin: const EdgeInsets.only(bottom: 4),
          // Smaller day text size
          defaultTextStyle: const TextStyle(fontSize: 11),
          selectedTextStyle: const TextStyle(color: Colors.white, fontSize: 11),
          todayTextStyle: const TextStyle(color: Color(0xFF4299E1), fontSize: 11, fontWeight: FontWeight.bold),
          // Even smaller markers
          markerSize: 4,
          // Reduce outside days visibility
          outsideDaysVisible: false,
        ),
        headerStyle: const HeaderStyle(
          formatButtonVisible: true,
          titleCentered: true,
          formatButtonShowsNext: false,
          formatButtonDecoration: BoxDecoration(
            color: Color(0xFF4299E1),
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
          formatButtonTextStyle: TextStyle(color: Colors.white, fontSize: 12),
          // Minimal header padding
          headerPadding: EdgeInsets.symmetric(vertical: 4),
          titleTextStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF2D3748)),
          leftChevronIcon: Icon(Icons.chevron_left, color: Color(0xFF4299E1), size: 20),
          rightChevronIcon: Icon(Icons.chevron_right, color: Color(0xFF4299E1), size: 20),
        ),
        // Even smaller row height
        rowHeight: 32,
      ),
    );
  }

  Widget _buildTodaySummary() {
    final today = DateTime.now();
    final isToday = isSameDay(_selectedDay, today);
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: isToday 
          ? const LinearGradient(
              colors: [Color(0xFF4299E1), Color(0xFF3182CE)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            )
          : null,
        color: isToday ? null : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
        border: isToday ? null : Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isToday ? Colors.white.withOpacity(0.2) : const Color(0xFF4299E1).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isToday ? Icons.today : Icons.calendar_today,
              color: isToday ? Colors.white : const Color(0xFF4299E1),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isToday ? 'Today' : DateFormat('EEEE, MMM dd').format(_selectedDay),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: isToday ? Colors.white : const Color(0xFF2D3748),
                  ),
                ),
                Text(
                  '${_selectedEvents.length} events scheduled',
                  style: TextStyle(
                    color: isToday ? Colors.white.withOpacity(0.8) : Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          if (_selectedEvents.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isToday ? Colors.white.withOpacity(0.2) : const Color(0xFF4299E1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${_selectedEvents.length}',
                style: TextStyle(
                  color: isToday ? Colors.white : Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEventsList() {
    if (_selectedEvents.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_busy,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'No events for ${DateFormat('MMM dd').format(_selectedDay)}',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => _showAddEventModal(context),
              child: const Text('Add Event'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _selectedEvents.length,
      itemBuilder: (context, index) {
        final event = _selectedEvents[index];
        return _buildEventCard(event);
      },
    );
  }

  Widget _buildEventCard(Event event) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(20),
        leading: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                _getEventColor(event.type),
                _getEventColor(event.type).withOpacity(0.7),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: _getEventColor(event.type).withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(
            _getEventIcon(event.type),
            color: Colors.white,
            size: 24,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                event.title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Color(0xFF2D3748),
                ),
              ),
            ),
            if (event.isSmartSuggestion)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFFF9800), Color(0xFFF57C00)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
                child: const Text(
                  'Smart',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            Text(
              event.description,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),
            // Use Wrap instead of Row for info chips
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildInfoChip(Icons.access_time, '${event.formattedStartTime} - ${event.formattedEndTime}'),
                _buildInfoChip(Icons.location_on, event.location),
              ],
            ),
            if (event.weatherInfo != null) ...[
              const SizedBox(height: 8),
              _buildInfoChip(Icons.wb_sunny, event.weatherInfo!),
            ],
            if (event.travelInfo != null) ...[
              const SizedBox(height: 8),
              _buildInfoChip(Icons.directions_car, event.travelInfo!),
            ],
          ],
        ),
        onTap: () => _showEventDetails(context, event),
      ),
    );
  }

  Color _getEventColor(EventType type) {
    switch (type) {
      case EventType.meeting:
        return Colors.blue;
      case EventType.travel:
        return Colors.green;
      case EventType.weather:
        return Colors.orange;
      case EventType.cityEvent:
        return Colors.purple;
      case EventType.personal:
        return Colors.pink;
      case EventType.work:
        return Colors.indigo;
      case EventType.health:
        return Colors.teal;
      case EventType.entertainment:
        return Colors.amber;
    }
  }

  IconData _getEventIcon(EventType type) {
    switch (type) {
      case EventType.meeting:
        return Icons.meeting_room;
      case EventType.travel:
        return Icons.directions_car;
      case EventType.weather:
        return Icons.wb_sunny;
      case EventType.cityEvent:
        return Icons.location_city;
      case EventType.personal:
        return Icons.person;
      case EventType.work:
        return Icons.work;
      case EventType.health:
        return Icons.favorite;
      case EventType.entertainment:
        return Icons.movie;
    }
  }

  void _showEventDetails(BuildContext context, Event event) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _getEventColor(event.type).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getEventIcon(event.type),
                      color: _getEventColor(event.type),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          event.title,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          event.dayOfWeek,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                event.description,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              _buildDetailRow(Icons.access_time, 'Time', '${event.formattedStartTime} - ${event.formattedEndTime}'),
              _buildDetailRow(Icons.location_on, 'Location', event.location),
              if (event.weatherInfo != null)
                _buildDetailRow(Icons.wb_sunny, 'Weather', event.weatherInfo!),
              if (event.travelInfo != null)
                _buildDetailRow(Icons.directions_car, 'Travel', event.travelInfo!),
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // Add to calendar functionality
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                      ),
                      child: const Text('Add to Calendar'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey.shade600),
          const SizedBox(width: 12),
          Text(
            '$label: ',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  void _showInsightsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Smart Insights',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: _insights.length,
                  itemBuilder: (context, index) {
                    final insight = _insights[index];
                    return _buildInsightCard(insight);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInsightCard(UserInsight insight) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _getInsightIcon(insight.type),
                color: _getInsightColor(insight.type),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  insight.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            insight.description,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            DateFormat('MMM dd, HH:mm').format(insight.timestamp),
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getInsightIcon(InsightType type) {
    switch (type) {
      case InsightType.weather:
        return Icons.wb_sunny;
      case InsightType.traffic:
        return Icons.traffic;
      case InsightType.event:
        return Icons.event;
      case InsightType.routine:
        return Icons.schedule;
      case InsightType.health:
        return Icons.favorite;
      case InsightType.productivity:
        return Icons.trending_up;
    }
  }

  Color _getInsightColor(InsightType type) {
    switch (type) {
      case InsightType.weather:
        return Colors.orange;
      case InsightType.traffic:
        return Colors.red;
      case InsightType.event:
        return Colors.purple;
      case InsightType.routine:
        return Colors.blue;
      case InsightType.health:
        return Colors.green;
      case InsightType.productivity:
        return Colors.indigo;
    }
  }

  void _showSettingsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Planner Settings',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.notifications),
              title: const Text('Smart Notifications'),
              trailing: Switch(
                value: true,
                onChanged: (value) {},
              ),
            ),
            ListTile(
              leading: const Icon(Icons.location_on),
              title: const Text('Location Services'),
              trailing: Switch(
                value: true,
                onChanged: (value) {},
              ),
            ),
            ListTile(
              leading: const Icon(Icons.wb_sunny),
              title: const Text('Weather Integration'),
              trailing: Switch(
                value: true,
                onChanged: (value) {},
              ),
            ),
            ListTile(
              leading: const Icon(Icons.sync),
              title: const Text('Calendar Sync'),
              trailing: Switch(
                value: true,
                onChanged: (value) {},
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddEventModal(BuildContext context) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final locationController = TextEditingController();
    DateTime selectedDate = DateTime.now();
    TimeOfDay selectedStartTime = TimeOfDay.now();
    TimeOfDay selectedEndTime = TimeOfDay.now().replacing(hour: TimeOfDay.now().hour + 1);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => DraggableScrollableSheet(
          initialChildSize: 0.8,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          builder: (context, scrollController) => Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Add New Event',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: Column(
                      children: [
                        TextField(
                          controller: titleController,
                          decoration: const InputDecoration(
                            labelText: 'Event Title',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: descriptionController,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            labelText: 'Description',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        ListTile(
                          title: const Text('Date'),
                          subtitle: Text(
                            '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                          ),
                          trailing: const Icon(Icons.calendar_today),
                          onTap: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: selectedDate,
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now().add(const Duration(days: 365)),
                            );
                            if (date != null) {
                              setModalState(() {
                                selectedDate = date;
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: ListTile(
                                title: const Text('Start Time'),
                                subtitle: Text(selectedStartTime.format(context)),
                                trailing: const Icon(Icons.access_time),
                                onTap: () async {
                                  final time = await showTimePicker(
                                    context: context,
                                    initialTime: selectedStartTime,
                                  );
                                  if (time != null) {
                                    setModalState(() {
                                      selectedStartTime = time;
                                    });
                                  }
                                },
                              ),
                            ),
                            Expanded(
                              child: ListTile(
                                title: const Text('End Time'),
                                subtitle: Text(selectedEndTime.format(context)),
                                trailing: const Icon(Icons.access_time),
                                onTap: () async {
                                  final time = await showTimePicker(
                                    context: context,
                                    initialTime: selectedEndTime,
                                  );
                                  if (time != null) {
                                    setModalState(() {
                                      selectedEndTime = time;
                                    });
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: locationController,
                          decoration: const InputDecoration(
                            labelText: 'Location',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancel'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () async {
                                  if (titleController.text.isNotEmpty) {
                                    final startDateTime = DateTime(
                                      selectedDate.year,
                                      selectedDate.month,
                                      selectedDate.day,
                                      selectedStartTime.hour,
                                      selectedStartTime.minute,
                                    );
                                    final endDateTime = DateTime(
                                      selectedDate.year,
                                      selectedDate.month,
                                      selectedDate.day,
                                      selectedEndTime.hour,
                                      selectedEndTime.minute,
                                    );

                                    final newEvent = Event(
                                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                                      title: titleController.text,
                                      description: descriptionController.text,
                                      startTime: startDateTime,
                                      endTime: endDateTime,
                                      location: locationController.text,
                                      type: EventType.personal,
                                    );

                                    Navigator.pop(context);
                                    
                                    // Reload events after adding new one
                                    if (mounted) {
                                      await _loadEventsForMonth(_focusedDay);
                                    }
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Theme.of(context).primaryColor,
                                ),
                                child: const Text('Add Event'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF4299E1).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFF4299E1)),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              text,
              style: const TextStyle(
                color: Color(0xFF4299E1),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}