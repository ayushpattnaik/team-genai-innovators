import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class TrafficNavigationScreen extends StatefulWidget {
  const TrafficNavigationScreen({super.key});

  @override
  State<TrafficNavigationScreen> createState() => _TrafficNavigationScreenState();
}

class _TrafficNavigationScreenState extends State<TrafficNavigationScreen> {
  String _selectedDestination = 'Select Destination';
  String _selectedMode = 'Car';
  bool _avoidCrowds = true;
  bool _avoidTolls = false;
  
  // Google Maps Controller
  GoogleMapController? _mapController;
  
  // Bangalore center coordinates
  static const LatLng _bangaloreCenter = LatLng(12.9716, 77.5946);
  
  // Sample traffic data points
  final List<TrafficPoint> _trafficPoints = [
    TrafficPoint(
      position: const LatLng(12.9716, 77.5946), // MG Road
      title: 'MG Road',
      description: 'Heavy traffic due to shopping rush',
      severity: TrafficSeverity.high,
      type: TrafficType.congestion,
      timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
    ),
    TrafficPoint(
      position: const LatLng(12.9352, 77.6244), // Koramangala
      title: 'Koramangala',
      description: 'Restaurant rush during lunch hours',
      severity: TrafficSeverity.medium,
      type: TrafficType.crowd,
      timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
    ),
    TrafficPoint(
      position: const LatLng(12.9789, 77.5917), // Indiranagar
      title: 'Indiranagar',
      description: 'Accident reported, expect delays',
      severity: TrafficSeverity.high,
      type: TrafficType.accident,
      timestamp: DateTime.now().subtract(const Duration(minutes: 8)),
    ),
    TrafficPoint(
      position: const LatLng(12.9716, 77.7500), // Whitefield
      title: 'Whitefield',
      description: 'IT corridor - heavy during office hours',
      severity: TrafficSeverity.medium,
      type: TrafficType.congestion,
      timestamp: DateTime.now().subtract(const Duration(minutes: 20)),
    ),
    TrafficPoint(
      position: const LatLng(12.8458, 77.6655), // Electronic City
      title: 'Electronic City',
      description: 'Clear traffic, smooth flow',
      severity: TrafficSeverity.low,
      type: TrafficType.clear,
      timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
    ),
    TrafficPoint(
      position: const LatLng(12.9716, 77.6400), // HSR Layout
      title: 'HSR Layout',
      description: 'Construction work, single lane',
      severity: TrafficSeverity.medium,
      type: TrafficType.construction,
      timestamp: DateTime.now().subtract(const Duration(minutes: 12)),
    ),
  ];

