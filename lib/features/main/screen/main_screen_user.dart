import 'package:flutter/material.dart';
import 'package:truck_app/features/connect/screens/connect_screen.dart';
import 'package:truck_app/features/home/screens/home_screen_user.dart';
import 'package:truck_app/features/profile/screen/profile_screen_user.dart';

import '../../../core/constants/dummy_data.dart';
import '../../../core/theme/app_colors.dart';
import '../../post/screens/add_post_screen.dart';

class MainScreenUser extends StatefulWidget {
  const MainScreenUser({super.key});

  @override
  State<MainScreenUser> createState() => _MainScreenUserState();
}

class _MainScreenUserState extends State<MainScreenUser> {
  int _selectedIndex = 0;

  // List of screens to be displayed in the BottomNavigationBar for users
  final List<Widget> _screens = [
    const HomeScreenUser(),
    ConnectScreen(connections: DummyData.userConnections), // Reusing the ConnectScreen as it's common
    AddPostScreen(),
    const ProfileScreenUser(),
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
