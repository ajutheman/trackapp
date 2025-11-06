// lib/features/post/screens/my_trip_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:truck_app/core/theme/app_colors.dart';
import 'package:truck_app/features/home/bloc/posts_bloc.dart';
import 'package:truck_app/features/home/model/post.dart';
import 'package:truck_app/features/home/widgets/post_card.dart';
import 'package:truck_app/features/post/screens/add_trip_screen.dart';

class MyTripScreen extends StatefulWidget {
  const MyTripScreen({super.key});

  @override
  State<MyTripScreen> createState() => _MyTripScreenState();
}

class _MyTripScreenState extends State<MyTripScreen> {
  // Data variable - assigned in listener when success
  List<Post> posts = [];

  @override
  void initState() {
    super.initState();
    // Fetch user posts when screen loads
    context.read<PostsBloc>().add(const FetchUserPosts(page: 1, limit: 20));
  }

  void _editPost(Post post) async {
    // Navigate to AddTripScreen, passing the post to be edited
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
                          if (post.id != null) {
                            context.read<PostsBloc>().add(DeletePost(postId: post.id!));
                            Navigator.of(context).pop();
                          }
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
    if (post.id != null) {
      final newStatus = !(post.isActive ?? true);
      context.read<PostsBloc>().add(TogglePostStatus(postId: post.id!, isActive: newStatus));
    }
  }

  void _navigateToAddTripScreen() async {
    await Navigator.push(context, MaterialPageRoute(builder: (context) => const AddTripScreen()));
    // Refresh the list when returning from AddTripScreen
    // The PostCreated state handler will also refresh, but this ensures refresh happens
    // even if navigation happens before state is emitted
    if (mounted) {
      context.read<PostsBloc>().add(const FetchUserPosts(page: 1, limit: 20));
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
        title: Text('My Trips', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w800, fontSize: 22, letterSpacing: -0.5)),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: AppColors.textPrimary),
            onPressed: () {
              context.read<PostsBloc>().add(const FetchUserPosts(page: 1, limit: 20));
            },
          ),
        ],
      ),
      body: BlocConsumer<PostsBloc, PostsState>(
        listener: (context, state) {
          if (state is UserPostsLoaded) {
            setState(() {
              posts = state.posts;
            });
          } else if (state is PostCreated) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Post created successfully!'), backgroundColor: Colors.green));
            context.read<PostsBloc>().add(const FetchUserPosts(page: 1, limit: 20));
          } else if (state is PostDeleted) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Post deleted successfully'), backgroundColor: Colors.green));
            context.read<PostsBloc>().add(const FetchUserPosts(page: 1, limit: 20));
          } else if (state is PostUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Post "${state.post.title}" is now ${state.post.isActive == true ? 'active' : 'inactive'}'),
                backgroundColor: state.post.isActive == true ? Colors.green : Colors.orange,
              ),
            );
            context.read<PostsBloc>().add(const FetchUserPosts(page: 1, limit: 20));
          } else if (state is PostsError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: Colors.red));
          }
        },
        builder: (context, state) {
          if (state is PostsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is PostsError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red.withOpacity(0.5)),
                  const SizedBox(height: 16),
                  Text(state.message, style: TextStyle(color: AppColors.textSecondary), textAlign: TextAlign.center),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      context.read<PostsBloc>().add(const FetchUserPosts(page: 1, limit: 20));
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (posts.isEmpty) {
            return Center(
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
                        onPressed: _navigateToAddTripScreen,
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
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];
              return PostCard(post: post, onEdit: () => _editPost(post), onDelete: () => _deletePost(post), onToggleStatus: () => _togglePostStatus(post));
            },
          );
        },
      ),
    );
  }
}
