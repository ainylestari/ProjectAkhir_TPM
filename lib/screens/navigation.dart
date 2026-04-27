import 'package:flutter/material.dart';
import '/screens/home.dart';
import '/screens/explore.dart';
import '/screens/planner.dart';
import '/screens/tools.dart';
import '/screens/profile.dart';


class Navigation extends StatefulWidget {
  const Navigation({super.key});

  @override
  State<Navigation> createState() => _NavigationState();
}

class _NavigationState extends State<Navigation> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomeScreen(),
    const ExploreScreen(),
    const PlannerScreen(),
    const ToolsScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],

      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        indicatorColor: Colors.purple.withOpacity(0.1), 
        backgroundColor: Colors.white,
        destinations: const [
          NavigationDestination(
            selectedIcon: Icon(Icons.home, color: Colors.purple),
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.explore, color: Colors.purple),
            icon: Icon(Icons.explore_outlined),
            label: 'Explore',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.calendar_today, color: Colors.purple),
            icon: Icon(Icons.calendar_today_outlined),
            label: 'Mood Plan',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.build, color: Colors.purple),
            icon: Icon(Icons.build_outlined),
            label: 'Tools',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.person, color: Colors.purple),
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}