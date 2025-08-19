// lib/features/post/screens/my_posts_screen.dart
import 'package:flutter/material.dart';
import 'package:truck_app/core/theme/app_colors.dart'; // Ensure this path is correct
import 'package:truck_app/features/post/screens/add_post_screen.dart'; // Import the AddPostScreen

// A simple model for a user's post (assuming a structure similar to add_post_screen)
class UserPost {
  final String id;
  final String title;
  final String description;
  final String type; // e.g., 'Load', 'Truck'
  final String? goodsType; // For Load posts
  final String? vehicleType; // For Truck posts
  final String pickupLocation;
  final String dropLocation;
  final DateTime postDate;
  bool isActive; // To simulate if the post is still active/open

  UserPost({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    this.goodsType,
    this.vehicleType,
    required this.pickupLocation,
    required this.dropLocation,
    required this.postDate,
    this.isActive = true,
  });

  // Helper method to create a copy with updated properties (useful for editing)
  UserPost copyWith({
    String? title,
    String? description,
    String? type,
    String? goodsType,
    String? vehicleType,
    String? pickupLocation,
    String? dropLocation,
    DateTime? postDate,
    bool? isActive,
  }) {
    return UserPost(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      goodsType: goodsType ?? this.goodsType,
      vehicleType: vehicleType ?? this.vehicleType,
      pickupLocation: pickupLocation ?? this.pickupLocation,
      dropLocation: dropLocation ?? this.dropLocation,
      postDate: postDate ?? this.postDate,
      isActive: isActive ?? this.isActive,
    );
  }
}

class MyPostsScreen extends StatefulWidget {
  const MyPostsScreen({super.key});

  @override
  State<MyPostsScreen> createState() => _MyPostsScreenState();
}

class _MyPostsScreenState extends State<MyPostsScreen> {
  // Dummy data for user posts
  // In a real application, this would come from a backend or state management
  final List<UserPost> _myPosts = [
    UserPost(
      id: 'p1',
      title: 'Need truck for furniture transport',
      description: 'Looking for a small truck to move household furniture from Malappuram to Kochi. Flexible dates.',
      type: 'Load',
      goodsType: 'Furniture',
      pickupLocation: 'Malappuram',
      dropLocation: 'Kochi',
      postDate: DateTime.now().subtract(const Duration(days: 2)),
      isActive: true,
    ),
    UserPost(
      id: 'p2',
      title: 'Available 10-wheel truck for long haul',
      description: '10-wheel truck available for long haul, any goods. Ready to travel across South India.',
      type: 'Truck',
      vehicleType: '10-wheel truck',
      pickupLocation: 'Coimbatore',
      dropLocation: 'Bangalore',
      // This might be a base or current location
      postDate: DateTime.now().subtract(const Duration(days: 5)),
      isActive: true,
    ),
    UserPost(
      id: 'p3',
      title: 'Urgent: Books transport to Thrissur',
      description: 'Need a mini-truck for transporting 50 cartons of books from Kozhikode to Thrissur by tomorrow.',
      type: 'Load',
      goodsType: 'Books',
      pickupLocation: 'Kozhikode',
      dropLocation: 'Thrissur',
      postDate: DateTime.now().subtract(const Duration(days: 10)),
      isActive: false, // Example of an inactive/completed post
    ),
    UserPost(
      id: 'p4',
      title: 'Small van available for local delivery',
      description: 'Small commercial van available for local deliveries within Malappuram district.',
      type: 'Truck',
      vehicleType: 'Van',
      pickupLocation: 'Malappuram',
      dropLocation: 'Malappuram',
      postDate: DateTime.now().subtract(const Duration(days: 15)),
      isActive: true,
    ),
  ];

  void _editPost(UserPost post) async {
    // Navigate to AddPostScreen, passing the post to be edited
    // final result = await Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => AddPostScreen(postToEdit: post),
    //   ),
    // );

    // If the AddPostScreen returns a result (e.g., indicating an update)
    // if (result != null && result is bool && result) {
    //   // In a real app, you would refresh the data from your backend
    //   // For this dummy data, we'll just show a success message
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(content: Text('Post "${post.title}" updated successfully!')),
    //   );
    //   // You might need to manually update the _myPosts list here if not fetching from a backend
    //   // For now, we'll just re-render to reflect potential internal changes if any were made.
    //   setState(() {});
    // }
  }

