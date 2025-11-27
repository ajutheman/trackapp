import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/loading_skeletons.dart';
import '../../../core/utils/error_display.dart';
import '../bloc/review_bloc.dart';
import '../model/review.dart';
import '../widgets/review_card.dart';
import '../widgets/review_summary_widget.dart';

class ReviewsListScreen extends StatefulWidget {
  final String userId;
  final bool showSummary;

  const ReviewsListScreen({
    super.key,
    required this.userId,
    this.showSummary = true,
  });

  @override
  State<ReviewsListScreen> createState() => _ReviewsListScreenState();
}

class _ReviewsListScreenState extends State<ReviewsListScreen> {
  List<Review> _reviews = [];
  ReviewSummary? _summary;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.showSummary) {
      context.read<ReviewBloc>().add(FetchReviewSummary(userId: widget.userId));
    }
    context.read<ReviewBloc>().add(FetchReviewsByUser(userId: widget.userId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Reviews',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
      ),
      body: BlocListener<ReviewBloc, ReviewState>(
        listener: (context, state) {
          if (state is ReviewsLoaded) {
            setState(() {
              _reviews = state.reviews;
              _isLoading = false;
            });
          } else if (state is ReviewSummaryLoaded) {
            setState(() {
              _summary = state.summary;
            });
          } else if (state is ReviewLoading) {
            setState(() {
              _isLoading = true;
            });
          } else if (state is ReviewError) {
            setState(() {
              _isLoading = false;
            });
            showErrorSnackBar(context, state.message);
          }
        },
        child: RefreshIndicator(
          onRefresh: () async {
            if (widget.showSummary) {
              context.read<ReviewBloc>().add(FetchReviewSummary(userId: widget.userId));
            }
            context.read<ReviewBloc>().add(FetchReviewsByUser(userId: widget.userId));
            await Future.delayed(const Duration(seconds: 1));
          },
          color: AppColors.secondary,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Summary
                if (widget.showSummary && _summary != null) ...[
                  ReviewSummaryWidget(summary: _summary!),
                  const SizedBox(height: 24),
                ],

                // Reviews List Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'All Reviews',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (_reviews.isNotEmpty)
                      Text(
                        '${_reviews.length} review${_reviews.length != 1 ? 's' : ''}',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),

                // Reviews List
                if (_isLoading && _reviews.isEmpty)
                  ListSkeleton(
                    itemCount: 3,
                    itemBuilder: () => const ReviewCardSkeleton(),
                  )
                else if (_reviews.isEmpty)
                  _buildEmptyState()
                else
                  ..._reviews.map((review) => ReviewCard(review: review)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.textSecondary.withOpacity(0.1),
                  AppColors.textSecondary.withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.star_outline_rounded,
              size: 60,
              color: AppColors.textSecondary.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'No Reviews Yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Reviews will appear here once users start rating',
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

