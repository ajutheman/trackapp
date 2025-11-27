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
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Fetch review summary when widget is inserted into tree
    // didChangeDependencies is called after the widget is inserted and has access to providers
    if (widget.userId.isNotEmpty && !_hasFetched) {
      _fetchReviewSummary();
    }
  }

  void _fetchReviewSummary() {
    // Prevent duplicate fetches and avoid API calls for empty userId
    if (_hasFetched || widget.userId.isEmpty) return;
    
    // Check if ReviewBloc is available in the context
    try {
      final reviewBloc = context.read<ReviewBloc>();
      setState(() {
        _isLoading = true;
        _hasFetched = true;
      });
      reviewBloc.add(FetchReviewSummary(userId: widget.userId));
    } catch (e) {
      // If bloc is not available, just skip fetching
      // This can happen if the widget is used outside the provider tree
      debugPrint('ReviewBloc not available: $e');
    }
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
          // Only update if this summary is for our user
          if (state.userId == widget.userId) {
            setState(() {
              _reviewSummary = state.summary;
              _isLoading = false;
            });
          }
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

    // CircleAvatar requires onBackgroundImageError to be null if backgroundImage is null
    if (imageUrl == null) {
      return CircleAvatar(
        radius: 24,
        backgroundColor: AppColors.secondary.withOpacity(0.1),
        child: Icon(
          Icons.person_rounded,
          size: 24,
          color: AppColors.secondary,
        ),
      );
    }

    return CircleAvatar(
      radius: 24,
      backgroundColor: AppColors.secondary.withOpacity(0.1),
      backgroundImage: NetworkImage(imageUrl),
      onBackgroundImageError: (exception, stackTrace) {
        // Handle image load errors gracefully - fallback icon will be shown
        // No need to setState as the child widget handles the fallback
      },
      child: Icon(
        Icons.person_rounded,
        size: 24,
        color: AppColors.secondary,
      ),
    );
  }
}