  void _deletePost(UserPost post) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Post'),
          content: Text('Are you sure you want to delete "${post.title}"?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel', style: TextStyle(color: AppColors.textPrimary)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
              child: const Text('Delete', style: TextStyle(color: Colors.white)),
              onPressed: () {
                setState(() {
                  _myPosts.removeWhere((p) => p.id == post.id);
                });
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Post "${post.title}" deleted.')));
              },
            ),
          ],
        );
      },
    );
  }

  void _togglePostStatus(UserPost post) {
    setState(() {
      final index = _myPosts.indexWhere((p) => p.id == post.id);
      if (index != -1) {
        _myPosts[index].isActive = !_myPosts[index].isActive;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Post "${post.title}" is now ${_myPosts[index].isActive ? 'active' : 'inactive'}.')));
      }
    });
  }

  void _navigateToAddPostScreen() async {
    final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => const AddPostScreen()));
    // If a new post was successfully added, you might want to refresh the list
    if (result != null && result is bool && result) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('New post added successfully! (Refresh data from backend)')));
      // In a real app, you would refetch your posts here from the backend
      // For this dummy data, we'll just re-render.
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Posts', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
        foregroundColor: Colors.black,
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
      ),
      body:
          _myPosts.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.post_add_rounded, size: 80, color: AppColors.textSecondary.withOpacity(0.5)),
                    const SizedBox(height: 16),
                    Text('You haven\'t created any posts yet.', style: TextStyle(fontSize: 16, color: AppColors.textSecondary)),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _navigateToAddPostScreen,
                      icon: const Icon(Icons.add_circle_outline_rounded, color: Colors.white),
                      label: const Text('Create New Post', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                    ),
                  ],
                ),
              )
              : ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: _myPosts.length,
                itemBuilder: (context, index) {
                  final post = _myPosts[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12.0),
                    color: AppColors.surface,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: post.isActive ? AppColors.secondary : AppColors.textSecondary.withOpacity(0.3), width: 0.5),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: Text(
                                  post.title,
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: post.type == 'Load' ? AppColors.info.withOpacity(0.2) : AppColors.success.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  post.type,
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: post.type == 'Load' ? AppColors.info : AppColors.success),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(post.description, style: const TextStyle(fontSize: 14, color: AppColors.textSecondary), maxLines: 2, overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.location_on_rounded, size: 16, color: AppColors.textSecondary),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  '${post.pickupLocation} to ${post.dropLocation}',
                                  style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          if (post.goodsType != null) ...[
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.category_rounded, size: 16, color: AppColors.textSecondary),
                                const SizedBox(width: 4),
                                Text('Goods: ${post.goodsType}', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                              ],
                            ),
                          ],
                          if (post.vehicleType != null) ...[
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.local_shipping_rounded, size: 16, color: AppColors.textSecondary),
                                const SizedBox(width: 4),
                                Text('Vehicle: ${post.vehicleType}', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                              ],
                            ),
                          ],
                          const SizedBox(height: 8),
                          Divider(color: AppColors.textSecondary.withOpacity(0.2)),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(post.isActive ? Icons.check_circle_rounded : Icons.cancel_rounded, size: 16, color: post.isActive ? AppColors.success : AppColors.error),
                                  const SizedBox(width: 4),
                                  Text(
                                    post.isActive ? 'Active' : 'Inactive',
                                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: post.isActive ? AppColors.success : AppColors.error),
                                  ),
                                ],
                              ),
                              Text('Posted: ${_formatDate(post.postDate)}', style: TextStyle(fontSize: 12, color: AppColors.textSecondary.withOpacity(0.7))),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton.icon(
                                onPressed: () => _togglePostStatus(post),
                                icon: Icon(post.isActive ? Icons.toggle_off_rounded : Icons.toggle_on_rounded, color: post.isActive ? AppColors.error : AppColors.success),
                                label: Text(post.isActive ? 'Mark Inactive' : 'Mark Active', style: TextStyle(color: post.isActive ? AppColors.error : AppColors.success)),
                              ),
                              const SizedBox(width: 8),
                              TextButton.icon(
                                onPressed: () => _editPost(post),
                                icon: const Icon(Icons.edit_rounded, color: AppColors.primary),
                                label: const Text('Edit', style: TextStyle(color: AppColors.primary)),
                              ),
                              const SizedBox(width: 8),
                              TextButton.icon(
                                onPressed: () => _deletePost(post),
                                icon: const Icon(Icons.delete_rounded, color: AppColors.error),
                                label: const Text('Delete', style: TextStyle(color: AppColors.error)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      floatingActionButton:
          _myPosts.isNotEmpty
              ? FloatingActionButton.extended(
                onPressed: _navigateToAddPostScreen,
                label: const Text('Add New Post', style: TextStyle(color: Colors.white)),
                icon: const Icon(Icons.add_circle_outline_rounded, color: Colors.white),
                backgroundColor: AppColors.primary,
              )
              : null, // Don't show FAB if empty state has "Create New Post" button
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
