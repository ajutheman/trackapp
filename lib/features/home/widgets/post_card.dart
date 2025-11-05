import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../model/post.dart';

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

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(milliseconds: 150), vsync: this);
    _pulseController = AnimationController(duration: const Duration(milliseconds: 1000), vsync: this);
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));
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
                                if (widget.onToggleStatus != null)
                                  Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(color: (widget.post.isActive ?? true) ? Colors.green.withOpacity(0.3) : Colors.orange.withOpacity(0.3), width: 1.5),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: IconButton(
                                      onPressed: widget.onToggleStatus,
                                      icon: Icon(
                                        (widget.post.isActive ?? true) ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                        color: (widget.post.isActive ?? true) ? Colors.green : Colors.orange,
                                        size: 22,
                                      ),
                                      style: IconButton.styleFrom(padding: const EdgeInsets.all(12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                                    ),
                                  ),
                                if (widget.onToggleStatus != null && widget.onDelete != null) const SizedBox(width: 10),
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
                                              _showSuccessDialog(context);
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
                                      // Handle view details
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

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 20, offset: const Offset(0, 10))],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Animated success icon
                TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 600),
                  tween: Tween<double>(begin: 0.0, end: 1.0),
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: value,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [AppColors.secondary.withOpacity(0.2), AppColors.secondary.withOpacity(0.1)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [BoxShadow(color: AppColors.secondary.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 5))],
                        ),
                        child: Icon(Icons.check_circle_rounded, color: AppColors.secondary, size: 60),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
                const Text('🎉 Connection Request Sent!', textAlign: TextAlign.center, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                const SizedBox(height: 12),
                Text(
                  'Your connection request has been successfully sent. We\'ll notify you once it\'s accepted.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 15, height: 1.4),
                ),
                const SizedBox(height: 24),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [AppColors.secondary, AppColors.secondary.withOpacity(0.8)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: AppColors.secondary.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))],
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Awesome!', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
