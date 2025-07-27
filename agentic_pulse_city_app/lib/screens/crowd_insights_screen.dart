import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class CrowdInsightsScreen extends StatefulWidget {
  const CrowdInsightsScreen({super.key});

  @override
  State<CrowdInsightsScreen> createState() => _CrowdInsightsScreenState();
}

class _CrowdInsightsScreenState extends State<CrowdInsightsScreen> {
  String _selectedTimeframe = 'Today';
  String _selectedArea = 'All Areas';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: const [
            Icon(Icons.groups, color: Color(0xFF4299E1)),
            SizedBox(width: 8),
            Text(
              'Crowd Insights',
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
            icon: const Icon(Icons.refresh, color: Color(0xFF4299E1)),
            onPressed: () {},
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Filters
            Row(
              children: [
                DropdownButton<String>(
                  value: _selectedTimeframe,
                  items: const [
                    DropdownMenuItem(value: 'Today', child: Text('Today')),
                    DropdownMenuItem(value: 'This Week', child: Text('This Week')),
                    DropdownMenuItem(value: 'This Month', child: Text('This Month')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedTimeframe = value!;
                    });
                  },
                ),
                const SizedBox(width: 16),
                DropdownButton<String>(
                  value: _selectedArea,
                  items: const [
                    DropdownMenuItem(value: 'All Areas', child: Text('All Areas')),
                    DropdownMenuItem(value: 'MG Road', child: Text('MG Road')),
                    DropdownMenuItem(value: 'Koramangala', child: Text('Koramangala')),
                    DropdownMenuItem(value: 'Indiranagar', child: Text('Indiranagar')),
                    DropdownMenuItem(value: 'Whitefield', child: Text('Whitefield')),
                    DropdownMenuItem(value: 'Electronic City', child: Text('Electronic City')),
                    DropdownMenuItem(value: 'Marathahalli', child: Text('Marathahalli')),
                    DropdownMenuItem(value: 'HSR Layout', child: Text('HSR Layout')),
                    DropdownMenuItem(value: 'JP Nagar', child: Text('JP Nagar')),
                    DropdownMenuItem(value: 'Banashankari', child: Text('Banashankari')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedArea = value!;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Crowd Density Chart
            _buildCrowdDensityChart(context),
            const SizedBox(height: 32),
            // Hotspots
            const Text(
              'Current Hotspots',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3748),
              ),
            ),
            const SizedBox(height: 16),
            _buildHotspotsList(),
            const SizedBox(height: 32),
            // Insights
            const Text(
              'Actionable Insights',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3748),
              ),
            ),
            const SizedBox(height: 16),
            _buildInsightsCards(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // Crowd Density Chart
  Widget _buildCrowdDensityChart(BuildContext context) {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: true, drawVerticalLine: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: true, reservedSize: 28),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final hour = value.toInt();
                  return Text('$hour:00', style: const TextStyle(fontSize: 10));
                },
                reservedSize: 28,
              ),
            ),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: [
                const FlSpot(0, 20),
                const FlSpot(2, 40),
                const FlSpot(4, 80),
                const FlSpot(6, 120),
                const FlSpot(8, 100),
                const FlSpot(10, 60),
                const FlSpot(12, 30),
                const FlSpot(14, 20),
                const FlSpot(16, 50),
                const FlSpot(18, 90),
                const FlSpot(20, 130),
                const FlSpot(22, 110),
                const FlSpot(24, 60),
              ],
              isCurved: true,
              color: const Color(0xFF4299E1),
              barWidth: 3,
              dotData: FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: const Color(0xFF4299E1).withOpacity(0.15),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Hotspots List
  Widget _buildHotspotsList() {
    final hotspots = [
      {
        'name': 'MG Road',
        'crowd': 'Very High',
        'icon': Icons.shopping_bag,
        'color': Colors.red,
        'advice': 'Peak shopping hours, expect heavy traffic',
      },
      {
        'name': 'Koramangala',
        'crowd': 'High',
        'icon': Icons.restaurant,
        'color': Colors.orange,
        'advice': 'Restaurant rush during lunch and dinner',
      },
      {
        'name': 'Indiranagar',
        'crowd': 'Moderate',
        'icon': Icons.nightlife,
        'color': Colors.purple,
        'advice': 'Nightlife picks up after 8 PM',
      },
      {
        'name': 'Whitefield',
        'crowd': 'High',
        'icon': Icons.work,
        'color': Colors.blue,
        'advice': 'IT corridor - heavy during office hours',
      },
      {
        'name': 'Electronic City',
        'crowd': 'Moderate',
        'icon': Icons.business,
        'color': Colors.green,
        'advice': 'Tech companies - busy during work hours',
      },
    ];

    return Column(
      children: hotspots.map((spot) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: (spot['color'] as Color).withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: (spot['color'] as Color).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(spot['icon'] as IconData, color: spot['color'] as Color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      spot['name'] as String,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      'Crowd: ${spot['crowd']}',
                      style: TextStyle(
                        color: (spot['color'] as Color),
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      spot['advice'] as String,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // Insights Cards
  Widget _buildInsightsCards() {
    final insights = [
      {
        'icon': Icons.directions_bus,
        'color': Colors.blue,
        'title': 'BMTC Transit',
        'desc': 'Metro lines less crowded after 10 AM. BMTC buses frequent on MG Road.',
      },
      {
        'icon': Icons.event,
        'color': Colors.purple,
        'title': 'Local Events',
        'desc': 'Food festival in Koramangala tonight. Expect high footfall.',
      },
      {
        'icon': Icons.shopping_cart,
        'color': Colors.orange,
        'title': 'Shopping',
        'desc': 'Best time to visit Commercial Street: 2-4 PM.',
      },
      {
        'icon': Icons.directions_car,
        'color': Colors.red,
        'title': 'Traffic Alert',
        'desc': 'Heavy traffic on Outer Ring Road during peak hours.',
      },
      {
        'icon': Icons.park,
        'color': Colors.green,
        'title': 'Parks & Recreation',
        'desc': 'Cubbon Park is less crowded in the early morning.',
      },
    ];

    return Column(
      children: insights.map((insight) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: (insight['color'] as Color).withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: (insight['color'] as Color).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(insight['icon'] as IconData, color: insight['color'] as Color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      insight['title'] as String,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      insight['desc'] as String,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}