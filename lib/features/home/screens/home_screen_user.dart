import 'package:flutter/material.dart';
import 'package:truck_app/core/constants/app_images.dart';

import '../../../core/theme/app_colors.dart';
import '../model/connect.dart';
import '../model/post.dart'; // Assuming you have this model
import '../widgets/post_card.dart';
import '../widgets/recent_connect_card.dart'; // Assuming you have this widget

// Placeholder for a simple ConnectCard for Recent Connects

class HomeScreenUser extends StatefulWidget {
  const HomeScreenUser({super.key});

  @override
  State<HomeScreenUser> createState() => _HomeScreenUserState();
}

class _HomeScreenUserState extends State<HomeScreenUser> {
  // Mock data for Recent Connects
  final List<Connect> _connects = [
    Connect(
      id: 'c1',
      postName: 'Load Request #54321',
      replyUserName: 'Faheem',
      postTitle: 'FMCG delivery from Calicut to Trivandrum',
      dateTime: DateTime.now().subtract(const Duration(hours: 1)),
      status: ConnectStatus.pending,
    ),
    Connect(
      id: 'c2',
      postName: 'Vehicle Availability #90876',
      replyUserName: 'Anjali',
      postTitle: 'AC container for pharma supplies',
      dateTime: DateTime.now().subtract(const Duration(days: 3)),
      status: ConnectStatus.accepted,
    ),
    Connect(
      id: 'c3',
      postName: 'Load Request #33445',
      replyUserName: 'Rahul',
      postTitle: 'Furniture shifting to Thrissur',
      dateTime: DateTime.now().subtract(const Duration(minutes: 30)),
      status: ConnectStatus.completed,
    ),
    Connect(
      id: 'c4',
      postName: 'Vehicle Availability #55667',
      replyUserName: 'Sneha',
      postTitle: 'Open truck available for bulk goods',
      dateTime: DateTime.now().subtract(const Duration(days: 1, hours: 5)),
      status: ConnectStatus.rejected,
    ),
    Connect(
      id: 'c5',
      postName: 'Load Request #99887',
      replyUserName: 'Manoj Kumar',
      postTitle: 'Urgent delivery to Hyderabad within 24h',
      dateTime: DateTime.now().subtract(const Duration(hours: 3)),
      status: ConnectStatus.pending,
    ),
  ];

  // Mock data for List of Posts
  final List<Post> _userPosts = [
    Post(
      title: 'Looking for a truck to move household items',
      description: 'Need a medium-sized truck to shift goods from Malappuram to Kochi next week.',
      date: DateTime.now().subtract(const Duration(hours: 5)),
      imageUrl: 'https://via.placeholder.com/600x400.png?text=Household+Move',
    ),
    Post(
      title: 'Urgent transport for fragile goods',
      description: 'Require a secure vehicle for delicate items, preferably with air conditioning.',
      date: DateTime.now().subtract(const Duration(days: 1)),
      imageUrl: 'https://via.placeholder.com/600x400.png?text=Fragile+Transport',
    ),
    Post(
      title: 'Daily commute service for office staff',
      description: 'Seeking a reliable tempo traveller for staff pick-up and drop-off.',
      date: DateTime.now().subtract(const Duration(days: 2)),
      imageUrl: 'https://via.placeholder.com/600x400.png?text=Office+Commute',
    ),
    Post(
      title: 'Bulk cement delivery to construction site',
      description: 'Looking for a large truck to deliver cement bags to a site in Thrissur.',
      date: DateTime.now().subtract(const Duration(days: 3)),
      imageUrl: 'https://via.placeholder.com/600x400.png?text=Cement+Delivery',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildRecentConnectsSection(), const SizedBox(height: 24), _buildListOfPostsSection()]),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      titleSpacing: 0,
      scrolledUnderElevation: 0,
      title: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Center: App Logo
            SizedBox(height: 35, child: Image.asset(AppImages.appIconWithName)),
            // Right: Notification Icon
            IconButton(
              icon: Icon(Icons.notifications_none_rounded, color: AppColors.textPrimary, size: 28),
              onPressed: () {
                _showSnackBar('Notifications tapped!');
              },
              style: IconButton.styleFrom(
                backgroundColor: AppColors.surface,
                padding: const EdgeInsets.all(12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentConnectsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Connects', // Section title
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 120, // Height for horizontal list
          child:
              _connects.isEmpty
                  ? Center(child: Text('No recent connects yet.', style: TextStyle(color: AppColors.textSecondary)))
                  : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _connects.length,
                    itemBuilder: (context, index) {
                      return RecentConnectCard(connect: _connects[index]);
                    },
                  ),
        ),
      ],
    );
  }

  Widget _buildListOfPostsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Available Posts', // Section title
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 16),
        _userPosts.isEmpty
            ? Center(child: Text('No posts available at the moment.', style: TextStyle(color: AppColors.textSecondary)))
            : ListView.builder(
              shrinkWrap: true, // Important for nested list views
              physics: const NeverScrollableScrollPhysics(), // Important for nested list views
              itemCount: _userPosts.length,
              itemBuilder: (context, index) {
                return Padding(padding: const EdgeInsets.only(bottom: 12.0), child: PostCard(post: _userPosts[index]));
              },
            ),
      ],
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), duration: const Duration(seconds: 1)));
  }
}
