import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_colors.dart';
import '../model/connect.dart';
import '../model/post.dart';
import '../widgets/connect_card.dart';
import '../widgets/post_card.dart';

class HomeScreenDriver extends StatefulWidget {
  const HomeScreenDriver({super.key});

  @override
  State<HomeScreenDriver> createState() => _HomeScreenDriverState();
}

class _HomeScreenDriverState extends State<HomeScreenDriver> {
  // Mock data for Connect Cards
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

  // Mock data for Latest Posts
  final List<Post> _latestPosts = [
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
          children: [_buildConnectStatusSection(), const SizedBox(height: 24), _buildConnectRequestsSection(), const SizedBox(height: 24), _buildLatestPostsSection()],
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
            // Left: Verification Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.primary, width: 1)),
              child: Row(
                children: [
                  Icon(Icons.verified_outlined, color: AppColors.primary, size: 18),
                  const SizedBox(width: 8),
                  Text('Verified Partner', style: TextStyle(color: AppColors.primary, fontSize: 14, fontWeight: FontWeight.w600)),
                ],
              ),
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

  Widget _buildConnectStatusSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Connect Status', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          const SizedBox(height: 12),
          Text('You have 3 new connect requests pending. Review them now!', style: TextStyle(fontSize: 16, color: AppColors.textSecondary)),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                _showSnackBar('Reset Connect Status tapped!');
                // Implement logic to reset status or navigate to connect screen
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 5,
                shadowColor: AppColors.secondary.withOpacity(0.4),
              ),
              child: Text('View New Connects', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectRequestsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Connect Requests', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        const SizedBox(height: 16),
        // Display Connect Cards
        ..._connects.map(
          (connect) => Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: ConnectCard(
              connect: connect,
              onAccept: (connect) {
                _showSnackBar('Accepted connect from ${connect.replyUserName}');
                // Implement actual accept logic
              },
              onReject: (connect) {
                _showSnackBar('Rejected connect from ${connect.replyUserName}');
                // Implement actual reject logic
              },
              onCall: (phoneNumber) => _makePhoneCall(phoneNumber),
              // Mock phone number
              onWhatsApp: (phoneNumber) => _launchWhatsApp(phoneNumber), // Mock phone number
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLatestPostsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Latest Posts', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            TextButton(
              onPressed: () {
                _showSnackBar('View All Latest Posts tapped!');
                // Navigate to a screen showing all posts
              },
              child: Text('View All', style: TextStyle(color: AppColors.secondary, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Display Latest Posts
        ..._latestPosts.take(3).map((post) => Padding(padding: const EdgeInsets.only(bottom: 12.0), child: PostCard(post: post))),
      ],
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), duration: const Duration(seconds: 1)));
  }

  // Function to launch phone call
  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      _showSnackBar('Could not launch $phoneNumber');
    }
  }

  // Function to launch WhatsApp chat
  Future<void> _launchWhatsApp(String phoneNumber) async {
    // WhatsApp URL scheme for Android and iOS
    final Uri whatsappUri = Uri.parse('whatsapp://send?phone=$phoneNumber');
    if (await canLaunchUrl(whatsappUri)) {
      await launchUrl(whatsappUri);
    } else {
      _showSnackBar('WhatsApp is not installed or could not launch $phoneNumber');
    }
  }
}
