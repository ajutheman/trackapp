import 'package:flutter/material.dart';
import 'package:truck_app/features/connect/screens/connect_screen.dart';
import 'package:truck_app/features/home/screens/home_screen_user.dart';
import 'package:truck_app/features/profile/screen/profile_screen_user.dart';
import 'package:truck_app/features/vehicle/screens/vehicle_list_screen.dart';

import '../../../core/constants/dummy_data.dart';
import '../../../core/theme/app_colors.dart';
import '../../post/screens/add_trip_screen.dart';
import '../../post/screens/my_trip_screen.dart';
import '../../post/screens/add_post_screen.dart';
import '../../post/screens/my_post_screen.dart';

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
    ConnectScreen(),
    AddPostScreen(), // Customer requests (posts) for users
    MyPostScreen(), // My customer requests for users
    const ProfileScreenUser(),
  ];

  void _onItemTapped(int index) {
    if (index == 2) {
      // Handle center button (Create Post) - Navigate to AddPostScreen for customer requests
      Navigator.push(context, MaterialPageRoute(builder: (_) => const AddPostScreen()));
      return;
    }
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _screens),
      floatingActionButton: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(colors: [AppColors.secondary, AppColors.secondary.withOpacity(0.8)], begin: Alignment.topLeft, end: Alignment.bottomRight),
          boxShadow: [BoxShadow(color: AppColors.secondary.withOpacity(0.4), blurRadius: 12, offset: const Offset(0, 4), spreadRadius: 2)],
          border: Border.all(color: Colors.white, width: 3),
        ),
        child: FloatingActionButton(
          onPressed: () => _onItemTapped(2),
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: const Icon(Icons.add, color: Colors.white, size: 32),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 0,
        color: Colors.white,
        elevation: 0,
        child: Container(
          height: 45,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildNavItem(Icons.home_rounded, Icons.home_outlined, 'Home', 0),
              _buildNavItem(Icons.chat_bubble_rounded, Icons.chat_bubble_outline, 'Connections', 1),
              const SizedBox(width: 48), // Space for FAB
              _buildNavItem(Icons.description_rounded, Icons.description_outlined, 'My Posts', 3),
              _buildNavItem(Icons.person_rounded, Icons.person_outline, 'Account', 4),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData activeIcon, IconData inactiveIcon, String label, int index) {
    final isSelected = _selectedIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () => _onItemTapped(index),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(isSelected ? activeIcon : inactiveIcon, color: isSelected ? AppColors.secondary : AppColors.textSecondary, size: 26),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(fontSize: 12, fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500, color: isSelected ? AppColors.secondary : AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
