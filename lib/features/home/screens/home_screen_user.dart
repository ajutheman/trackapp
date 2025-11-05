import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:truck_app/core/constants/app_images.dart';

import '../../../core/constants/dummy_data.dart';
import '../../../core/theme/app_colors.dart';
import '../../notification/screen/notification_screen.dart';
import '../../search/screens/search_screen.dart';
import '../model/post.dart';
import '../widgets/post_card.dart';
import '../widgets/recent_connect_card.dart';
import '../bloc/posts_bloc.dart';
import '../../post/screens/my_posts_screen.dart';
import '../../post/screens/add_post_screen.dart';

// Placeholder for a simple ConnectCard for Recent Connects

class HomeScreenUser extends StatefulWidget {
  const HomeScreenUser({super.key});

  @override
  State<HomeScreenUser> createState() => _HomeScreenUserState();
}

class _HomeScreenUserState extends State<HomeScreenUser> {
  // Posts from API will be managed by BLoC
  List<Post> _posts = [];
  List<Post> _myPosts = [];
  bool _isLoading = false;
  bool _isLoadingMyPosts = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Fetch all posts when the screen initializes
    context.read<PostsBloc>().add(const FetchAllPosts(page: 1, limit: 20));
    // Also fetch user's own posts
    context.read<PostsBloc>().add(const FetchUserPosts(page: 1, limit: 10));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: BlocListener<PostsBloc, PostsState>(
        listenWhen: (previous, current) {
          // Only listen to states that affect this screen's data
          // Don't listen to PostCreated/PostUpdated/PostDeleted as those are handled by other screens
          return current is PostsLoaded || current is UserPostsLoaded || current is PostsLoading || current is PostsError;
        },
        listener: (context, state) {
          // Only handle if screen is still mounted and visible
          final route = ModalRoute.of(context);
          if (!mounted || route == null || !route.isCurrent) {
            return;
          }
          if (state is PostsLoaded) {
            setState(() {
              _posts = state.posts;
              _isLoading = false;
              _errorMessage = null;
            });
          } else if (state is UserPostsLoaded) {
            setState(() {
              _myPosts = state.posts;
              _isLoadingMyPosts = false;
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
            // Only show snackbar for critical errors, not for empty results
            if (!state.message.toLowerCase().contains('no posts') && !state.message.toLowerCase().contains('empty')) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: Colors.red));
            }
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSearchBox(),
              const SizedBox(height: 24),
              _buildRecentConnectsSection(),
              const SizedBox(height: 24),
              _buildMyPostsSection(),
              const SizedBox(height: 24),
              _buildListOfPostsSection(),
            ],
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
      flexibleSpace: Container(
        decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.white, Colors.white.withOpacity(0.95)], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
      ),
      title: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // App Logo with animation
            Hero(tag: 'app_logo', child: SizedBox(height: 35, child: Image.asset(AppImages.appIconWithName))),
            // Notification Icon with badge
            Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.secondary.withOpacity(0.1), AppColors.secondary.withOpacity(0.05)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [BoxShadow(color: AppColors.secondary.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 2))],
                  ),
                  child: IconButton(
                    icon: Icon(Icons.notifications_none_rounded, color: AppColors.secondary, size: 26),
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => NotificationScreen()));
                    },
                    style: IconButton.styleFrom(padding: const EdgeInsets.all(12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  ),
                ),
                // Notification badge
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: Colors.red.withOpacity(0.3), blurRadius: 4, spreadRadius: 1)],
                    ),
                    constraints: const BoxConstraints(minWidth: 8, minHeight: 8),
                  ),
                ),
              ],
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
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.secondary.withOpacity(0.2), AppColors.secondary.withOpacity(0.1)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.people_rounded, color: AppColors.secondary, size: 20),
            ),
            const SizedBox(width: 12),
            Text('Recent Connects', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary, letterSpacing: -0.5)),
            const Spacer(),
            TextButton(
              onPressed: () {
                // Navigate to all connects
              },
              child: Text('See All', style: TextStyle(color: AppColors.secondary, fontWeight: FontWeight.w600, fontSize: 14)),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 185,
          child:
              DummyData.userConnections.isEmpty
                  ? Center(
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border.withOpacity(0.2))),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.people_outline, color: AppColors.textSecondary, size: 32),
                          const SizedBox(height: 8),
                          Text('No recent connects yet', style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                        ],
                      ),
                    ),
                  )
                  : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    itemCount: DummyData.userConnections.length,
                    itemBuilder: (context, index) {
                      return Padding(padding: const EdgeInsets.only(right: 4), child: RecentConnectCard(connect: DummyData.userConnections[index]));
                    },
                  ),
        ),
      ],
    );
  }

  Widget _buildMyPostsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.secondary.withOpacity(0.2), AppColors.secondary.withOpacity(0.1)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.description_rounded, color: AppColors.secondary, size: 20),
            ),
            const SizedBox(width: 12),
            Text('My Posts', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary, letterSpacing: -0.5)),
            const Spacer(),
            if (_myPosts.isNotEmpty)
              TextButton(
                onPressed: () {
                  // Navigate to My Posts Screen
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const MyPostsScreen()));
                },
                child: Text('See All', style: TextStyle(color: AppColors.secondary, fontWeight: FontWeight.w600, fontSize: 14)),
              ),
            const SizedBox(width: 4),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [AppColors.secondary.withOpacity(0.1), AppColors.secondary.withOpacity(0.05)]),
                borderRadius: BorderRadius.circular(10),
              ),
              child: IconButton(
                onPressed: () {
                  context.read<PostsBloc>().add(const FetchUserPosts(page: 1, limit: 10));
                },
                icon: Icon(Icons.refresh_rounded, color: AppColors.secondary, size: 22),
                tooltip: 'Refresh',
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (_isLoadingMyPosts)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(40.0),
              child: Column(
                children: [
                  CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(AppColors.secondary), strokeWidth: 3),
                  const SizedBox(height: 16),
                  Text('Loading your posts...', style: TextStyle(color: AppColors.textSecondary, fontSize: 14, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          )
        else if (_myPosts.isEmpty)
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 20),
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [AppColors.surface, AppColors.surface.withOpacity(0.5)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [AppColors.secondary.withOpacity(0.15), AppColors.secondary.withOpacity(0.05)]),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.post_add_rounded, color: AppColors.secondary, size: 56),
                  ),
                  const SizedBox(height: 20),
                  Text('No Posts Yet', style: TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  Text('Start by creating your first post', style: TextStyle(color: AppColors.textSecondary, fontSize: 14), textAlign: TextAlign.center),
                  const SizedBox(height: 24),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [AppColors.secondary, AppColors.secondary.withOpacity(0.85)]),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [BoxShadow(color: AppColors.secondary.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))],
                    ),
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Navigate to add post screen
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const AddPostScreen()));
                      },
                      icon: const Icon(Icons.add_circle_outline_rounded, color: Colors.white, size: 20),
                      label: const Text('Create Post', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          SizedBox(
            height: 260,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              itemCount: _myPosts.length > 5 ? 5 : _myPosts.length, // Show max 5 posts
              itemBuilder: (context, index) {
                return Container(width: 320, margin: const EdgeInsets.only(right: 16), child: PostCard(post: _myPosts[index]));
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
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.secondary.withOpacity(0.2), AppColors.secondary.withOpacity(0.1)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.local_shipping_rounded, color: AppColors.secondary, size: 20),
            ),
            const SizedBox(width: 12),
            Text('Available Trips', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary, letterSpacing: -0.5)),
            const Spacer(),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [AppColors.secondary.withOpacity(0.1), AppColors.secondary.withOpacity(0.05)]),
                borderRadius: BorderRadius.circular(10),
              ),
              child: IconButton(
                onPressed: () {
                  context.read<PostsBloc>().add(const RefreshPosts());
                },
                icon: Icon(Icons.refresh_rounded, color: AppColors.secondary, size: 22),
                tooltip: 'Refresh',
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (_isLoading)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(40.0),
              child: Column(
                children: [
                  CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(AppColors.secondary), strokeWidth: 3),
                  const SizedBox(height: 16),
                  Text('Loading trips...', style: TextStyle(color: AppColors.textSecondary, fontSize: 14, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          )
        else if (_errorMessage != null)
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 20),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: Colors.red.withOpacity(0.05), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.red.withOpacity(0.2))),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), shape: BoxShape.circle),
                    child: Icon(Icons.error_outline_rounded, color: Colors.red, size: 48),
                  ),
                  const SizedBox(height: 16),
                  Text('Oops! Something went wrong', style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  Text(_errorMessage!, style: TextStyle(color: AppColors.textSecondary, fontSize: 14), textAlign: TextAlign.center),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () {
                      context.read<PostsBloc>().add(const FetchAllPosts(page: 1, limit: 20));
                    },
                    icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                    label: const Text('Try Again', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
            ),
          )
        else if (_posts.isEmpty)
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 20),
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [AppColors.surface, AppColors.surface.withOpacity(0.5)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [AppColors.secondary.withOpacity(0.15), AppColors.secondary.withOpacity(0.05)]),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.inbox_outlined, color: AppColors.secondary, size: 56),
                  ),
                  const SizedBox(height: 20),
                  Text('No Trips Available', style: TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  Text('Check back later for new opportunities', style: TextStyle(color: AppColors.textSecondary, fontSize: 14), textAlign: TextAlign.center),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      context.read<PostsBloc>().add(const FetchAllPosts(page: 1, limit: 20));
                    },
                    icon: const Icon(Icons.refresh_rounded, color: Colors.white, size: 20),
                    label: const Text('Refresh', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 2,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _posts.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: AnimatedOpacity(opacity: 1.0, duration: Duration(milliseconds: 300 + (index * 50)), child: PostCard(post: _posts[index])),
              );
            },
          ),
      ],
    );
  }

  // Search Box Widget
  Widget _buildSearchBox() {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchScreen()));
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [Colors.white, AppColors.surface.withOpacity(0.8)], begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: AppColors.secondary.withOpacity(0.06), blurRadius: 16, offset: const Offset(0, 6), spreadRadius: -2),
            BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 2)),
          ],
          border: Border.all(color: AppColors.secondary.withOpacity(0.08), width: 1),
        ),
        child: Row(
          children: [
            Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.secondary.withOpacity(0.15), AppColors.secondary.withOpacity(0.08)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.search_rounded, color: AppColors.secondary, size: 22),
            ),
            Expanded(child: Text('Search trips, locations, or goods...', style: TextStyle(color: AppColors.textHint, fontSize: 15, fontWeight: FontWeight.w400))),
          ],
        ),
      ),
    );
  }
}
