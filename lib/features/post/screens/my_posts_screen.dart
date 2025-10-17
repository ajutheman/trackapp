// lib/features/post/screens/my_posts_screen.dart
import 'package:flutter/material.dart';
import 'package:truck_app/core/theme/app_colors.dart';
import 'package:truck_app/features/post/screens/add_post_screen.dart';
import 'package:truck_app/features/home/model/post.dart';
import 'package:truck_app/features/home/widgets/post_card.dart';

class MyPostsScreen extends StatefulWidget {
  const MyPostsScreen({super.key});

  @override
  State<MyPostsScreen> createState() => _MyPostsScreenState();
}

class _MyPostsScreenState extends State<MyPostsScreen> {
  // Dummy data for user posts using the Post model
  final List<Post> _myPosts = [
    Post(
      id: '68ee48f0cfd19f82c673a512',
      title: 'Fresh Vegetables Delivery to Kochi',
      description: 'Transporting fresh vegetables from Pathanamthitta to Kochi via Kottayam.',
      date: DateTime.now().subtract(const Duration(hours: 1)),
      routeGeoJSON: RouteGeoJSON(
        type: 'LineString',
        coordinates: [
          [76.7704, 9.2645],
          [76.5212, 9.5916],
          [76.3516, 10.1076],
          [76.2875, 9.9674],
        ],
      ),
      distance: Distance(value: 135.5, text: '135.5 km'),
      duration: TripDuration(value: 150, text: '2 hours 30 mins'),
      currentLocation: TripLocation(coordinates: [76.7704, 9.2645]),
      tripAddedBy: User(id: '68e0156e2655da19d6948c7d', name: 'Current User', phone: '1212121212', email: '1212@sdasd.com'),
      vehicleDetails: Vehicle(id: '68ee48c8cfd19f82c673a4da', vehicleNumber: 'KL12AB1212', vehicleType: 'Mini Truck', vehicleBodyType: 'Refrigerated'),
      driver: User(id: '68e0156e2655da19d6948c7d', name: 'Self Drive', phone: '1212121212', email: '1212@sdasd.com'),
      selfDrive: true,
      goodsTypeDetails: GoodsType(id: '684aa733b88048daeaebff93', name: 'Food', description: 'Food products and consumables'),
      tripStartLocation: TripLocation(address: 'Pathanamthitta Bus Stand, Kerala', coordinates: [76.7704, 9.2645]),
      tripDestination: TripLocation(address: 'Kochi, Kerala', coordinates: [76.2875, 9.9674]),
      tripStartDate: DateTime.now().add(const Duration(hours: 3)),
      tripEndDate: DateTime.now().add(const Duration(hours: 6)),
      isStarted: false,
      isActive: true,
      imageUrl: 'https://via.placeholder.com/600x400.png?text=Vegetable+Delivery',
    ),
    Post(
      id: '68ee49b9cfd19f82c673a5ab',
      title: 'Bulk Construction Material Delivery to Palakkad',
      description: 'Delivering cement and steel rods from Thrissur to Palakkad.',
      date: DateTime.now().subtract(const Duration(days: 1)),
      routeGeoJSON: RouteGeoJSON(
        type: 'LineString',
        coordinates: [
          [76.2133, 10.5276],
          [76.4650, 10.7740],
        ],
      ),
      distance: Distance(value: 90.0, text: '90 km'),
      duration: TripDuration(value: 120, text: '2 hours'),
      currentLocation: TripLocation(coordinates: [76.2133, 10.5276]),
      tripAddedBy: User(id: '68e0156e2655da19d6948c7d', name: 'Current User', phone: '7890123456', email: 'contact@buildlog.com'),
      vehicleDetails: Vehicle(id: '68ee48c8cfd19f82c673a4dc', vehicleNumber: 'KL09XY9999', vehicleType: 'Heavy Truck', vehicleBodyType: 'Open Body'),
      driver: User(id: '68e0156e2655da19d6948c80', name: 'Rajeev Menon', phone: '9988771122', email: 'rajeev@driver.com'),
      selfDrive: false,
      goodsTypeDetails: GoodsType(id: '684aa733b88048daeaebff95', name: 'Construction Materials', description: 'Cement, rods, and construction items'),
      tripStartLocation: TripLocation(address: 'Thrissur Industrial Estate', coordinates: [76.2133, 10.5276]),
      tripDestination: TripLocation(address: 'Palakkad Construction Site', coordinates: [76.4650, 10.7740]),
      tripStartDate: DateTime.now().add(const Duration(days: 1)),
      tripEndDate: DateTime.now().add(const Duration(days: 1, hours: 3)),
      isStarted: false,
      isActive: false,
      imageUrl: 'https://via.placeholder.com/600x400.png?text=Construction+Delivery',
    ),
  ];

  void _editPost(Post post) async {
    // Navigate to AddPostScreen, passing the post to be edited
    // In a real app, you would implement edit functionality
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Edit feature coming soon for "${post.title}"'), backgroundColor: AppColors.info));
  }

  void _deletePost(Post post) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(20)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), shape: BoxShape.circle),
                  child: Icon(Icons.delete_outline_rounded, color: Colors.red, size: 48),
                ),
                const SizedBox(height: 16),
                Text('Delete Post?', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                const SizedBox(height: 8),
                Text(
                  'Are you sure you want to delete "${post.title}"? This action cannot be undone.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          side: BorderSide(color: AppColors.border),
                        ),
                        child: Text('Cancel', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _myPosts.removeWhere((p) => p.id == post.id);
                          });
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Post "${post.title}" deleted successfully'), backgroundColor: Colors.green));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Delete', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _togglePostStatus(Post post) {
    setState(() {
      final index = _myPosts.indexWhere((p) => p.id == post.id);
      if (index != -1) {
        final newStatus = !(post.isActive ?? true);
        _myPosts[index] = post.copyWith(isActive: newStatus);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Post "${post.title}" is now ${newStatus ? 'active' : 'inactive'}'), backgroundColor: newStatus ? Colors.green : Colors.orange));
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
        backgroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 0,
        scrolledUnderElevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.white, Colors.white.withOpacity(0.95)], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
        ),
        centerTitle: true,
        title: Text('My Posts', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w800, fontSize: 22, letterSpacing: -0.5)),
      ),
      body:
          _myPosts.isEmpty
              ? Center(
                child: Container(
                  margin: const EdgeInsets.all(32),
                  padding: const EdgeInsets.all(40),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [AppColors.surface, AppColors.surface.withOpacity(0.5)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: [AppColors.secondary.withOpacity(0.15), AppColors.secondary.withOpacity(0.05)]),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.post_add_rounded, size: 64, color: AppColors.secondary),
                      ),
                      const SizedBox(height: 24),
                      Text('No Posts Yet', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                      const SizedBox(height: 12),
                      Text(
                        'You haven\'t created any posts yet.\nStart by creating your first post!',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 15, color: AppColors.textSecondary, height: 1.5),
                      ),
                      const SizedBox(height: 32),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: [AppColors.secondary, AppColors.secondary.withOpacity(0.85)]),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [BoxShadow(color: AppColors.secondary.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))],
                        ),
                        child: ElevatedButton.icon(
                          onPressed: _navigateToAddPostScreen,
                          icon: const Icon(Icons.add_circle_outline_rounded, color: Colors.white, size: 24),
                          label: const Text('Create New Post', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
              : ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: _myPosts.length,
                itemBuilder: (context, index) {
                  final post = _myPosts[index];
                  return PostCard(post: post);
                },
              ),
    );
  }
}
