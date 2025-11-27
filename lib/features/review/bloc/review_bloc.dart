import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../model/network/result.dart';
import '../model/review.dart';
import '../repo/review_repo.dart';

// ==================== EVENTS ====================

abstract class ReviewEvent extends Equatable {
  const ReviewEvent();

  @override
  List<Object?> get props => [];
}

class CreateReview extends ReviewEvent {
  final String bookingId;
  final String connectRequestId;
  final String driverId;
  final String customerId;
  final String raterRole;
  final int rating;
  final String? tripId;
  final String? customerRequestId;
  final String? title;
  final String? comment;

  const CreateReview({
    required this.bookingId,
    required this.connectRequestId,
    required this.driverId,
    required this.customerId,
    required this.raterRole,
    required this.rating,
    this.tripId,
    this.customerRequestId,
    this.title,
    this.comment,
  });

  @override
  List<Object?> get props => [
        bookingId,
        connectRequestId,
        driverId,
        customerId,
        raterRole,
        rating,
        tripId,
        customerRequestId,
        title,
        comment,
      ];
}

class UpdateReview extends ReviewEvent {
  final String reviewId;
  final int? rating;
  final String? title;
  final String? comment;

  const UpdateReview({
    required this.reviewId,
    this.rating,
    this.title,
    this.comment,
  });

  @override
  List<Object?> get props => [reviewId, rating, title, comment];
}

class FetchReviewsByBooking extends ReviewEvent {
  final String bookingId;

  const FetchReviewsByBooking({required this.bookingId});

  @override
  List<Object?> get props => [bookingId];
}

class FetchReviewsByUser extends ReviewEvent {
  final String userId;
  final int? page;
  final int? limit;

  const FetchReviewsByUser({
    required this.userId,
    this.page,
    this.limit,
  });

  @override
  List<Object?> get props => [userId, page, limit];
}

class FetchReviewSummary extends ReviewEvent {
  final String userId;