  // Sample route polylines
  final List<Polyline> _routePolylines = [
    Polyline(
      polylineId: const PolylineId('fastest_route'),
      points: [
        const LatLng(12.9716, 77.5946), // Start
        const LatLng(12.9789, 77.5917), // Via Indiranagar
        const LatLng(12.9352, 77.6244), // End - Koramangala
      ],
      color: Colors.green,
      width: 4,
    ),
    Polyline(
      polylineId: const PolylineId('least_crowded'),
      points: [
        const LatLng(12.9716, 77.5946), // Start
        const LatLng(12.9716, 77.6400), // Via HSR Layout
        const LatLng(12.9352, 77.6244), // End - Koramangala
      ],
      color: Colors.blue,
      width: 4,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: const [
            Icon(Icons.directions_car, color: Color(0xFF4299E1)),
            SizedBox(width: 8),
            Text(
              'Smart Navigation',
              style: TextStyle(
                color: Color(0xFF2D3748),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location, color: Color(0xFF4299E1)),
            onPressed: () {
              _mapController?.animateCamera(
                CameraUpdate.newLatLngZoom(_bangaloreCenter, 12),
              );
            },
            tooltip: 'My Location',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Route Input Section
            _buildRouteInputSection(),
            const SizedBox(height: 24),
            
            // Live Traffic Map
            _buildLiveTrafficMap(),
            const SizedBox(height: 24),
            
            // Current Traffic Status
            _buildTrafficStatusCard(),
            const SizedBox(height: 24),
            
            // Route Options
            _buildRouteOptions(),
            const SizedBox(height: 24),
            
            // Public Transport Options
            _buildPublicTransportSection(),
            const SizedBox(height: 24),
            
            // Parking Information
            _buildParkingSection(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildRouteInputSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // From Location
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF7FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.my_location, color: Colors.green, size: 20),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Current Location',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          
          // To Location
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF7FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.location_on, color: Colors.red, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButton<String>(
                    value: _selectedDestination,
                    isExpanded: true,
                    underline: Container(),
                    items: const [
                      DropdownMenuItem(value: 'Select Destination', child: Text('Select Destination')),
                      DropdownMenuItem(value: 'MG Road', child: Text('MG Road')),
                      DropdownMenuItem(value: 'Koramangala', child: Text('Koramangala')),
                      DropdownMenuItem(value: 'Whitefield', child: Text('Whitefield')),
                      DropdownMenuItem(value: 'Electronic City', child: Text('Electronic City')),
                      DropdownMenuItem(value: 'Indiranagar', child: Text('Indiranagar')),
                      DropdownMenuItem(value: 'HSR Layout', child: Text('HSR Layout')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedDestination = value!;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Transport Mode & Preferences
          Row(
            children: [
              Expanded(
                child: DropdownButton<String>(
                  value: _selectedMode,
                  isExpanded: true,
                  items: const [
                    DropdownMenuItem(value: 'Car', child: Text('🚗 Car')),
                    DropdownMenuItem(value: 'Bike', child: Text('🏍️ Bike')),
                    DropdownMenuItem(value: 'Walk', child: Text('🚶 Walk')),
                    DropdownMenuItem(value: 'Public', child: Text('🚌 Public')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedMode = value!;
                    });
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Calculate route
                  },
                  icon: const Icon(Icons.directions),
                  label: const Text('Find Route'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4299E1),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTrafficStatusCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4299E1), Color(0xFF3182CE)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4299E1).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.traffic, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current Traffic Status',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Bangalore City',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _buildTrafficMetric('Major Roads', 'Moderate', Colors.orange),
              const SizedBox(width: 20),
              _buildTrafficMetric('Highways', 'Clear', Colors.green),
              const SizedBox(width: 20),
              _buildTrafficMetric('Metro', 'Smooth', Colors.blue),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTrafficMetric(String label, String status, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRouteOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Route Options',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D3748),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildRouteOption(
                'Fastest Route',
                '25 mins',
                'Via MG Road',
                Colors.green,
                Icons.speed,
                isSelected: true,
              ),
              const SizedBox(height: 12),
              _buildRouteOption(
                'Least Crowded',
                '32 mins',
                'Via Indiranagar',
                Colors.blue,
                Icons.groups,
                isSelected: false,
              ),
              const SizedBox(height: 12),
              _buildRouteOption(
                'Eco-Friendly',
                '28 mins',
                'Via bike lanes',
                Colors.teal,
                Icons.eco,
                isSelected: false,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRouteOption(String title, String time, String via, Color color, IconData icon, {required bool isSelected}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isSelected ? color.withOpacity(0.1) : Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? color : Colors.grey[300]!,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: isSelected ? color : Colors.black,
                  ),
                ),
                Text(
                  via,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: isSelected ? color : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveTrafficMap() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Fixed header with better layout
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Live Traffic Map',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3748),
              ),
            ),
            const SizedBox(height: 8),
            // Legend in a more compact layout
            Wrap(
              spacing: 12,
              runSpacing: 4,
              children: [
                _buildLegendItem('High', Colors.red),
                _buildLegendItem('Medium', Colors.orange),
                _buildLegendItem('Low', Colors.green),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          height: 300,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: GoogleMap(
              initialCameraPosition: const CameraPosition(
                target: _bangaloreCenter,
                zoom: 11,
              ),
              onMapCreated: (GoogleMapController controller) {
                _mapController = controller;
              },
              markers: _getTrafficMarkers(),
              polylines: Set<Polyline>.from(_routePolylines),
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              mapToolbarEnabled: false,
              trafficEnabled: true,
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Traffic Insights Summary
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Traffic Insights',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  _buildInsightChip('6 Active Reports', Colors.blue),
                  _buildInsightChip('2 Accidents', Colors.red),
                  _buildInsightChip('1 Construction', Colors.orange),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildInsightChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Set<Marker> _getTrafficMarkers() {
    return _trafficPoints.map((point) {
      return Marker(
        markerId: MarkerId(point.title),
        position: point.position,
        infoWindow: InfoWindow(
          title: point.title,
          snippet: point.description,
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(_getMarkerHue(point.severity)),
        onTap: () => _showTrafficDetails(point),
      );
    }).toSet();
  }

  double _getMarkerHue(TrafficSeverity severity) {
    switch (severity) {
      case TrafficSeverity.high:
        return BitmapDescriptor.hueRed;
      case TrafficSeverity.medium:
        return BitmapDescriptor.hueOrange;
      case TrafficSeverity.low:
        return BitmapDescriptor.hueGreen;
    }
  }

  void _showTrafficDetails(TrafficPoint point) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _getSeverityColor(point.severity).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getTrafficIcon(point.type),
                    color: _getSeverityColor(point.severity),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        point.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        _getSeverityText(point.severity),
                        style: TextStyle(
                          color: _getSeverityColor(point.severity),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              point.description,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Reported ${_getTimeAgo(point.timestamp)}',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
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
                      Navigator.pop(context);
                      // Navigate to this location
                      _mapController?.animateCamera(
                        CameraUpdate.newLatLngZoom(point.position, 15),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4299E1),
                    ),
                    child: const Text('View Location'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getSeverityColor(TrafficSeverity severity) {
    switch (severity) {
      case TrafficSeverity.high:
        return Colors.red;
      case TrafficSeverity.medium:
        return Colors.orange;
      case TrafficSeverity.low:
        return Colors.green;
    }
  }

  String _getSeverityText(TrafficSeverity severity) {
    switch (severity) {
      case TrafficSeverity.high:
        return 'High Traffic';
      case TrafficSeverity.medium:
        return 'Moderate Traffic';
      case TrafficSeverity.low:
        return 'Clear Traffic';
    }
  }

  IconData _getTrafficIcon(TrafficType type) {
    switch (type) {
      case TrafficType.congestion:
        return Icons.traffic;
      case TrafficType.accident:
        return Icons.car_crash;
      case TrafficType.construction:
        return Icons.construction;
      case TrafficType.crowd:
        return Icons.groups;
      case TrafficType.clear:
        return Icons.check_circle;
    }
  }

  String _getTimeAgo(DateTime timestamp) {
    final difference = DateTime.now().difference(timestamp);
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else {
      return '${difference.inDays} days ago';
    }
  }

  Widget _buildPublicTransportSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Public Transport',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D3748),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildTransportCard(
                'Metro',
                '5 mins',
                'Green Line',
                Colors.green,
                Icons.train,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTransportCard(
                'BMTC',
                '8 mins',
                'Route 401',
                Colors.blue,
                Icons.directions_bus,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTransportCard(String type, String wait, String route, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            type,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          Text(
            'Wait: $wait',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
          Text(
            route,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParkingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Parking Information',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D3748),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildParkingInfo('MG Road Mall', 'Available', '₹50/hour', Colors.green),
              const SizedBox(height: 12),
              _buildParkingInfo('Street Parking', 'Limited', '₹20/hour', Colors.orange),
              const SizedBox(height: 12),
              _buildParkingInfo('Metro Station', 'Full', '₹30/hour', Colors.red),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildParkingInfo(String location, String status, String price, Color color) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            location,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ),
        Text(
          status,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          price,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

// Data classes for traffic points
class TrafficPoint {
  final LatLng position;
  final String title;
  final String description;
  final TrafficSeverity severity;
  final TrafficType type;
  final DateTime timestamp;

  TrafficPoint({
    required this.position,
    required this.title,
    required this.description,
    required this.severity,
    required this.type,
    required this.timestamp,
  });
}

enum TrafficSeverity { low, medium, high }
enum TrafficType { congestion, accident, construction, crowd, clear } 