import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/theme/app_colors.dart';
import '../../review/bloc/review_bloc.dart';
import '../../review/model/review.dart';
import '../../review/widgets/rating_stars.dart';

class ProfileSummaryWidget extends StatefulWidget {
  final String userId;
  final String userName;
  final String? profilePictureUrl;
  final String userRole; // 'driver' or 'customer'
  final VoidCallback? onTap;

  const ProfileSummaryWidget({
    super.key,
    required this.userId,
    required this.userName,
    this.profilePictureUrl,
    required this.userRole,
    this.onTap,
  });

  @override
  State<ProfileSummaryWidget> createState() => _ProfileSummaryWidgetState();
}

class _ProfileSummaryWidgetState extends State<ProfileSummaryWidget> {
  ReviewSummary? _reviewSummary;
  bool _isLoading = false;
  bool _hasFetched = false;

  @override
  void initState() {
    super.initState();
    // Fetch review summary when widget is first built
    if (widget.userId.isNotEmpty) {
      _fetchReviewSummary();
    }
  }

  void _fetchReviewSummary() {
    if (_hasFetched) return; // Prevent duplicate fetches
    
    setState(() {
      _isLoading = true;
      _hasFetched = true;
    });

    context.read<ReviewBloc>().add(FetchReviewSummary(userId: widget.userId));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ReviewBloc, ReviewState>(
      listenWhen: (previous, current) {
        // Only listen to summary loaded states
        return current is ReviewSummaryLoaded || 
               (current is ReviewError && previous is ReviewLoading);
      },
      listener: (context, state) {
        if (state is ReviewSummaryLoaded) {
          // Update review summary when loaded
          // Note: In a production app, you might want to track which user ID
          // the summary is for to avoid updating with wrong user's data
          setState(() {
            _reviewSummary = state.summary;
            _isLoading = false;
          });
        } else if (state is ReviewError) {
          setState(() {
            _isLoading = false;
          });
        }
      },
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.border.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              // Avatar
              _buildAvatar(),
              const SizedBox(width: 12),
              // Name and Rating
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.userName,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    if (_isLoading)
                      SizedBox(
                        width: 80,
                        height: 14,
                        child: LinearProgressIndicator(
                          backgroundColor: AppColors.border.withOpacity(0.2),
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.secondary),
                          minHeight: 2,
                        ),
                      )
                    else if (_reviewSummary != null && _reviewSummary!.totalReviews > 0)
                      Row(
                        children: [
                          RatingStars(
                            rating: _reviewSummary!.averageRating,
                            size: 14,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${_reviewSummary!.averageRating.toStringAsFixed(1)} (${_reviewSummary!.totalReviews})',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      )
                    else
                      Text(
                        'No reviews yet',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                  ],
                ),
              ),
              // Arrow icon if clickable
              if (widget.onTap != null)
                Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    String? imageUrl = widget.profilePictureUrl;
    
    // Construct full URL if relative path
    if (imageUrl != null && !imageUrl.startsWith('http')) {
      String baseUrl = ApiEndpoints.baseUrl.replaceAll('/api/v1/', '');
      if (baseUrl.endsWith('/')) {
        baseUrl = baseUrl.substring(0, baseUrl.length - 1);
      }
      if (imageUrl.startsWith('/')) {
        imageUrl = imageUrl.substring(1);
      }
      imageUrl = '$baseUrl/$imageUrl';
    }

    return CircleAvatar(
      radius: 24,
      backgroundColor: AppColors.secondary.withOpacity(0.1),
      backgroundImage: imageUrl != null ? NetworkImage(imageUrl) : null,
      child: imageUrl == null
          ? Icon(
              Icons.person_rounded,
              size: 24,
              color: AppColors.secondary,
            )
          : null,
    );
  }
}

