import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:truck_app/core/constants/app_images.dart';

import '../../../core/constants/dummy_data.dart';
import '../../../core/theme/app_colors.dart';
import '../../notification/screen/notification_screen.dart';
import '../model/post.dart';
import '../widgets/post_card.dart';
import '../widgets/recent_connect_card.dart';
import '../bloc/posts_bloc.dart';

// Placeholder for a simple ConnectCard for Recent Connects

class HomeScreenUser extends StatefulWidget {
  const HomeScreenUser({super.key});

  @override
  State<HomeScreenUser> createState() => _HomeScreenUserState();
}

class _HomeScreenUserState extends State<HomeScreenUser> {
  // Posts from API will be managed by BLoC
  List<Post> _posts = [];
  bool _isLoading = false;
  String? _errorMessage;

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
  void initState() {
    super.initState();
    // Fetch posts when the screen initializes
    context.read<PostsBloc>().add(const FetchAllPosts(page: 1, limit: 20));
  }

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
      body: BlocListener<PostsBloc, PostsState>(
        listener: (context, state) {
          if (state is PostsLoaded) {
            setState(() {
              _posts = state.posts;
              _isLoading = false;
              _errorMessage = null;
            });
          } else if (state is PostsLoading) {
            setState(() {
              _isLoading = true;
              _errorMessage = null;
            });
          } else if (state is PostsError) {
            setState(() {
              _isLoading = false;
              _errorMessage = state.message;
            });
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: Colors.red));
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [_buildHeaderLocationSelector(), const SizedBox(height: 24), _buildRecentConnectsSection(), const SizedBox(height: 24), _buildListOfPostsSection()],
          ),
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Available Posts', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            IconButton(
              onPressed: () {
                // Refresh posts
                context.read<PostsBloc>().add(RefreshPosts(pickupLocation: _fromLocation, dropLocation: _toLocation));
              },
              icon: Icon(Icons.refresh_rounded, color: AppColors.secondary, size: 24),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (_isLoading)
          const Center(child: Padding(padding: EdgeInsets.all(20.0), child: CircularProgressIndicator()))
        else if (_errorMessage != null)
          Center(
            child: Column(
              children: [
                Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: 8),
                Text(_errorMessage!, style: TextStyle(color: Colors.red), textAlign: TextAlign.center),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    context.read<PostsBloc>().add(const FetchAllPosts(page: 1, limit: 20));
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          )
        else if (_posts.isEmpty)
          Center(
            child: Column(
              children: [
                Icon(Icons.inbox_outlined, color: AppColors.textSecondary, size: 48),
                const SizedBox(height: 8),
                Text('No posts available at the moment.', style: TextStyle(color: AppColors.textSecondary)),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    context.read<PostsBloc>().add(const FetchAllPosts(page: 1, limit: 20));
                  },
                  child: const Text('Refresh'),
                ),
              ],
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _posts.length,
            itemBuilder: (context, index) {
              return Padding(padding: const EdgeInsets.only(bottom: 12.0), child: PostCard(post: _posts[index]));
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
              const SizedBox(height: 12),
              // Swap locations button
              if (_fromLocation != null || _toLocation != null)
                Center(
                  child: IconButton(
                    onPressed: _swapLocations,
                    icon: Icon(Icons.swap_vert_rounded, color: AppColors.secondary, size: 28),
                    style: IconButton.styleFrom(backgroundColor: AppColors.secondary.withOpacity(0.1), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  ),
                ),
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

      // Filter posts based on selected locations
      _filterPostsByLocation();
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

    // Filter posts after swapping locations
    _filterPostsByLocation();
  }

  void _filterPostsByLocation() {
    // Fetch posts with location filters
    context.read<PostsBloc>().add(FetchAllPosts(pickupLocation: _fromLocation, dropLocation: _toLocation, page: 1, limit: 20));
  }
}
