import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:truck_app/core/constants/app_images.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/loading_skeletons.dart';
import '../../notification/screen/notifications_screen.dart';
import '../../search/screens/search_screen.dart';
import '../model/post.dart';
import '../model/connect.dart';
import '../widgets/post_card.dart';
import '../widgets/recent_connect_card.dart';
import '../widgets/location_filter_dialog.dart';
import '../bloc/posts_bloc.dart';
import '../../post/screens/my_post_screen.dart';
import '../../post/screens/add_post_screen.dart';
import '../../post/bloc/customer_request_bloc.dart';
import '../../connect/bloc/connect_request_bloc.dart';
import '../../connect/model/connect_request.dart';

// Placeholder for a simple ConnectCard for Recent Connects

class HomeScreenUser extends StatefulWidget {
  const HomeScreenUser({super.key});

  @override
  State<HomeScreenUser> createState() => _HomeScreenUserState();
}

class _HomeScreenUserState extends State<HomeScreenUser> {
  // TERMINOLOGY CLARIFICATION FOR CUSTOMERS (USERS):
  // - "_posts" = Other customers' posts (Customer Requests)
  // - "_myPosts" = My own customer requests (what I posted)
  // - "_trips" = Driver trips I can connect to (trips posted by drivers)
  // Data variables - assigned in listeners when success
  List<Post> _posts = [];
  List<Post> _myPosts = [];
  List<Post> _trips = [];
  List<ConnectRequest> _recentConnections = [];
  bool _isLoadingConnections = false;

  // Location filter state
  String? _pickupLocation;
  String? _dropoffLocation;
  String? _currentLocation;
  bool? _pickupDropoffBoth;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  void _loadInitialData() {
    // Fetch all customer requests (posts) when the screen initializes
    context.read<CustomerRequestBloc>().add(
      const FetchAllCustomerRequests(page: 1, limit: 20),
    );
    // Also fetch user's own customer requests (posts)
    context.read<CustomerRequestBloc>().add(
      const FetchMyCustomerRequests(page: 1, limit: 10),
    );
    // Fetch trips for users to see and connect with location filters
    context.read<PostsBloc>().add(
      FetchAllPosts(
        page: 1,
        limit: 20,
        pickupLocation: _pickupLocation,
        dropoffLocation: _dropoffLocation,
        currentLocation: _currentLocation,
        pickupDropoffBoth: _pickupDropoffBoth,
      ),
    );
    // Fetch only received connect requests for recent connects section (requests sent TO the user)
    context.read<ConnectRequestBloc>().add(
      const FetchConnectRequests(type: 'received', page: 1, limit: 5),
    );
  }

