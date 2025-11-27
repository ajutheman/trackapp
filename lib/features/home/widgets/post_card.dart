import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_colors.dart';
import '../../../services/local/local_services.dart';
import '../model/post.dart';
import '../bloc/posts_bloc.dart';
import '../../post/screens/trip_detail_screen.dart';
import '../../post/bloc/customer_request_bloc.dart';
import '../../connect/utils/connect_request_helper.dart';
import '../../connect/bloc/connect_request_bloc.dart';
import '../../connect/model/connect_request.dart';

class PostCard extends StatefulWidget {
  final Post post;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onToggleStatus;

  const PostCard({super.key, required this.post, this.onEdit, this.onDelete, this.onToggleStatus});

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;
  bool? _isDriver;
  bool _isLoadingUserType = true;
  List<ConnectRequest> _sentRequests = [];
  bool _hasCheckedExistingRequest = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(milliseconds: 150), vsync: this);
    _pulseController = AnimationController(duration: const Duration(milliseconds: 1000), vsync: this);
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));
    _loadUserType();
    // Check for existing requests after user type is loaded
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _checkExistingRequest();
      }
    });
  }

  Future<void> _loadUserType() async {
    final isDriver = await LocalService.getIsDriver();
    if (mounted) {
      setState(() {
        _isDriver = isDriver ?? false;
        _isLoadingUserType = false;
      });
    }
  }

  /// Determines if the post is a trip (driver post) or customer request (user post)
  bool _isTrip() {
    // Trip has tripStartLocation and tripAddedBy
    // Customer request has pickupLocationObj and user (not tripAddedBy)
    return widget.post.tripStartLocation != null && widget.post.tripAddedBy != null;
  }

  /// Determines if the current user owns this post
  bool _isOwnPost() {
    // For trips: check if tripAddedBy matches current user
    // For customer requests: check if user matches current user
    // Note: We need to get current user ID, but for now we'll check based on available data
    // This is a simplified check - in production, you'd compare with actual logged-in user ID
    return false; // Will be enhanced when we have access to current user ID
  }

  /// Determines if connect button should be shown
  bool _shouldShowConnectButton() {
    if (_isLoadingUserType || _isOwnPost()) return false;
    
    // Don't show if request already exists
    if (_hasExistingRequest()) return false;
    
    final isTrip = _isTrip();
    
    // Driver sees customer request (post) -> can connect
    if (_isDriver == true && !isTrip) {
      return true;
    }
    
    // User sees trip -> can connect
    if (_isDriver == false && isTrip) {
      return true;
    }
    
    return false;
  }

  /// Gets the recipient ID and name from the post
  String? _getRecipientId() {
    if (_isTrip()) {
      // For trips, recipient is the tripAddedBy (driver)
      return widget.post.tripAddedBy?.id;
    } else {
      // For customer requests, recipient is the user (customer)
      return widget.post.userId;
    }
  }

  String? _getRecipientName() {
    if (_isTrip()) {
      return widget.post.tripAddedBy?.name;
    } else {
      return widget.post.userName;
    }
  }

  void _handleConnect() async {
    final recipientId = _getRecipientId();
    if (recipientId == null || widget.post.id == null) return;

    final recipientName = _getRecipientName() ?? 'user';
    
    if (_isDriver == true) {
      // Driver needs to have a trip - fetch trips first
      _fetchTripsAndShowConfirmation(recipientId, recipientName);
    } else {
      // User connecting to trip - needs customerRequestId, fetch customer requests first
      _fetchCustomerRequestsAndShowConfirmation(recipientId, recipientName);
    }
  }

  void _fetchTripsAndShowConfirmation(String recipientId, String recipientName) {
    // Fetch driver's trips
    context.read<PostsBloc>().add(const FetchUserPosts(page: 1, limit: 10));
    
    // Listen to the bloc to get trips
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => BlocListener<PostsBloc, PostsState>(
        listener: (context, state) {
          if (state is UserPostsLoaded) {
            final trips = state.posts.where((post) => post.tripStartLocation != null).toList();
            Navigator.of(dialogContext).pop(); // Close loading dialog
            
            if (trips.isEmpty) {
              // No trips available
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('You need to create a trip first before connecting.'),
                  backgroundColor: Colors.orange,
                ),
              );
              return;
            }
            
            // Use the first trip
            final selectedTripId = trips.first.id;
            _showConfirmationDialog(recipientId, recipientName, selectedTripId, null);
          } else if (state is PostsError) {
            Navigator.of(dialogContext).pop(); // Close loading dialog
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to load trips: ${state.message}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }

  void _fetchCustomerRequestsAndShowConfirmation(String recipientId, String recipientName) {
    // Fetch user's customer requests
    context.read<CustomerRequestBloc>().add(const FetchMyCustomerRequests(page: 1, limit: 10));
    
    // Listen to the bloc to get customer requests
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => BlocListener<CustomerRequestBloc, CustomerRequestState>(
        listener: (context, state) {
          if (state is MyCustomerRequestsLoaded) {
            final customerRequests = state.requests;
            Navigator.of(dialogContext).pop(); // Close loading dialog
            
            if (customerRequests.isEmpty) {
              // No customer requests available
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('You need to create a post (customer request) first before connecting.'),
                  backgroundColor: Colors.orange,
                ),
              );
              return;
            }
            
            // Use the first customer request
            final selectedCustomerRequestId = customerRequests.first.id;
            _showConfirmationDialog(recipientId, recipientName, null, selectedCustomerRequestId);
          } else if (state is CustomerRequestError) {
            Navigator.of(dialogContext).pop(); // Close loading dialog
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to load your posts: ${state.message}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }

  void _showConfirmationDialog(String recipientId, String recipientName, String? tripId, String? customerRequestId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.secondary.withOpacity(0.2),
                    AppColors.secondary.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.connect_without_contact_rounded, color: AppColors.secondary, size: 24),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Send Connection Request',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to send a connection request to $recipientName?',
          style: const TextStyle(fontSize: 15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.secondary, AppColors.secondary.withOpacity(0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _sendConnectRequest(recipientId, tripId, customerRequestId);
              },
              child: const Text(
                'Confirm',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _sendConnectRequest(String recipientId, String? tripId, String? customerRequestId) {
    if (widget.post.id == null) return;

    // Listen to the response to handle errors
    final bloc = context.read<ConnectRequestBloc>();
    final subscription = bloc.stream.listen((state) {
      if (state is ConnectRequestError) {
        // Handle specific error codes
        if (state.message.contains('already exists') || state.message.contains('409')) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('A connection request already exists for this post.'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 3),
            ),
          );
          // Refresh sent requests to update UI
          _checkExistingRequest();
        } else if (state.message.contains('403') || state.message.contains('You can only respond')) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('You can only respond to requests sent to you.'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 3),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to send request: ${state.message}'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      } else if (state is ConnectRequestSent) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Connection request sent successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
        // Refresh sent requests to update UI
        _checkExistingRequest();
      }
    });

    if (_isDriver == true) {
      // Driver connecting to customer request - send with customerRequestId and tripId
      if (tripId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No trip available. Please create a trip first.'),
            backgroundColor: Colors.red,
          ),
        );
        subscription.cancel();
        return;
      }
      ConnectRequestHelper.sendRequest(
        context: context,
        recipientId: recipientId,
        customerRequestId: widget.post.id!,
        tripId: tripId,
        message: null,
      );
    } else if (_isDriver == false) {
      // User connecting to trip - send with tripId and customerRequestId (both required by server)
      if (customerRequestId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No post available. Please create a post first.'),
            backgroundColor: Colors.red,
          ),
        );
        subscription.cancel();
        return;
      }
      ConnectRequestHelper.sendRequest(
        context: context,
        recipientId: recipientId,
        customerRequestId: customerRequestId,
        tripId: widget.post.id!,
        message: null,
      );
    }

    // Cancel subscription after a delay to avoid memory leaks
    Future.delayed(const Duration(seconds: 5), () {
      subscription.cancel();
    });
  }

  void _checkExistingRequest() {
    if (!_hasCheckedExistingRequest) {
      _hasCheckedExistingRequest = true;
      // Fetch sent requests to check if one exists for this post
      context.read<ConnectRequestBloc>().add(const FetchConnectRequests(type: 'sent', page: 1, limit: 100));
    }
  }

  bool _hasExistingRequest() {
    if (widget.post.id == null) return false;
    
    return _sentRequests.any((request) {
      if (_isDriver == true) {
        // Driver: check if request exists for this customerRequest
        return request.customerRequestId == widget.post.id && request.status != ConnectRequestStatus.rejected && request.status != ConnectRequestStatus.cancelled;
      } else {
        // User: check if request exists for this trip
        return request.tripId == widget.post.id && request.status != ConnectRequestStatus.rejected && request.status != ConnectRequestStatus.cancelled;
      }
    });
  }

  /// Gets the existing request for this post
  ConnectRequest? _getExistingRequest() {
    if (widget.post.id == null) return null;
    
    try {
      return _sentRequests.firstWhere((request) {
        if (_isDriver == true) {
          // Driver: check if request exists for this customerRequest
          return request.customerRequestId == widget.post.id && request.status != ConnectRequestStatus.rejected && request.status != ConnectRequestStatus.cancelled;
        } else {
          // User: check if request exists for this trip
          return request.tripId == widget.post.id && request.status != ConnectRequestStatus.rejected && request.status != ConnectRequestStatus.cancelled;
        }
      });
    } catch (e) {
      return null;
    }
  }

  /// Gets the status text for display
  String _getStatusText(ConnectRequestStatus status) {
    switch (status) {
      case ConnectRequestStatus.pending:
        return 'Pending';
      case ConnectRequestStatus.accepted:
        return 'Accepted';
      case ConnectRequestStatus.hold:
        return 'On Hold';
      case ConnectRequestStatus.rejected:
        return 'Rejected';
      case ConnectRequestStatus.cancelled:
        return 'Cancelled';
    }
  }

  /// Gets the status color for display
  Color _getStatusColor(ConnectRequestStatus status) {
    switch (status) {
      case ConnectRequestStatus.pending:
        return Colors.orange;
      case ConnectRequestStatus.accepted:
        return Colors.green;
      case ConnectRequestStatus.hold:
        return Colors.blue;
      case ConnectRequestStatus.rejected:
        return Colors.red;
      case ConnectRequestStatus.cancelled:
        return Colors.grey;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Listen to ConnectRequestBloc to update sent requests
    return BlocListener<ConnectRequestBloc, ConnectRequestState>(
      listenWhen: (previous, current) {
        // Only listen to ConnectRequestsLoaded states
        return current is ConnectRequestsLoaded;
      },
      listener: (context, state) {
        if (state is ConnectRequestsLoaded) {
          // Update sent requests list when loaded
          setState(() {
            _sentRequests = state.requests;
          });
        }
      },
      child: _buildPostCard(context),
    );
  }

  Widget _buildPostCard(BuildContext context) {
    final String formattedDate = _formatDate(widget.post.tripStartDate ?? widget.post.date);
    final pickupLocation = widget.post.tripStartLocation?.address ?? widget.post.pickupLocation ?? 'Pickup Location';
    final dropLocation = widget.post.tripDestination?.address ?? widget.post.dropLocation ?? 'Drop Location';
    final vehicleInfo = widget.post.vehicleDetails;
    final goodsInfo = widget.post.goodsTypeDetails;

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: (_) {
              _controller.forward();
            },
            onTapUp: (_) {
              _controller.reverse();
              if (widget.post.id != null) {
                Navigator.push(context, MaterialPageRoute(builder: (context) => TripDetailScreen(tripId: widget.post.id!)));
              }
            },
            onTapCancel: () {
              _controller.reverse();
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [Colors.white, AppColors.surface.withOpacity(0.8)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.secondary.withOpacity(0.08), width: 1.5),
                boxShadow: [
                  BoxShadow(color: AppColors.secondary.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, 8), spreadRadius: -4),
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with Route Information
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.secondary.withOpacity(0.08), AppColors.secondary.withOpacity(0.03)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Status Badge and Date
                          Row(
                            children: [
                              if (widget.post.status != null) ...[
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(colors: [Colors.green.shade400, Colors.green.shade600]),
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [BoxShadow(color: Colors.green.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 2))],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.check_circle_rounded, size: 12, color: Colors.white),
                                      const SizedBox(width: 4),
                                      Text(widget.post.status!.name, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white)),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                              ],
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppColors.background.withOpacity(0.8),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: AppColors.border.withOpacity(0.2)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.calendar_today_rounded, size: 11, color: AppColors.textSecondary),
                                    const SizedBox(width: 4),
                                    Text(formattedDate, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                                  ],
                                ),
                              ),
                              const Spacer(),
                              if (widget.post.distance != null)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(colors: [AppColors.secondary.withOpacity(0.15), AppColors.secondary.withOpacity(0.08)]),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.route_rounded, size: 12, color: AppColors.secondary),
                                      const SizedBox(width: 4),
                                      Text(widget.post.distance!.text, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.secondary)),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Route Display (From -> To)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // From Location
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(colors: [Colors.green.shade50, Colors.green.shade100.withOpacity(0.3)]),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: Colors.green.shade200, width: 1.5),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.all(4),
                                                decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.green.shade600, Colors.green.shade700]), shape: BoxShape.circle),
                                                child: const Icon(Icons.my_location_rounded, size: 12, color: Colors.white),
                                              ),
                                              const SizedBox(width: 6),
                                              Text('FROM', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: Colors.green.shade700, letterSpacing: 0.8)),
                                            ],
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            pickupLocation,
                                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary, height: 1.2),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Arrow
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(colors: [AppColors.secondary.withOpacity(0.2), AppColors.secondary.withOpacity(0.1)]),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(Icons.arrow_forward_rounded, size: 18, color: AppColors.secondary),
                                ),
                              ),

                              // To Location
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(colors: [Colors.red.shade50, Colors.red.shade100.withOpacity(0.3)]),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: Colors.red.shade200, width: 1.5),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.all(4),
                                                decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.red.shade600, Colors.red.shade700]), shape: BoxShape.circle),
                                                child: const Icon(Icons.location_on_rounded, size: 12, color: Colors.white),
                                              ),
                                              const SizedBox(width: 6),
                                              Text('TO', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: Colors.red.shade700, letterSpacing: 0.8)),
                                            ],
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            dropLocation,
                                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary, height: 1.2),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Trip Details Section
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Vehicle and Goods Info
                          Row(
                            children: [
                              if (vehicleInfo != null)
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: AppColors.background.withOpacity(0.5),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: AppColors.border.withOpacity(0.2)),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(Icons.local_shipping_rounded, size: 14, color: AppColors.secondary),
                                            const SizedBox(width: 6),
                                            Text('VEHICLE', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: AppColors.textSecondary, letterSpacing: 0.8)),
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          vehicleInfo.vehicleNumber,
                                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        // if (vehicleInfo.vehicleNumber.isNotEmpty)
                                        //   Text(
                                        //     vehicleInfo.vehicleNumber,
                                        //     style: TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                                        //     maxLines: 1,
                                        //     overflow: TextOverflow.ellipsis,
                                        //   ),
                                      ],
                                    ),
                                  ),
                                ),
                              if (vehicleInfo != null && goodsInfo != null) const SizedBox(width: 10),
                              if (goodsInfo != null)
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: AppColors.background.withOpacity(0.5),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: AppColors.border.withOpacity(0.2)),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(Icons.inventory_2_rounded, size: 14, color: AppColors.secondary),
                                            const SizedBox(width: 6),
                                            Text('CARGO', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: AppColors.textSecondary, letterSpacing: 0.8)),
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          goodsInfo.name,
                                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        if (widget.post.weight != null)
                                          Text('${widget.post.weight} kg', style: TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          // Duration and Driver Info
                          if (widget.post.duration != null || widget.post.driver != null)
                            Row(
                              children: [
                                if (widget.post.duration != null)
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(colors: [AppColors.secondary.withOpacity(0.08), AppColors.secondary.withOpacity(0.03)]),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(Icons.access_time_rounded, size: 16, color: AppColors.secondary),
                                          const SizedBox(width: 8),
                                          Text(widget.post.duration!.text, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                                        ],
                                      ),
                                    ),
                                  ),
                                if (widget.post.duration != null && widget.post.driver != null) const SizedBox(width: 10),
                                if (widget.post.driver != null)
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(colors: [AppColors.secondary.withOpacity(0.08), AppColors.secondary.withOpacity(0.03)]),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(Icons.person_rounded, size: 16, color: AppColors.secondary),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              widget.post.driver!.name,
                                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                              ],
                            ),

                          // Connect Stats for Customer Requests (Leads) viewed by Drivers
                          if (!_isTrip() && widget.post.connectStats != null && widget.post.connectStats!.total > 0)
                            Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [AppColors.secondary.withOpacity(0.08), AppColors.secondary.withOpacity(0.03)],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppColors.secondary.withOpacity(0.15)),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.people_outline_rounded, size: 16, color: AppColors.secondary),
                                        const SizedBox(width: 6),
                                        Text(
                                          'Connection Activity',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.secondary,
                                            letterSpacing: 0.3,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                      children: [
                                        _buildStatItem(
                                          widget.post.connectStats!.total.toString(),
                                          'Total',
                                          Icons.connect_without_contact_rounded,
                                          AppColors.textPrimary,
                                        ),
                                        _buildStatItem(
                                          widget.post.connectStats!.pending.toString(),
                                          'Pending',
                                          Icons.hourglass_empty_rounded,
                                          Colors.orange,
                                        ),
                                        _buildStatItem(
                                          widget.post.connectStats!.accepted.toString(),
                                          'Accepted',
                                          Icons.check_circle_outline_rounded,
                                          Colors.green,
                                        ),
                                        if (widget.post.connectStats!.rejected > 0)
                                          _buildStatItem(
                                            widget.post.connectStats!.rejected.toString(),
                                            'Rejected',
                                            Icons.cancel_outlined,
                                            Colors.red,
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),

                          const SizedBox(height: 16),

                          // Action Buttons
                          Row(
                            children: [
                              // Show edit/delete/toggle buttons if callbacks are provided (for my posts screen)
                              if (widget.onEdit != null || widget.onDelete != null || widget.onToggleStatus != null) ...[
                                if (widget.onEdit != null)
                                  Expanded(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(color: AppColors.secondary.withOpacity(0.3), width: 1.5),
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: ElevatedButton.icon(
                                        onPressed: widget.onEdit,
                                        icon: Icon(Icons.edit_outlined, color: AppColors.secondary, size: 20),
                                        label: Text(
                                          'Edit',
                                          style: TextStyle(
                                            color: AppColors.secondary,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 15,
                                            letterSpacing: 0.3,
                                          ),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.transparent,
                                          shadowColor: Colors.transparent,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                          padding: const EdgeInsets.symmetric(vertical: 14),
                                        ),
                                      ),
                                    ),
                                  ),
                                if (widget.onEdit != null && widget.onDelete != null) const SizedBox(width: 10),
                                if (widget.onDelete != null)
                                  Expanded(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.red.withOpacity(0.3), width: 1.5),
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: ElevatedButton.icon(
                                        onPressed: widget.onDelete,
                                        icon: Icon(Icons.delete_outline_rounded, color: Colors.red, size: 20),
                                        label: Text(
                                          'Delete',
                                          style: TextStyle(
                                            color: Colors.red,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 15,
                                            letterSpacing: 0.3,
                                          ),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.transparent,
                                          shadowColor: Colors.transparent,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                          padding: const EdgeInsets.symmetric(vertical: 14),
                                        ),
                                      ),
                                    ),
                                  ),
                              ] else ...[
                                // Default action buttons for regular posts
                                // Check if there's an existing request
                                Builder(
                                  builder: (context) {
                                    final existingRequest = _getExistingRequest();
                                    if (existingRequest != null) {
                                      // Show status with full width
                                      final statusColor = _getStatusColor(existingRequest.status);
                                      final statusText = _getStatusText(existingRequest.status);
                                      return Expanded(
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                                          decoration: BoxDecoration(
                                            color: statusColor.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(14),
                                            border: Border.all(
                                              color: statusColor.withOpacity(0.3),
                                              width: 1.5,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.info_outline_rounded,
                                                size: 20,
                                                color: statusColor,
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                'Status: $statusText',
                                                style: TextStyle(
                                                  color: statusColor,
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 15,
                                                  letterSpacing: 0.3,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    } else if (_shouldShowConnectButton()) {
                                      // Show connect button and info button
                                      return Expanded(
                                        child: Row(
                                          children: [
                                            Expanded(
                                              flex: 2,
                                              child: AnimatedBuilder(
                                                animation: _pulseAnimation,
                                                builder: (context, child) {
                                                  return Transform.scale(
                                                    scale: _pulseAnimation.value,
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                        gradient: LinearGradient(colors: [AppColors.secondary, AppColors.secondary.withOpacity(0.85)]),
                                                        borderRadius: BorderRadius.circular(14),
                                                        boxShadow: [BoxShadow(color: AppColors.secondary.withOpacity(0.4), blurRadius: 12, offset: const Offset(0, 4))],
                                                      ),
                                                      child: ElevatedButton.icon(
                                                        onPressed: () {
                                                          _pulseController.forward().then((_) => _pulseController.reverse());
                                                          _handleConnect();
                                                        },
                                                        icon: const Icon(Icons.connect_without_contact_rounded, size: 20, color: Colors.white),
                                                        label: const Text('Connect Now', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15, letterSpacing: 0.3)),
                                                        style: ElevatedButton.styleFrom(
                                                          backgroundColor: Colors.transparent,
                                                          shadowColor: Colors.transparent,
                                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                                          padding: const EdgeInsets.symmetric(vertical: 14),
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            Container(
                                              decoration: BoxDecoration(border: Border.all(color: AppColors.secondary.withOpacity(0.3), width: 1.5), borderRadius: BorderRadius.circular(14)),
                                              child: IconButton(
                                                onPressed: () {
                                                  if (widget.post.id != null) {
                                                    Navigator.push(context, MaterialPageRoute(builder: (context) => TripDetailScreen(tripId: widget.post.id!)));
                                                  }
                                                },
                                                icon: Icon(Icons.info_outline_rounded, color: AppColors.secondary, size: 22),
                                                style: IconButton.styleFrom(padding: const EdgeInsets.all(12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    } else {
                                      // Show info button with full width and text
                                      return Expanded(
                                        child: Container(
                                          decoration: BoxDecoration(
                                            border: Border.all(color: AppColors.secondary.withOpacity(0.3), width: 1.5),
                                            borderRadius: BorderRadius.circular(14),
                                          ),
                                          child: ElevatedButton.icon(
                                            onPressed: () {
                                              if (widget.post.id != null) {
                                                Navigator.push(context, MaterialPageRoute(builder: (context) => TripDetailScreen(tripId: widget.post.id!)));
                                              }
                                            },
                                            icon: Icon(Icons.info_outline_rounded, color: AppColors.secondary, size: 20),
                                            label: const Text(
                                              'View Details',
                                              style: TextStyle(
                                                color: AppColors.secondary,
                                                fontWeight: FontWeight.w700,
                                                fontSize: 15,
                                                letterSpacing: 0.3,
                                              ),
                                            ),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.transparent,
                                              shadowColor: Colors.transparent,
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                              padding: const EdgeInsets.symmetric(vertical: 14),
                                            ),
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${date.day} ${months[date.month - 1]}, ${date.year}';
  }

  /// Build a stat item for connectStats display
  Widget _buildStatItem(String value, String label, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 14, color: color),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

}
