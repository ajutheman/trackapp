import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../services/local/local_services.dart';
import '../model/post.dart';
import '../../post/screens/trip_detail_screen.dart';
import '../../connect/screens/select_trip_or_request_dialog.dart';

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

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(milliseconds: 150), vsync: this);
    _pulseController = AnimationController(duration: const Duration(milliseconds: 1000), vsync: this);
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));
    _loadUserType();
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

  void _handleConnect() {
    final recipientId = _getRecipientId();
    if (recipientId == null || widget.post.id == null) return;

    if (_isDriver == true) {
      // Driver connecting to customer request - need to select trip
      showDialog(
        context: context,
        builder: (context) => SelectTripDialog(
          customerRequestId: widget.post.id!,
          recipientId: recipientId,
          recipientName: _getRecipientName(),
        ),
      );
    } else if (_isDriver == false) {
      // User connecting to trip - need to select customer request
      showDialog(
        context: context,
        builder: (context) => SelectCustomerRequestDialog(
          tripId: widget.post.id!,
          recipientId: recipientId,
          recipientName: _getRecipientName(),
        ),
      );
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

                          const SizedBox(height: 16),

                          // Action Buttons
                          Row(
                            children: [
                              // Show edit/delete/toggle buttons if callbacks are provided (for my posts screen)
                              if (widget.onEdit != null || widget.onDelete != null || widget.onToggleStatus != null) ...[
                                if (widget.onEdit != null)
                                  Container(
                                    decoration: BoxDecoration(border: Border.all(color: AppColors.secondary.withOpacity(0.3), width: 1.5), borderRadius: BorderRadius.circular(14)),
                                    child: IconButton(
                                      onPressed: widget.onEdit,
                                      icon: Icon(Icons.edit_outlined, color: AppColors.secondary, size: 22),
                                      style: IconButton.styleFrom(padding: const EdgeInsets.all(12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                                    ),
                                  ),
                                if (widget.onEdit != null && (widget.onDelete != null || widget.onToggleStatus != null)) const SizedBox(width: 10),
                                if (widget.onDelete != null)
                                  Container(
                                    decoration: BoxDecoration(border: Border.all(color: Colors.red.withOpacity(0.3), width: 1.5), borderRadius: BorderRadius.circular(14)),
                                    child: IconButton(
                                      onPressed: widget.onDelete,
                                      icon: Icon(Icons.delete_outline_rounded, color: Colors.red, size: 22),
                                      style: IconButton.styleFrom(padding: const EdgeInsets.all(12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                                    ),
                                  ),
                              ] else ...[
                                // Default action buttons for regular posts
                                if (_shouldShowConnectButton())
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
                                if (_shouldShowConnectButton()) const SizedBox(width: 10),
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

}
