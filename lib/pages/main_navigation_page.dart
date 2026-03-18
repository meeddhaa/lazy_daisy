import 'package:flutter/material.dart';
import 'package:mini_habit_tracker/pages/mood_tracker_page.dart';


// This is a wrapper that provides navigation between Habits and Mood Tracker
class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _selectedIndex = 0;

  // Replace this with your actual HomePage
  final List<Widget> _pages = [
    // const HomePage(), // Your existing habit tracker home page
    const Center(child: Text('Import your HomePage here')), // Placeholder
    const MoodTrackerPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: Theme.of(context).colorScheme.surface,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Theme.of(context).colorScheme.secondary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.check_circle_outline),
            activeIcon: Icon(Icons.check_circle),
            label: 'Habits',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.mood_outlined),
            activeIcon: Icon(Icons.mood),
            label: 'Mood',
          ),
        ],
      ),
    );
  }
}
