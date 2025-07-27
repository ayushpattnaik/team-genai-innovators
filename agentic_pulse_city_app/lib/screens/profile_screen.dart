import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart'; // Add this dependency to pubspec.yaml

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                // Profile Header with Background
                Container(  // Changed from SizedBox to Container
                  height: 300,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Theme.of(context).primaryColor,
                        Theme.of(context).primaryColor.withOpacity(0.7),
                      ],
                    ),
                  ),
                  child: SafeArea(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircleAvatar(
                          radius: 50,
                          backgroundImage: NetworkImage(
                            'https://imgcdn.stablediffusionweb.com/2024/9/8/04fdb256-b489-4571-972c-249a0cb35019.jpg',
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'John Doe',
                          style: TextStyle(
                            color: Colors.white,  // Changed text color to white
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'City Explorer',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),  // Changed text color to white with opacity
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Settings Button
                Positioned(
                  top: MediaQuery.of(context).padding.top + 10,
                  right: 16,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.2),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.settings, color: Colors.white),
                      onPressed: () => _showSettingsModal(context),
                    ),
                  ),
                ),
              ],
            ),
            // Stats Row
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatColumn('Reports', '23'),
                  _buildStatColumn('Points', '1,234'),
                  _buildStatColumn('Rank', '#42'),
                ],
              ),
            ),
            // Activity Graph
            Container(
              height: 200,
              padding: const EdgeInsets.all(16),
              child: _buildActivityGraph(context),
            ),
            // Recommendations Section
            _buildRecommendationsSection(context),
            // Recent Activity
            _buildRecentActivity(context),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityGraph(BuildContext context) {
    return LineChart(
      LineChartData(
        gridData: FlGridData(show: false),
        titlesData: FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: [
              const FlSpot(0, 3),
              const FlSpot(2.6, 2),
              const FlSpot(4.9, 5),
              const FlSpot(6.8, 3.1),
              const FlSpot(8, 4),
              const FlSpot(9.5, 3),
              const FlSpot(11, 4),
            ],
            isCurved: true,
            color: Theme.of(context).primaryColor,
            barWidth: 3,
            dotData: FlDotData(show: false),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationsSection(BuildContext context) {
    final recommendedEvents = [
      {
        'title': 'Jazz in the Park',
        'location': 'Central Park',
        'time': 'Today, 6:00 PM',
        'category': 'music',
      },
      {
        'title': 'City Marathon',
        'location': 'Main Street',
        'time': 'Tomorrow, 7:00 AM',
        'category': 'sports',
      },
      {
        'title': 'Food Truck Fiesta',
        'location': 'Market Square',
        'time': 'Sat, 12:00 PM',
        'category': 'food',
      },
      {
        'title': 'Community Cleanup',
        'location': 'Riverside',
        'time': 'Sun, 9:00 AM',
        'category': 'community',
      },
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recommended Events',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: recommendedEvents.map((event) {
                final iconData = _getEventCategoryIcon(event['category'] as String);
                final color = _getEventCategoryColor(event['category'] as String);
                return Container(
                  margin: const EdgeInsets.only(right: 16),
                  width: 180,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min, // <-- This allows the card to shrink to fit content
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(iconData, color: color, size: 28),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          event['title'] as String,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.location_on, size: 14, color: Colors.grey),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                event['location'] as String,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 13,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            const Icon(Icons.access_time, size: 14, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(
                              event['time'] as String,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getEventCategoryIcon(String category) {
    switch (category) {
      case 'music':
        return Icons.music_note;
      case 'sports':
        return Icons.directions_run;
      case 'food':
        return Icons.fastfood;
      case 'community':
        return Icons.volunteer_activism;
      default:
        return Icons.event;
    }
  }

  Color _getEventCategoryColor(String category) {
    switch (category) {
      case 'music':
        return Colors.deepPurple;
      case 'sports':
        return Colors.blue;
      case 'food':
        return Colors.orange;
      case 'community':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Widget _buildRecentActivity(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recent Activity',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildActivityItem(
            'Reported positive sentiment',
            'Downtown Area',
            '2h ago',
            Icons.mood,
          ),
          _buildActivityItem(
            'Explored new location',
            'Central Park',
            '5h ago',
            Icons.explore,
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(
      String title, String location, String time, IconData icon) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(location),
      trailing: Text(time),
    );
  }

  void _showSettingsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.person_outline),
                title: const Text('Edit Profile'),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(Icons.history),
                title: const Text('Activity History'),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(Icons.help_outline),
                title: const Text('Help & Support'),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text('Logout',
                    style: TextStyle(color: Colors.red)),
                onTap: () {},
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatColumn(String title, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}