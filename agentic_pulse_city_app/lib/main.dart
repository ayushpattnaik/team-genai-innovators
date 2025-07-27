import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/report_incident_screen.dart';
import 'screens/planner_screen.dart';
import 'screens/traffic_navigation_screen.dart';

Future<void> main() async {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: const Color(0xFF4299E1),
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
        cardColor: const Color(0xFF9AA0A6).withOpacity(0.1),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _screens = [
    HomeTab(),
    DashboardTab(),
    PlannerScreen(), // Add the new planner screen
    ReportIncidentScreen(),
    ProfileTab(),
    TrafficNavigationScreen(), // Add this
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomAppBar(
        notchMargin: 8.0,
        shape: const CircularNotchedRectangle(),
        color: Colors.white, // Change this to your preferred color
        elevation: 8, // Add some elevation for better appearance
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // Left side navigation items
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.home,
                      color: _selectedIndex == 0 
                          ? Theme.of(context).primaryColor 
                          : Colors.grey,
                    ),
                    onPressed: () => _onItemTapped(0),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.explore,
                      color: _selectedIndex == 1 
                          ? Theme.of(context).primaryColor 
                          : Colors.grey,
                    ),
                    onPressed: () => _onItemTapped(1),
                  ),
                ],
              ),
            ),
            // Right side navigation items
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.calendar_today,
                      color: _selectedIndex == 2 
                          ? Theme.of(context).primaryColor 
                          : Colors.grey,
                    ),
                    onPressed: () => _onItemTapped(2),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.person,
                      color: _selectedIndex == 4 
                          ? Theme.of(context).primaryColor 
                          : Colors.grey,
                    ),
                    onPressed: () => _onItemTapped(4),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _onItemTapped(3), // Report incident
        backgroundColor: Theme.of(context).primaryColor,
        shape: const CircleBorder(),
        child: const Icon(Icons.touch_app, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}