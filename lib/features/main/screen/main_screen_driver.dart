import 'package:flutter/material.dart';
import 'package:truck_app/core/constants/dummy_data.dart';
import 'package:truck_app/features/post/screens/add_post_screen.dart';
import 'package:truck_app/features/connect/screens/connect_screen.dart';

import '../../../core/theme/app_colors.dart';
import '../../home/screens/home_screen_driver.dart';
import '../../profile/screen/profile_screen_driver.dart';

class MainScreenDriver extends StatefulWidget {
  const MainScreenDriver({super.key});

  @override
  State<MainScreenDriver> createState() => _MainScreenDriverState();
}

class _MainScreenDriverState extends State<MainScreenDriver> {
  int _selectedIndex = 0;

  // List of screens to be displayed in the BottomNavigationBar
  final List<Widget> _screens = [
    const HomeScreenDriver(),
    // Placeholder for Connect Screen
    ConnectScreen(connections: DummyData.driverConnections), // Placeholder for Add Post Screen
    AddPostScreen(),
    const ProfileScreenDriver(),
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
        // Use IndexedStack to preserve state of screens
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.secondary,
        unselectedItemColor: AppColors.textSecondary,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home_rounded), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.link_outlined), activeIcon: Icon(Icons.link_rounded), label: 'Connect'),
          BottomNavigationBarItem(icon: Icon(Icons.add_box_outlined), activeIcon: Icon(Icons.add_box_rounded), label: 'Add Post'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person_rounded), label: 'Profile'),
        ],
      ),
    );
  }
}