  const FetchReviewSummary({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class FetchReviewById extends ReviewEvent {
  final String reviewId;

  const FetchReviewById({required this.reviewId});

  @override
  List<Object?> get props => [reviewId];
}

// ==================== STATES ====================

abstract class ReviewState extends Equatable {
  const ReviewState();

  @override
  List<Object?> get props => [];
}

class ReviewInitial extends ReviewState {}

class ReviewLoading extends ReviewState {}

class ReviewCreated extends ReviewState {
  final Review review;

  const ReviewCreated({required this.review});

  @override
  List<Object?> get props => [review];
}

class ReviewUpdated extends ReviewState {
  final Review review;

  const ReviewUpdated({required this.review});

  @override
  List<Object?> get props => [review];
}

class ReviewsLoaded extends ReviewState {
  final List<Review> reviews;

  const ReviewsLoaded({required this.reviews});

  @override
  List<Object?> get props => [reviews];
}

class ReviewSummaryLoaded extends ReviewState {
  final ReviewSummary summary;
  final String userId;

  const ReviewSummaryLoaded({
    required this.summary,
    required this.userId,
  });

  @override
  List<Object?> get props => [summary, userId];
}

class ReviewLoaded extends ReviewState {
  final Review review;

  const ReviewLoaded({required this.review});

  @override
  List<Object?> get props => [review];
}

class ReviewError extends ReviewState {
  final String message;
  final List<ValidationError>? fieldErrors;

  const ReviewError({required this.message, this.fieldErrors});

  bool get hasFieldErrors => fieldErrors != null && fieldErrors!.isNotEmpty;

  @override
  List<Object?> get props => [message, fieldErrors];
}

// ==================== BLOC ====================

class ReviewBloc extends Bloc<ReviewEvent, ReviewState> {
  final ReviewRepository repository;

  ReviewBloc({required this.repository}) : super(ReviewInitial()) {
    on<CreateReview>(_onCreateReview);
    on<UpdateReview>(_onUpdateReview);
    on<FetchReviewsByBooking>(_onFetchReviewsByBooking);
    on<FetchReviewsByUser>(_onFetchReviewsByUser);
    on<FetchReviewSummary>(_onFetchReviewSummary);
    on<FetchReviewById>(_onFetchReviewById);
  }

  Future<void> _onCreateReview(
    CreateReview event,
    Emitter<ReviewState> emit,
  ) async {
    emit(ReviewLoading());

    try {
      final result = await repository.createReview(
        bookingId: event.bookingId,
        connectRequestId: event.connectRequestId,
        driverId: event.driverId,
        customerId: event.customerId,
        raterRole: event.raterRole,
        rating: event.rating,
        tripId: event.tripId,
        customerRequestId: event.customerRequestId,
        title: event.title,
        comment: event.comment,
      );

      if (result.isSuccess) {
        emit(ReviewCreated(review: result.data!));
      } else {
        emit(ReviewError(
          message: result.message!,
          fieldErrors: result.errors,
        ));
      }
    } catch (e) {
      emit(ReviewError(message: 'An error occurred: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateReview(
    UpdateReview event,
    Emitter<ReviewState> emit,
  ) async {
    emit(ReviewLoading());

    try {
      final result = await repository.updateReview(
        reviewId: event.reviewId,
        rating: event.rating,
        title: event.title,
        comment: event.comment,
      );

      if (result.isSuccess) {
        emit(ReviewUpdated(review: result.data!));
      } else {
        emit(ReviewError(
          message: result.message!,
          fieldErrors: result.errors,
        ));
      }
    } catch (e) {
      emit(ReviewError(message: 'An error occurred: ${e.toString()}'));
    }
  }

  Future<void> _onFetchReviewsByBooking(
    FetchReviewsByBooking event,
    Emitter<ReviewState> emit,
  ) async {
    emit(ReviewLoading());

    try {
      final result = await repository.getReviewsByBooking(event.bookingId);

      if (result.isSuccess) {
        emit(ReviewsLoaded(reviews: result.data!));
      } else {
        emit(ReviewError(message: result.message!));
      }
    } catch (e) {
      emit(ReviewError(message: 'An error occurred: ${e.toString()}'));
    }
  }

  Future<void> _onFetchReviewsByUser(
    FetchReviewsByUser event,
    Emitter<ReviewState> emit,
  ) async {
    emit(ReviewLoading());

    try {
      final result = await repository.getReviewsByUser(
        event.userId,
        page: event.page,
        limit: event.limit,
      );

      if (result.isSuccess) {
        emit(ReviewsLoaded(reviews: result.data!));
      } else {
        emit(ReviewError(message: result.message!));
      }
    } catch (e) {
      emit(ReviewError(message: 'An error occurred: ${e.toString()}'));
    }
  }

  Future<void> _onFetchReviewSummary(
    FetchReviewSummary event,
    Emitter<ReviewState> emit,
  ) async {
    emit(ReviewLoading());

    try {
      final result = await repository.getReviewSummary(event.userId);

      if (result.isSuccess) {
        emit(ReviewSummaryLoaded(
          summary: result.data!,
          userId: event.userId,
        ));
      } else {
        emit(ReviewError(message: result.message!));
      }
    } catch (e) {
      emit(ReviewError(message: 'An error occurred: ${e.toString()}'));
    }
  }

  Future<void> _onFetchReviewById(
    FetchReviewById event,
    Emitter<ReviewState> emit,
  ) async {
    emit(ReviewLoading());

    try {
      final result = await repository.getReviewById(event.reviewId);

      if (result.isSuccess) {
        emit(ReviewLoaded(review: result.data!));
      } else {
        emit(ReviewError(message: result.message!));
      }
    } catch (e) {
      emit(ReviewError(message: 'An error occurred: ${e.toString()}'));
    }
  }
}

