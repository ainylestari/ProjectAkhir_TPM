import 'package:flutter/material.dart';
import '/screens/home.dart';
import '/screens/explore.dart';
import '/screens/planner.dart';
import '/screens/journal.dart';
import '/screens/profile.dart';


class Navigation extends StatefulWidget {
  const Navigation({super.key});

  @override
  State<Navigation> createState() => _NavigationState();
}

class _NavigationState extends State<Navigation> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> _pages = [
    HomeScreen(action: (index) {
      setState(() {
        _selectedIndex = index;
      });
    }),
    const ExploreScreen(),
    const PlannerScreen(),
    const JournalScreen(),
    const ProfileScreen(),
  ];

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),

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
            selectedIcon: Icon(Icons.home_rounded, color: Colors.purple),
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.explore_rounded, color: Colors.purple),
            icon: Icon(Icons.explore_outlined),
            label: 'Explore',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.calendar_today_rounded, color: Colors.purple),
            icon: Icon(Icons.calendar_today_outlined),
            label: 'Mood Plan',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.book_rounded, color: Colors.purple),
            icon: Icon(Icons.book_outlined),
            label: 'Journals',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.person_rounded, color: Colors.purple),
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}