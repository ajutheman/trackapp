import 'package:flutter/material.dart';
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
      postName: 'Load Request #12345',
      replyUserName: 'Rinu',
      postTitle: 'Urgent: Goods from Malappuram to Kochi',
      dateTime: DateTime.now().subtract(const Duration(hours: 2)),
      status: ConnectStatus.pending,
    ),
    Connect(
      id: 'c2',
      postName: 'Vehicle Availability #67890',
      replyUserName: 'Miya',
      postTitle: 'Truck available for Chennai route',
      dateTime: DateTime.now().subtract(const Duration(days: 1)),
      status: ConnectStatus.accepted,
    ),
    Connect(
      id: 'c3',
      postName: 'Load Request #11223',
      replyUserName: 'Xavier',
      postTitle: 'Heavy machinery transport to Bangalore',
      dateTime: DateTime.now().subtract(const Duration(minutes: 45)),
      status: ConnectStatus.pending,
    ),
    Connect(
      id: 'c4',
      postName: 'Load Request #44556',
      replyUserName: 'Marco',
      postTitle: 'Fragile items delivery to Delhi',
      dateTime: DateTime.now().subtract(const Duration(days: 2)),
      status: ConnectStatus.rejected,
    ),
    Connect(
      id: 'c5',
      postName: 'Vehicle Availability #77889',
      replyUserName: 'John Smith',
      postTitle: 'Mini truck for local shifting',
      dateTime: DateTime.now().subtract(const Duration(hours: 5)),
      status: ConnectStatus.completed,
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildRecentConnectsSection(),
            const SizedBox(height: 24),
            _buildListOfPostsSection(),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      titleSpacing: 0,
      title: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Center: App Logo
            Row(
              children: [
                Icon(Icons.local_shipping_outlined, color: AppColors.primary, size: 28),
                const SizedBox(width: 8),
                Text(
                  'TruckApp', // Placeholder for App Logo text
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
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
          child: _connects.isEmpty
              ? Center(
            child: Text(
              'No recent connects yet.',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          )
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
            ? Center(
          child: Text(
            'No posts available at the moment.',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        )
            : ListView.builder(
          shrinkWrap: true, // Important for nested list views
          physics: const NeverScrollableScrollPhysics(), // Important for nested list views
          itemCount: _userPosts.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: PostCard(post: _userPosts[index]),
            );
          },
        ),
      ],
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), duration: const Duration(seconds: 1)));
  }
}