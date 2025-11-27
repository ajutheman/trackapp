import '../../../core/constants/api_endpoints.dart';
import '../../../model/network/result.dart';
import '../../../services/network/api_service.dart';
import '../model/review.dart';

class ReviewRepository {
  final ApiService apiService;

  ReviewRepository({required this.apiService});

  /// Create a new review
  Future<Result<Review>> createReview({
    required String bookingId,
    required String connectRequestId,
    required String driverId,
    required String customerId,
    required String raterRole,
    required int rating,
    String? tripId,
    String? customerRequestId,
    String? title,
    String? comment,
  }) async {
    final body = <String, dynamic>{
      'bookingId': bookingId,
      'connectRequestId': connectRequestId,
      'driverId': driverId,
      'customerId': customerId,
      'raterRole': raterRole,
      'rating': rating,
      if (tripId != null) 'tripId': tripId,
      if (customerRequestId != null) 'customerRequestId': customerRequestId,
      if (title != null && title.isNotEmpty) 'title': title,
      if (comment != null && comment.isNotEmpty) 'comment': comment,
    };

    final result = await apiService.post(
      ApiEndpoints.createReview,
      body: body,
      isTokenRequired: true,
    );

    if (result.isSuccess) {
      try {
        final reviewData = result.data is Map
            ? result.data
            : (result.data['review'] ?? result.data);
        final Review review = Review.fromJson(reviewData as Map<String, dynamic>);
        return Result.success(review);
      } catch (e) {
        return Result.error('Failed to parse created review: ${e.toString()}');
      }
    } else {
      return Result.error(
        result.message ?? 'Failed to create review',
      );
    }
  }

  /// Update an existing review
  Future<Result<Review>> updateReview({
    required String reviewId,
    int? rating,
    String? title,
    String? comment,
  }) async {
    final body = <String, dynamic>{};
    if (rating != null) body['rating'] = rating;
    if (title != null) body['title'] = title;
    if (comment != null) body['comment'] = comment;

    final result = await apiService.put(
      '${ApiEndpoints.updateReview}/$reviewId',
      body: body,
      isTokenRequired: true,
    );

    if (result.isSuccess) {
      try {
        final reviewData = result.data is Map
            ? result.data
            : (result.data['review'] ?? result.data);
        final Review review = Review.fromJson(reviewData as Map<String, dynamic>);
        return Result.success(review);
      } catch (e) {
        return Result.error('Failed to parse updated review: ${e.toString()}');
      }
    } else {
      return Result.error(
        result.message ?? 'Failed to update review',
      );
    }
  }

  /// Get reviews for a booking
  Future<Result<List<Review>>> getReviewsByBooking(String bookingId) async {
    final result = await apiService.get(
      '${ApiEndpoints.getReviewsByBooking}/$bookingId',
      isTokenRequired: true,
    );

    if (result.isSuccess) {
      try {
        final List<dynamic> reviewsData = result.data is List
            ? result.data
            : (result.data['reviews'] ?? result.data['data'] ?? []);
        final List<Review> reviews = reviewsData
            .map((reviewJson) => Review.fromJson(reviewJson as Map<String, dynamic>))
            .toList();
        return Result.success(reviews);
      } catch (e) {
        return Result.error('Failed to parse reviews: ${e.toString()}');
      }
    } else {
      return Result.error(result.message ?? 'Failed to fetch reviews');
    }
  }

  /// Get reviews for a user
  Future<Result<List<Review>>> getReviewsByUser(String userId, {int? page, int? limit}) async {
    final queryParams = <String, dynamic>{};
    if (page != null) queryParams['page'] = page;
    if (limit != null) queryParams['limit'] = limit;

    final result = await apiService.get(
      '${ApiEndpoints.getReviewsByUser}/$userId',
      queryParams: queryParams.isNotEmpty ? queryParams : null,
      isTokenRequired: true,
    );

    if (result.isSuccess) {
      try {
        final List<dynamic> reviewsData = result.data is List
            ? result.data
            : (result.data['reviews'] ?? result.data['data'] ?? []);
        final List<Review> reviews = reviewsData
            .map((reviewJson) => Review.fromJson(reviewJson as Map<String, dynamic>))
            .toList();
        return Result.success(reviews);
      } catch (e) {
        return Result.error('Failed to parse reviews: ${e.toString()}');
      }
    } else {
      return Result.error(result.message ?? 'Failed to fetch reviews');
    }
  }

  /// Get review summary for a user
  Future<Result<ReviewSummary>> getReviewSummary(String userId) async {
    final result = await apiService.get(
      '${ApiEndpoints.getReviewSummary}/$userId',
      isTokenRequired: true,
    );

    if (result.isSuccess) {
      try {
        final summaryData = result.data is Map
            ? result.data
            : (result.data['summary'] ?? result.data);
        final ReviewSummary summary = ReviewSummary.fromJson(summaryData as Map<String, dynamic>);
        return Result.success(summary);
      } catch (e) {
        return Result.error('Failed to parse review summary: ${e.toString()}');
      }
    } else {
      return Result.error(result.message ?? 'Failed to fetch review summary');
    }
  }

  /// Get a review by ID
  Future<Result<Review>> getReviewById(String reviewId) async {
    final result = await apiService.get(
      '${ApiEndpoints.getReviewById}/$reviewId',
      isTokenRequired: true,
    );

    if (result.isSuccess) {
      try {
        final reviewData = result.data is Map
            ? result.data
            : (result.data['review'] ?? result.data);
        final Review review = Review.fromJson(reviewData as Map<String, dynamic>);
        return Result.success(review);
      } catch (e) {
        return Result.error('Failed to parse review: ${e.toString()}');
      }
    } else {
      return Result.error(result.message ?? 'Failed to fetch review');
    }
  }
}

