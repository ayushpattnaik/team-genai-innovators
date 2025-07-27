import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/sentiment_data.dart';
import '../models/incident_data.dart';

class DashboardTab extends StatefulWidget {
  const DashboardTab({super.key});

  @override
  State<DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<DashboardTab> with TickerProviderStateMixin {
  GoogleMapController? mapController;
  final Set<Circle> _sentimentCircles = {};
  final Set<Circle> _incidentCircles = {};
  bool _showSentiments = true;
  bool _showIncidents = false;
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  // Update center to Bengaluru
  final LatLng _center = const LatLng(12.9716, 77.5946); // Bengaluru coordinates

  // Updated sentiment data for Bengaluru
  final List<SentimentData> _sentimentData = [
    SentimentData(
      location: const LatLng(12.9716, 77.5946), // MG Road
      sentiment: 0.8,
      description: 'Very positive area with high community satisfaction in MG Road',
    ),
    SentimentData(
      location: const LatLng(12.9789, 77.5917), // Indiranagar
      sentiment: -0.5,
      description: 'Negative sentiment detected due to recent traffic issues in Indiranagar',
    ),
    SentimentData(
      location: const LatLng(12.9352, 77.6245), // Jayanagar
      sentiment: 0.3,
      description: 'Moderate positive sentiment in residential area of Jayanagar',
    ),
    SentimentData(
      location: const LatLng(12.9724, 77.6408), // Koramangala
      sentiment: -0.2,
      description: 'Slight negative sentiment in commercial district of Koramangala',
    ),
    SentimentData(
      location: const LatLng(12.9543, 77.6420), // JP Nagar
      sentiment: 0.6,
      description: 'Positive sentiment in peaceful residential area of JP Nagar',
    ),
    SentimentData(
      location: const LatLng(12.9855, 77.6200), // Whitefield
      sentiment: 0.1,
      description: 'Neutral sentiment in tech hub area of Whitefield',
    ),
  ];

  // Updated incident data for Bengaluru
  final List<IncidentData> _incidentData = [
    IncidentData(
      location: const LatLng(12.9716, 77.5946), // MG Road
      type: 'traffic',
      description: 'Heavy traffic congestion on MG Road due to ongoing metro construction',
      source: 'twitter',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    IncidentData(
      location: const LatLng(12.9789, 77.5917), // Indiranagar
      type: 'traffic',
      description: 'Major traffic accident on 100 Feet Road, Indiranagar',
      source: 'reddit',
      timestamp: DateTime.now().subtract(const Duration(hours: 1)),
    ),
    IncidentData(
      location: const LatLng(12.9352, 77.6245), // Jayanagar
      type: 'event',
      description: 'Community festival in progress at Jayanagar 4th Block',
      source: 'instagram',
      timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
    ),
    IncidentData(
      location: const LatLng(12.9724, 77.6408), // Koramangala
      type: 'traffic',
      description: 'Vehicle break-in reported in Koramangala parking lot',
      source: 'reddit',
      timestamp: DateTime.now().subtract(const Duration(hours: 3)),
    ),
    IncidentData(
      location: const LatLng(12.9543, 77.6420), // JP Nagar
      type: 'event',
      description: 'Local market festival happening in JP Nagar 2nd Phase',
      source: 'twitter',
      timestamp: DateTime.now().subtract(const Duration(hours: 4)),
    ),
    IncidentData(
      location: const LatLng(12.9855, 77.6200), // Whitefield
      type: 'traffic',
      description: 'IT corridor traffic jam during peak hours in Whitefield',
      source: 'reddit',
      timestamp: DateTime.now().subtract(const Duration(hours: 5)),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
    
    _createSentimentCircles();
    _createIncidentCircles();
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _createSentimentCircles() {
    setState(() {
      _sentimentCircles.clear();
      for (var data in _sentimentData) {
        final circle = Circle(
          circleId: CircleId('sentiment_${data.location.toString()}'),
          center: data.location,
          radius: 300,
          fillColor: _getSentimentColor(data.sentiment).withOpacity(0.2),
          strokeColor: _getSentimentColor(data.sentiment),
          strokeWidth: 3,
          onTap: () {
            _showSentimentInfo(data);
          },
        );
        _sentimentCircles.add(circle);
      }
    });
  }

  void _createIncidentCircles() {
    setState(() {
      _incidentCircles.clear();
      for (var incident in _incidentData) {
        final circle = Circle(
          circleId: CircleId('incident_${incident.location.toString()}'),
          center: incident.location,
          radius: 300,
          fillColor: _getIncidentColor(incident.type).withOpacity(0.2),
          strokeColor: _getIncidentColor(incident.type),
          strokeWidth: 3,
          onTap: () {
            _showIncidentInfo(incident);
          },
        );
        _incidentCircles.add(circle);
      }
    });
  }

  // Updated color scheme for sentiments
  Color _getSentimentColor(double sentiment) {
    if (sentiment > 0.5) {
      return const Color(0xFF4CAF50); // Green for happy
    } else if (sentiment > 0) {
      return const Color(0xFFFFEB3B); // Yellow for neutral-positive
    } else if (sentiment > -0.5) {
      return const Color(0xFFFF9800); // Orange for neutral-negative
    } else {
      return const Color(0xFFF44336); // Red for sad
    }
  }

  // Updated color scheme for incidents - all same color
  Color _getIncidentColor(String type) {
    return const Color(0xFF2196F3); // Blue for all incidents
  }

  String _getSentimentLabel(double sentiment) {
    if (sentiment > 0.7) return 'Very Positive';
    if (sentiment > 0.3) return 'Positive';
    if (sentiment > -0.3) return 'Neutral';
    if (sentiment > -0.7) return 'Negative';
    return 'Very Negative';
  }

  String _getIncidentTypeLabel(String type) {
    switch (type) {
      case 'crime':
        return 'Crime';
      case 'traffic':
        return 'Traffic';
      case 'event':
        return 'Event';
      default:
        return 'Other';
    }
  }

  void _showSentimentInfo(SentimentData data) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Handle bar
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    width: 50,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header with gradient background
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  _getSentimentColor(data.sentiment).withOpacity(0.1),
                                  _getSentimentColor(data.sentiment).withOpacity(0.05),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: _getSentimentColor(data.sentiment),
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: _getSentimentColor(data.sentiment).withOpacity(0.3),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    data.sentiment > 0 ? Icons.sentiment_satisfied_alt : Icons.sentiment_dissatisfied,
                                    color: Colors.white,
                                    size: 28,
                                  ),
                                ),
                                const SizedBox(width: 20),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Sentiment Analysis',
                                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey.shade800,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: _getSentimentColor(data.sentiment),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          _getSentimentLabel(data.sentiment),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          
                          // Sentiment Score Card with animated progress
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  _getSentimentColor(data.sentiment).withOpacity(0.1),
                                  _getSentimentColor(data.sentiment).withOpacity(0.05),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: _getSentimentColor(data.sentiment).withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Sentiment Score',
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        color: Colors.grey.shade700,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      '${(data.sentiment * 100).toStringAsFixed(1)}%',
                                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                        color: _getSentimentColor(data.sentiment),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                // Progress bar
                                Container(
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade200,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: FractionallySizedBox(
                                    alignment: Alignment.centerLeft,
                                    widthFactor: (data.sentiment + 1) / 2, // Normalize to 0-1
                                    child: Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            _getSentimentColor(data.sentiment),
                                            _getSentimentColor(data.sentiment).withOpacity(0.7),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          
                          // Description
                          Text(
                            'Description',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade800,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: Text(
                              data.description,
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: Colors.grey.shade700,
                                height: 1.6,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          
                          // Location Info
                          Text(
                            'Location Details',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade800,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.blue.shade200),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.blue,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.location_on,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Coordinates',
                                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          color: Colors.blue.shade700,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Text(
                                        'Lat: ${data.location.latitude.toStringAsFixed(4)}, Lng: ${data.location.longitude.toStringAsFixed(4)}',
                                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          color: Colors.grey.shade700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showIncidentInfo(IncidentData incident) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Handle bar
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    width: 50,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header with gradient background
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  _getIncidentColor(incident.type).withOpacity(0.1),
                                  _getIncidentColor(incident.type).withOpacity(0.05),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: _getIncidentColor(incident.type),
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: _getIncidentColor(incident.type).withOpacity(0.3),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    _getIncidentIcon(incident.type),
                                    color: Colors.white,
                                    size: 28,
                                  ),
                                ),
                                const SizedBox(width: 20),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Incident Report',
                                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey.shade800,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: _getIncidentColor(incident.type),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          _getIncidentTypeLabel(incident.type),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          
                          // Incident Details Card
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  _getIncidentColor(incident.type).withOpacity(0.1),
                                  _getIncidentColor(incident.type).withOpacity(0.05),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: _getIncidentColor(incident.type).withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: _getIncidentColor(incident.type),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(
                                        Icons.access_time,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Reported',
                                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                          Text(
                                            _getTimeAgo(incident.timestamp),
                                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                              color: _getIncidentColor(incident.type),
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: _getIncidentColor(incident.type),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(
                                        Icons.source,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Source',
                                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                          Text(
                                            incident.source.toUpperCase(),
                                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                              color: _getIncidentColor(incident.type),
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          
                          // Description
                          Text(
                            'Description',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade800,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: Text(
                              incident.description,
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: Colors.grey.shade700,
                                height: 1.6,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          
                          // Location Info
                          Text(
                            'Location Details',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade800,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.blue.shade200),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.blue,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.location_on,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Coordinates',
                                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          color: Colors.blue.shade700,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Text(
                                        'Lat: ${incident.location.latitude.toStringAsFixed(4)}, Lng: ${incident.location.longitude.toStringAsFixed(4)}',
                                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          color: Colors.grey.shade700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          
                          // Action Buttons
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  height: 50,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: _getIncidentColor(incident.type)),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: OutlinedButton.icon(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      // Add report functionality
                                    },
                                    icon: Icon(
                                      Icons.report,
                                      color: _getIncidentColor(incident.type),
                                    ),
                                    label: Text(
                                      'Report',
                                      style: TextStyle(
                                        color: _getIncidentColor(incident.type),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    style: OutlinedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: SizedBox(
                                  height: 50,
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      // Add share functionality
                                    },
                                    icon: const Icon(Icons.share, color: Colors.white),
                                    label: const Text(
                                      'Share',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: _getIncidentColor(incident.type),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
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
            );
          },
        );
      },
    );
  }

  IconData _getIncidentIcon(String type) {
    switch (type) {
      case 'crime':
        return Icons.warning_amber_rounded;
      case 'traffic':
        return Icons.traffic;
      case 'event':
        return Icons.event;
      default:
        return Icons.info;
    }
  }

  String _getTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else {
      return '${difference.inDays} days ago';
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    setState(() {
      mapController = controller;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      extendBodyBehindAppBar: true,
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
              child: const Icon(Icons.dashboard, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Text(
              'City Dashboard',
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
              icon: const Icon(Icons.info_outline, color: Color(0xFF4299E1)),
              onPressed: () {
                // Show app info or help
              },
            ),
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Stack(
          children: [
            GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: _center,
                zoom: 12.0,
              ),
              circles: {
                if (_showSentiments) ..._sentimentCircles,
                if (_showIncidents) ..._incidentCircles,
              },
              mapType: MapType.normal,
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
            ),
            
            // Professional overlay controls
            Positioned(
              top: MediaQuery.of(context).padding.top + kToolbarHeight + 16,
              right: 16,
              child: SlideTransition(
                position: _slideAnimation,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _buildToggleButton(
                        'Sentiments',
                        Icons.mood,
                        _showSentiments,
                        (value) => setState(() {
                          _showSentiments = value;
                          if (value) _showIncidents = false;
                        }),
                      ),
                      Container(
                        height: 1,
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        color: Colors.grey.shade200,
                      ),
                      _buildToggleButton(
                        'Incidents',
                        Icons.warning_amber_rounded,
                        _showIncidents,
                        (value) => setState(() {
                          _showIncidents = value;
                          if (value) _showSentiments = false;
                        }),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            // Legend panel
            Positioned(
              bottom: 100,
              left: 16,
              child: SlideTransition(
                position: _slideAnimation,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Legend',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF2D3748),
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (_showSentiments) ...[
                        _buildLegendItem('Happy', const Color(0xFF4CAF50)),
                        _buildLegendItem('Neutral', const Color(0xFFFFEB3B)),
                        _buildLegendItem('Sad', const Color(0xFFF44336)),
                      ] else if (_showIncidents) ...[
                        _buildLegendItem('Incidents', const Color(0xFF2196F3)),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: FloatingActionButton(
              heroTag: 'refresh',
              backgroundColor: Colors.transparent,
              elevation: 0,
              onPressed: _createSentimentCircles,
              child: const Icon(Icons.refresh, color: Color(0xFF4299E1)),
            ),
          ),
          const SizedBox(height: 16),
          Container(
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
              heroTag: 'center',
              backgroundColor: Colors.transparent,
              elevation: 0,
              onPressed: () {
                mapController?.animateCamera(
                  CameraUpdate.newCameraPosition(
                    CameraPosition(target: _center, zoom: 12.0),
                  ),
                );
              },
              child: const Icon(Icons.center_focus_strong, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButton(
    String tooltip,
    IconData icon,
    bool isActive,
    Function(bool) onChanged,
  ) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF4299E1).withOpacity(0.15) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive ? const Color(0xFF4299E1) : Colors.grey.shade200,
          width: 1.5,
        ),
      ),
      child: IconButton(
        icon: Icon(
          icon,
          color: isActive ? const Color(0xFF4299E1) : Colors.grey.shade600,
          size: 20,
        ),
        tooltip: tooltip,
        onPressed: () => onChanged(!isActive),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: const Color(0xFF4A5568),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
