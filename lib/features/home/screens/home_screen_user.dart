import 'package:flutter/material.dart';
import 'package:truck_app/core/constants/app_images.dart';

import '../../../core/constants/dummy_data.dart';
import '../../../core/theme/app_colors.dart';
import '../../notification/screen/notification_screen.dart';
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

  // Header: From/To location inputs
  String? _fromLocation;
  String? _toLocation;

  final TextEditingController _fromController = TextEditingController();
  final TextEditingController _toController = TextEditingController();
  final List<String> _sampleLocations = [
    'Kochi',
    'Thrissur',
    'Thiruvananthapuram',
    'Kozhikode',
    'Malappuram',
    'Kannur',
    'Palakkad',
    'Alappuzha',
    'Kottayam',
    'Idukki',
    'Ernakulam',
    'Bengaluru',
    'Chennai',
    'Hyderabad',
    'Mumbai',
  ];

  @override
  void dispose() {
    _fromController.dispose();
    _toController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [_buildHeaderLocationSelector(), const SizedBox(height: 24), _buildRecentConnectsSection(), const SizedBox(height: 24), _buildListOfPostsSection()],
        ),
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
                Navigator.push(context, MaterialPageRoute(builder: (_) => NotificationScreen()));
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
              DummyData.userConnections.isEmpty
                  ? Center(child: Text('No recent connects yet.', style: TextStyle(color: AppColors.textSecondary)))
                  : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: DummyData.userConnections.length,
                    itemBuilder: (context, index) {
                      return RecentConnectCard(connect: DummyData.userConnections[index]);
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

  // Header UI - From/To selector
  Widget _buildHeaderLocationSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 6))],
            border: Border.all(color: Colors.black.withOpacity(0.05)),
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              _buildLocationRow(
                label: 'From',
                value: _fromLocation,
                icon: Icons.my_location_rounded,
                iconColor: Colors.green.shade600,
                onTap: () => _openLocationInput(isFrom: true),
              ),
              const Divider(height: 16),
              _buildLocationRow(label: 'To', value: _toLocation, icon: Icons.location_on_rounded, iconColor: Colors.red.shade600, onTap: () => _openLocationInput(isFrom: false)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLocationRow({required String label, required String? value, required IconData icon, required Color iconColor, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(color: iconColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, size: 20, color: iconColor),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                const SizedBox(height: 2),
                Text(
                  value == null || value.isEmpty ? 'Choose location' : value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
          Icon(Icons.edit_location_alt_rounded, color: AppColors.textSecondary),
        ],
      ),
    );
  }

  Future<void> _openLocationInput({required bool isFrom}) async {
    final controller = isFrom ? _fromController : _toController;
    controller.text = isFrom ? (_fromLocation ?? '') : (_toLocation ?? '');

    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setLocalState) {
            List<String> filtered =
                _sampleLocations.where((e) => controller.text.trim().isEmpty ? true : e.toLowerCase().contains(controller.text.trim().toLowerCase())).take(12).toList();

            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Text(isFrom ? 'Set From location' : 'Set To location'),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: controller,
                      autofocus: true,
                      textInputAction: TextInputAction.done,
                      onChanged: (_) => setLocalState(() {}),
                      onSubmitted: (_) => Navigator.pop(context, controller.text.trim()),
                      decoration: InputDecoration(
                        hintText: 'Type a place, area or city',
                        prefixIcon: Icon(isFrom ? Icons.my_location_rounded : Icons.location_on_rounded),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (filtered.isNotEmpty)
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 240),
                        child: ListView.separated(
                          shrinkWrap: true,
                          itemCount: filtered.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final item = filtered[index];
                            return ListTile(
                              dense: true,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                              leading: Icon(Icons.place_rounded, color: AppColors.textSecondary),
                              title: Text(item, maxLines: 1, overflow: TextOverflow.ellipsis),
                              onTap: () => Navigator.pop(context, item),
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                ElevatedButton(onPressed: () => Navigator.pop(context, controller.text.trim()), child: const Text('Save')),
              ],
            );
          },
        );
      },
    );

    if (result != null) {
      setState(() {
        if (isFrom) {
          _fromLocation = result;
        } else {
          _toLocation = result;
        }
      });
    }
  }

  void _swapLocations() {
    if ((_fromLocation ?? '').isEmpty && (_toLocation ?? '').isEmpty) {
      _showSnackBar('Nothing to swap');
      return;
    }
    setState(() {
      final temp = _fromLocation;
      _fromLocation = _toLocation;
      _toLocation = temp;
    });
  }
}
