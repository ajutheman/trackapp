import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/error_display.dart';
import '../bloc/review_bloc.dart';
import '../widgets/rating_stars.dart';

class CreateReviewScreen extends StatefulWidget {
  final String bookingId;
  final String connectRequestId;
  final String driverId;
  final String customerId;
  final String raterRole; // 'driver' or 'customer'
  final String? tripId;
  final String? customerRequestId;

  const CreateReviewScreen({
    super.key,
    required this.bookingId,
    required this.connectRequestId,
    required this.driverId,
    required this.customerId,
    required this.raterRole,
    this.tripId,
    this.customerRequestId,
  });

  @override
  State<CreateReviewScreen> createState() => _CreateReviewScreenState();
}

class _CreateReviewScreenState extends State<CreateReviewScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _commentController = TextEditingController();
  int _selectedRating = 0;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  void _submitReview() {
    if (_selectedRating == 0) {
      showErrorSnackBar(context, 'Please select a rating');
      return;
    }

    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
      });

      context.read<ReviewBloc>().add(
            CreateReview(
              bookingId: widget.bookingId,
              connectRequestId: widget.connectRequestId,
              driverId: widget.driverId,
              customerId: widget.customerId,
              raterRole: widget.raterRole,
              rating: _selectedRating,
              tripId: widget.tripId,
              customerRequestId: widget.customerRequestId,
              title: _titleController.text.trim().isNotEmpty
                  ? _titleController.text.trim()
                  : null,
              comment: _commentController.text.trim().isNotEmpty
                  ? _commentController.text.trim()
                  : null,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Write Review',
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
          if (state is ReviewCreated) {
            showSuccessSnackBar(context, 'Review submitted successfully!');
            Navigator.of(context).pop(true);
          } else if (state is ReviewError) {
            setState(() {
              _isSubmitting = false;
            });
            if (state.hasFieldErrors) {
              showValidationErrorsDialog(context, state.fieldErrors!);
            } else {
              showErrorSnackBar(context, state.message);
            }
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Rating Section
                const Text(
                  'Rating',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: RatingStars(
                    rating: _selectedRating.toDouble(),
                    size: 40,
                    editable: true,
                    onRatingChanged: (rating) {
                      setState(() {
                        _selectedRating = rating;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 32),

                // Title Section
                const Text(
                  'Title (Optional)',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    hintText: 'Give your review a title...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  maxLength: 120,
                ),
                const SizedBox(height: 24),

                // Comment Section
                const Text(
                  'Comment (Optional)',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _commentController,
                  decoration: InputDecoration(
                    hintText: 'Share your experience...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  maxLines: 6,
                  maxLength: 2000,
                  validator: (value) {
                    if (_titleController.text.trim().isEmpty &&
                        (value == null || value.trim().isEmpty)) {
                      return 'Please provide at least a title or comment';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitReview,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            'Submit Review',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