  Future<void> _refreshAllData() async {
    _loadInitialData();
    // Wait a bit for data to load
    await Future.delayed(const Duration(seconds: 1));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: BlocConsumer<ConnectRequestBloc, ConnectRequestState>(
        listener: (context, state) {
          if (state is ConnectRequestsLoaded) {
            setState(() {
              _recentConnections = state.requests;
              _isLoadingConnections = false;
            });
          } else if (state is ConnectRequestLoading) {
            setState(() {
              _isLoadingConnections = true;
            });
          } else if (state is ConnectRequestError) {
            setState(() {
              _isLoadingConnections = false;
            });
          }
        },
        builder: (context, connectState) {
          return BlocConsumer<CustomerRequestBloc, CustomerRequestState>(
            listener: (context, state) {
              if (state is CustomerRequestsLoaded) {
                setState(() {
                  _posts = state.requests;
                });
              } else if (state is MyCustomerRequestsLoaded) {
                setState(() {
                  _myPosts = state.requests;
                });
              } else if (state is CustomerRequestError) {
                if (!state.message.toLowerCase().contains('no posts') &&
                    !state.message.toLowerCase().contains('empty')) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            builder: (context, customerRequestState) {
              return BlocConsumer<PostsBloc, PostsState>(
                listener: (context, state) {
                  if (state is PostsLoaded) {
                    setState(() {
                      _trips = state.posts;
                    });
                  }
                },
                builder: (context, postsState) {
                  return RefreshIndicator(
                    onRefresh: _refreshAllData,
                    color: AppColors.secondary,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSearchBox(),
                          const SizedBox(height: 24),
                          _buildRecentConnectsSection(),

                          const SizedBox(height: 24),
                          _buildTripsSection(postsState),
                          const SizedBox(height: 24),
                          _buildMyPostsSection(customerRequestState),
                          // const SizedBox(height: 24),
                          // _buildListOfPostsSection(customerRequestState),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
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
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.white.withOpacity(0.95)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
      ),
      title: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // App Logo with animation
            Hero(
              tag: 'app_logo',
              child: SizedBox(
                height: 35,
                child: Image.asset(AppImages.appIconWithName),
              ),
            ),
            // Notification Icon with badge
            Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.secondary.withOpacity(0.1),
                        AppColors.secondary.withOpacity(0.05),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.secondary.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.notifications_none_rounded,
                      color: AppColors.secondary,
                      size: 26,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const NotificationsScreen(),
                        ),
                      );
                    },
                    style: IconButton.styleFrom(
                      padding: const EdgeInsets.all(12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
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
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withOpacity(0.3),
                          blurRadius: 4,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 8,
                      minHeight: 8,
                    ),
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
                  colors: [
                    AppColors.secondary.withOpacity(0.2),
                    AppColors.secondary.withOpacity(0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.people_rounded,
                color: AppColors.secondary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Recent Connects',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                letterSpacing: -0.5,
              ),
            ),
            const Spacer(),
            if (_recentConnections.isNotEmpty)
              TextButton(
                onPressed: () {
                  // Navigate to all connects
                  Navigator.pushNamed(context, '/connect-requests');
                },
                child: Text(
                  'See All',
                  style: TextStyle(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            const SizedBox(width: 4),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.secondary.withOpacity(0.1),
                    AppColors.secondary.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: IconButton(
                onPressed: () {
                  context.read<ConnectRequestBloc>().add(
                    const FetchConnectRequests(
                      type: 'received',
                      page: 1,
                      limit: 5,
                    ),
                  );
                },
                icon: Icon(
                  Icons.refresh_rounded,
                  color: AppColors.secondary,
                  size: 22,
                ),
                tooltip: 'Refresh',
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 185,
          child:
              _isLoadingConnections
                  ? Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.secondary,
                      ),
                      strokeWidth: 3,
                    ),
                  )
                  : _recentConnections.isEmpty
                  ? Center(
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.border.withOpacity(0.2),
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.people_outline,
                            color: AppColors.textSecondary,
                            size: 32,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'No recent connects yet',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    itemCount: _recentConnections.length,
                    itemBuilder: (context, index) {
                      final connection = _recentConnections[index];
                      // Convert ConnectRequest to Connect for display
                      final connect = _convertConnectRequestToConnect(
                        connection,
                      );
                      return Padding(
                        padding: const EdgeInsets.only(right: 4),
                        child: RecentConnectCard(connect: connect),
                      );
                    },
                  ),
        ),
      ],
    );
  }

  // Helper method to convert ConnectRequest to Connect model for display
  Connect _convertConnectRequestToConnect(ConnectRequest request) {
    // Get the name from populated data or fallback to 'Unknown'
    final String userName =
        request.requester?.name ?? request.recipient?.name ?? 'Unknown';

    // Determine post title from the populated trip or customer request
    String postTitle = request.message ?? '';
    if (request.trip != null) {
      postTitle =
          request.trip!.title ??
          'Trip to ${request.trip!.destination ?? "Unknown"}';
    } else if (request.customerRequest != null) {
      postTitle = request.customerRequest!.details ?? 'Customer Request';
    }

    return Connect(
      id: request.id ?? '',
      postName:
          request.customerRequestId != null
              ? 'Customer Request'
              : 'Trip Request',
      replyUserName: userName,
      postTitle: postTitle,
      dateTime: request.createdAt ?? DateTime.now(),
      status: _mapConnectRequestStatus(request.status),
      isUser: true,
    );
  }

  ConnectStatus _mapConnectRequestStatus(ConnectRequestStatus status) {
    switch (status) {
      case ConnectRequestStatus.accepted:
        return ConnectStatus.accepted;
      case ConnectRequestStatus.rejected:
        return ConnectStatus.rejected;
      case ConnectRequestStatus.cancelled:
        return ConnectStatus.rejected; // Map cancelled to rejected for display
      case ConnectRequestStatus.hold:
        return ConnectStatus.hold;
      case ConnectRequestStatus.pending:
        return ConnectStatus.pending;
    }
  }

  Widget _buildMyPostsSection(CustomerRequestState state) {
    final isLoading = state is CustomerRequestLoading;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.secondary.withOpacity(0.2),
                    AppColors.secondary.withOpacity(0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.description_rounded,
                color: AppColors.secondary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'My Posts',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                letterSpacing: -0.5,
              ),
            ),
            const Spacer(),
            if (_myPosts.isNotEmpty)
              TextButton(
                onPressed: () {
                  // Navigate to My Posts Screen (Customer Requests)
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const MyPostScreen()),
                  );
                },
                child: Text(
                  'See All',
                  style: TextStyle(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            const SizedBox(width: 4),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.secondary.withOpacity(0.1),
                    AppColors.secondary.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: IconButton(
                onPressed: () {
                  context.read<CustomerRequestBloc>().add(
                    const FetchMyCustomerRequests(page: 1, limit: 10),
                  );
                },
                icon: Icon(
                  Icons.refresh_rounded,
                  color: AppColors.secondary,
                  size: 22,
                ),
                tooltip: 'Refresh',
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (isLoading)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(40.0),
              child: Column(
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.secondary,
                    ),
                    strokeWidth: 3,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Loading your posts...',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
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
                gradient: LinearGradient(
                  colors: [
                    AppColors.surface,
                    AppColors.surface.withOpacity(0.5),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.secondary.withOpacity(0.15),
                          AppColors.secondary.withOpacity(0.05),
                        ],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.post_add_rounded,
                      color: AppColors.secondary,
                      size: 56,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'No Posts Yet',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Start by creating your first post',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.secondary,
                          AppColors.secondary.withOpacity(0.85),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.secondary.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Navigate to add post screen (customer request)
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AddPostScreen(),
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.add_circle_outline_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                      label: const Text(
                        'Create Post',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 28,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
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
            height: 470,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              itemCount:
                  _myPosts.length > 5 ? 5 : _myPosts.length, // Show max 5 posts
              itemBuilder: (context, index) {
                return Container(
                  width: 320,
                  margin: const EdgeInsets.only(right: 16),
                  child: PostCard(post: _myPosts[index]),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildTripsSection(PostsState state) {
    final isLoading = state is PostsLoading;
    final hasActiveFilters =
        _pickupLocation != null ||
        _dropoffLocation != null ||
        _currentLocation != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.secondary.withOpacity(0.2),
                    AppColors.secondary.withOpacity(0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.route_rounded,
                color: AppColors.secondary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Available Trips',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                letterSpacing: -0.5,
              ),
            ),
            const Spacer(),
            // Filter button
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.secondary.withOpacity(0.1),
                    AppColors.secondary.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Stack(
                children: [
                  IconButton(
                    onPressed: () async {
                      final result = await showDialog<Map<String, dynamic>>(
                        context: context,
                        builder:
                            (context) => LocationFilterDialog(
                              currentPickupLocation: _pickupLocation,
                              currentDropoffLocation: _dropoffLocation,
                              currentPickupDropoffBoth: _pickupDropoffBoth,
                            ),
                      );

                      if (result != null) {
                        setState(() {
                          _pickupLocation = result['pickupLocation'];
                          _dropoffLocation = result['dropoffLocation'];
                          _currentLocation = result['currentLocation'];
                          _pickupDropoffBoth = result['pickupDropoffBoth'];
                        });
                        // Reload trips with new filters
                        context.read<PostsBloc>().add(
                          FetchAllPosts(
                            page: 1,
                            limit: 20,
                            pickupLocation: _pickupLocation,
                            dropoffLocation: _dropoffLocation,
                            currentLocation: _currentLocation,
                            pickupDropoffBoth: _pickupDropoffBoth,
                          ),
                        );
                      }
                    },
                    icon: Icon(
                      Icons.filter_list_rounded,
                      color: AppColors.secondary,
                      size: 22,
                    ),
                    tooltip: 'Filter by location',
                  ),
                  if (hasActiveFilters)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppColors.secondary,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 8,
                          minHeight: 8,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 4),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.secondary.withOpacity(0.1),
                    AppColors.secondary.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: IconButton(
                onPressed: () {
                  context.read<PostsBloc>().add(
                    FetchAllPosts(
                      page: 1,
                      limit: 20,
                      pickupLocation: _pickupLocation,
                      dropoffLocation: _dropoffLocation,
                      currentLocation: _currentLocation,
                      pickupDropoffBoth: _pickupDropoffBoth,
                    ),
                  );
                },
                icon: Icon(
                  Icons.refresh_rounded,
                  color: AppColors.secondary,
                  size: 22,
                ),
                tooltip: 'Refresh',
              ),
            ),
          ],
        ),
        // Show active filters
        if (hasActiveFilters) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (_currentLocation != null)
                _buildFilterChip(
                  label: 'Current Location',
                  onRemove: () {
                    setState(() {
                      _currentLocation = null;
                    });
                    context.read<PostsBloc>().add(
                      FetchAllPosts(
                        page: 1,
                        limit: 20,
                        pickupLocation: _pickupLocation,
                        dropoffLocation: _dropoffLocation,
                        currentLocation: null,
                        pickupDropoffBoth: _pickupDropoffBoth,
                      ),
                    );
                  },
                ),
              if (_pickupLocation != null)
                _buildFilterChip(
                  label: 'Pickup',
                  onRemove: () {
                    setState(() {
                      _pickupLocation = null;
                      if (_pickupDropoffBoth == true) {
                        _pickupDropoffBoth = null;
                      }
                    });
                    context.read<PostsBloc>().add(
                      FetchAllPosts(
                        page: 1,
                        limit: 20,
                        pickupLocation: null,
                        dropoffLocation: _dropoffLocation,
                        currentLocation: _currentLocation,
                        pickupDropoffBoth: null,
                      ),
                    );
                  },
                ),
              if (_dropoffLocation != null)
                _buildFilterChip(
                  label: 'Dropoff',
                  onRemove: () {
                    setState(() {
                      _dropoffLocation = null;
                      if (_pickupDropoffBoth == true) {
                        _pickupDropoffBoth = null;
                      }
                    });
                    context.read<PostsBloc>().add(
                      FetchAllPosts(
                        page: 1,
                        limit: 20,
                        pickupLocation: _pickupLocation,
                        dropoffLocation: null,
                        currentLocation: _currentLocation,
                        pickupDropoffBoth: null,
                      ),
                    );
                  },
                ),
              if (_pickupDropoffBoth == true)
                _buildFilterChip(
                  label: 'Both Required',
                  onRemove: () {
                    setState(() {
                      _pickupDropoffBoth = null;
                    });
                    context.read<PostsBloc>().add(
                      FetchAllPosts(
                        page: 1,
                        limit: 20,
                        pickupLocation: _pickupLocation,
                        dropoffLocation: _dropoffLocation,
                        currentLocation: _currentLocation,
                        pickupDropoffBoth: null,
                      ),
                    );
                  },
                ),
            ],
          ),
        ],
        const SizedBox(height: 16),
        if (isLoading)
          ListSkeleton(itemCount: 3, itemBuilder: () => PostCardSkeleton())
        else if (_trips.isEmpty)
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 20),
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.surface,
                    AppColors.surface.withOpacity(0.5),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.secondary.withOpacity(0.15),
                          AppColors.secondary.withOpacity(0.05),
                        ],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.route_outlined,
                      color: AppColors.secondary,
                      size: 56,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'No Trips Available',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Check back later for new trips',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _trips.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: AnimatedOpacity(
                  opacity: 1.0,
                  duration: Duration(milliseconds: 300 + (index * 50)),
                  child: PostCard(post: _trips[index]),
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildListOfPostsSection(CustomerRequestState state) {
    final isLoading = state is CustomerRequestLoading;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.secondary.withOpacity(0.2),
                    AppColors.secondary.withOpacity(0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.local_shipping_rounded,
                color: AppColors.secondary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Available Posts',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                letterSpacing: -0.5,
              ),
            ),
            const Spacer(),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.secondary.withOpacity(0.1),
                    AppColors.secondary.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: IconButton(
                onPressed: () {
                  context.read<CustomerRequestBloc>().add(
                    const FetchAllCustomerRequests(page: 1, limit: 20),
                  );
                },
                icon: Icon(
                  Icons.refresh_rounded,
                  color: AppColors.secondary,
                  size: 22,
                ),
                tooltip: 'Refresh',
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (isLoading)
          ListSkeleton(itemCount: 3, itemBuilder: () => PostCardSkeleton())
        else if (state is CustomerRequestError)
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 20),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.red.withOpacity(0.2)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.error_outline_rounded,
                      color: Colors.red,
                      size: 48,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Oops! Something went wrong',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.message,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () {
                      context.read<CustomerRequestBloc>().add(
                        const FetchAllCustomerRequests(page: 1, limit: 20),
                      );
                    },
                    icon: const Icon(
                      Icons.refresh_rounded,
                      color: Colors.white,
                    ),
                    label: const Text(
                      'Try Again',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
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
                gradient: LinearGradient(
                  colors: [
                    AppColors.surface,
                    AppColors.surface.withOpacity(0.5),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.secondary.withOpacity(0.15),
                          AppColors.secondary.withOpacity(0.05),
                        ],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.inbox_outlined,
                      color: AppColors.secondary,
                      size: 56,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'No Trips Available',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Check back later for new opportunities',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      context.read<CustomerRequestBloc>().add(
                        const FetchAllCustomerRequests(page: 1, limit: 20),
                      );
                    },
                    icon: const Icon(
                      Icons.refresh_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                    label: const Text(
                      'Refresh',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 28,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
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
                child: AnimatedOpacity(
                  opacity: 1.0,
                  duration: Duration(milliseconds: 300 + (index * 50)),
                  child: PostCard(post: _posts[index]),
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildFilterChip({
    required String label,
    required VoidCallback onRemove,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.secondary.withOpacity(0.15),
            AppColors.secondary.withOpacity(0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.secondary.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              color: AppColors.secondary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: onRemove,
            child: Icon(
              Icons.close_rounded,
              size: 16,
              color: AppColors.secondary,
            ),
          ),
        ],
      ),
    );
  }

  // Search Box Widget
  Widget _buildSearchBox() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SearchScreen()),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, AppColors.surface.withOpacity(0.8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.secondary.withOpacity(0.06),
              blurRadius: 16,
              offset: const Offset(0, 6),
              spreadRadius: -2,
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(
            color: AppColors.secondary.withOpacity(0.08),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.secondary.withOpacity(0.15),
                    AppColors.secondary.withOpacity(0.08),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.search_rounded,
                color: AppColors.secondary,
                size: 22,
              ),
            ),
            Expanded(
              child: Text(
                'Search trips, locations, or goods...',
                style: TextStyle(
                  color: AppColors.textHint,
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
