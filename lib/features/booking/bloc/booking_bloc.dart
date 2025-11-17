// lib/features/booking/bloc/booking_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../model/booking.dart';
import '../repo/booking_repo.dart';

// ==================== EVENTS ====================

abstract class BookingEvent extends Equatable {
  const BookingEvent();

  @override
  List<Object?> get props => [];
}

class CreateBooking extends BookingEvent {
  final String tripId;
  final String customerRequestId;
  final String connectRequestId;
  final double? price;
  final DateTime? pickupDate;
  final String? notes;

  const CreateBooking({
    required this.tripId,
    required this.customerRequestId,
    required this.connectRequestId,
    this.price,
    this.pickupDate,
    this.notes,
  });

  @override
  List<Object?> get props => [tripId, customerRequestId, connectRequestId, price, pickupDate, notes];
}

class FetchBookings extends BookingEvent {
  final String? status;
  final String? type;
  final int? page;
  final int? limit;

  const FetchBookings({this.status, this.type, this.page, this.limit});

  @override
  List<Object?> get props => [status, type, page, limit];
}

class FetchBookingById extends BookingEvent {
  final String bookingId;

  const FetchBookingById({required this.bookingId});

  @override
  List<Object?> get props => [bookingId];
}

class AcceptBooking extends BookingEvent {
  final String bookingId;

  const AcceptBooking({required this.bookingId});

  @override
  List<Object?> get props => [bookingId];
}

class RejectBooking extends BookingEvent {
  final String bookingId;

  const RejectBooking({required this.bookingId});

  @override
  List<Object?> get props => [bookingId];
}

class CancelBooking extends BookingEvent {
  final String bookingId;
  final String? cancellationReason;

  const CancelBooking({required this.bookingId, this.cancellationReason});

  @override
  List<Object?> get props => [bookingId, cancellationReason];
}

class GeneratePickupOtp extends BookingEvent {
  final String bookingId;

  const GeneratePickupOtp({required this.bookingId});

  @override
  List<Object?> get props => [bookingId];
}

class GenerateDeliveryOtp extends BookingEvent {
  final String bookingId;

  const GenerateDeliveryOtp({required this.bookingId});

  @override
  List<Object?> get props => [bookingId];
}

class VerifyPickupOtp extends BookingEvent {
  final String bookingId;
  final String code;

  const VerifyPickupOtp({required this.bookingId, required this.code});

  @override
  List<Object?> get props => [bookingId, code];
}

class VerifyDeliveryOtp extends BookingEvent {
  final String bookingId;
  final String code;

  const VerifyDeliveryOtp({required this.bookingId, required this.code});

  @override
  List<Object?> get props => [bookingId, code];
}

class RefreshBookings extends BookingEvent {
  final String? status;

  const RefreshBookings({this.status});

  @override
  List<Object?> get props => [status];
}

// ==================== STATES ====================

abstract class BookingState extends Equatable {
  const BookingState();

  @override
  List<Object?> get props => [];
}

class BookingInitial extends BookingState {}

class BookingLoading extends BookingState {}

class BookingsLoaded extends BookingState {
  final List<Booking> bookings;
  final bool hasMore;
  final int currentPage;

  const BookingsLoaded({
    required this.bookings,
    this.hasMore = false,
    this.currentPage = 1,
  });

  @override
  List<Object?> get props => [bookings, hasMore, currentPage];
}

class BookingDetailLoaded extends BookingState {
  final Booking booking;

  const BookingDetailLoaded({required this.booking});

  @override
  List<Object?> get props => [booking];
}

class BookingCreated extends BookingState {
  final Booking booking;

  const BookingCreated({required this.booking});

  @override
  List<Object?> get props => [booking];
}

class BookingAccepted extends BookingState {
  final Booking booking;

  const BookingAccepted({required this.booking});

  @override
  List<Object?> get props => [booking];
}

class BookingRejected extends BookingState {
  final Booking booking;

  const BookingRejected({required this.booking});

  @override
  List<Object?> get props => [booking];
}

class BookingCancelled extends BookingState {
  final Booking booking;

  const BookingCancelled({required this.booking});

  @override
  List<Object?> get props => [booking];
}

class PickupOtpGenerated extends BookingState {
  final BookingOtp otp;

  const PickupOtpGenerated({required this.otp});

  @override
  List<Object?> get props => [otp];
}

class DeliveryOtpGenerated extends BookingState {
  final BookingOtp otp;

  const DeliveryOtpGenerated({required this.otp});

  @override
  List<Object?> get props => [otp];
}

class PickupOtpVerified extends BookingState {
  final Booking booking;

  const PickupOtpVerified({required this.booking});

  @override
  List<Object?> get props => [booking];
}

class DeliveryOtpVerified extends BookingState {
  final Booking booking;

  const DeliveryOtpVerified({required this.booking});

  @override
  List<Object?> get props => [booking];
}

class BookingError extends BookingState {
  final String message;

  const BookingError({required this.message});

  @override
  List<Object?> get props => [message];
}

// ==================== BLOC ====================

class BookingBloc extends Bloc<BookingEvent, BookingState> {
  final BookingRepository repository;

  BookingBloc({required this.repository}) : super(BookingInitial()) {
    on<CreateBooking>(_onCreateBooking);
    on<FetchBookings>(_onFetchBookings);
    on<FetchBookingById>(_onFetchBookingById);
    on<AcceptBooking>(_onAcceptBooking);
    on<RejectBooking>(_onRejectBooking);
    on<CancelBooking>(_onCancelBooking);
    on<GeneratePickupOtp>(_onGeneratePickupOtp);
    on<GenerateDeliveryOtp>(_onGenerateDeliveryOtp);
    on<VerifyPickupOtp>(_onVerifyPickupOtp);
    on<VerifyDeliveryOtp>(_onVerifyDeliveryOtp);
    on<RefreshBookings>(_onRefreshBookings);
  }

  Future<void> _onCreateBooking(
    CreateBooking event,
    Emitter<BookingState> emit,
  ) async {
    emit(BookingLoading());

    try {
      final result = await repository.createBooking(
        tripId: event.tripId,
        customerRequestId: event.customerRequestId,
        connectRequestId: event.connectRequestId,
        price: event.price,
        pickupDate: event.pickupDate,
        notes: event.notes,
      );

      if (result.isSuccess) {
        emit(BookingCreated(booking: result.data!));
      } else {
        emit(BookingError(message: result.message!));
      }
    } catch (e) {
      emit(BookingError(message: 'An error occurred: ${e.toString()}'));
    }
  }

  Future<void> _onFetchBookings(
    FetchBookings event,
    Emitter<BookingState> emit,
  ) async {
    emit(BookingLoading());

    try {
      final result = await repository.getBookings(
        status: event.status,
        type: event.type,
        page: event.page,
        limit: event.limit,
      );

      if (result.isSuccess) {
        emit(BookingsLoaded(
          bookings: result.data!,
          hasMore: result.data!.length >= (event.limit ?? 10),
          currentPage: event.page ?? 1,
        ));
      } else {
        emit(BookingError(message: result.message!));
      }
    } catch (e) {
      emit(BookingError(message: 'An error occurred: ${e.toString()}'));
    }
  }

  Future<void> _onFetchBookingById(
    FetchBookingById event,
    Emitter<BookingState> emit,
  ) async {
    emit(BookingLoading());

    try {
      final result = await repository.getBookingById(event.bookingId);

      if (result.isSuccess) {
        emit(BookingDetailLoaded(booking: result.data!));
      } else {
        emit(BookingError(message: result.message!));
      }
    } catch (e) {
      emit(BookingError(message: 'An error occurred: ${e.toString()}'));
    }
  }

  Future<void> _onAcceptBooking(
    AcceptBooking event,
    Emitter<BookingState> emit,
  ) async {
    emit(BookingLoading());

    try {
      final result = await repository.acceptBooking(event.bookingId);

      if (result.isSuccess) {
        emit(BookingAccepted(booking: result.data!));
      } else {
        emit(BookingError(message: result.message!));
      }
    } catch (e) {
      emit(BookingError(message: 'An error occurred: ${e.toString()}'));
    }
  }

  Future<void> _onRejectBooking(
    RejectBooking event,
    Emitter<BookingState> emit,
  ) async {
    emit(BookingLoading());

    try {
      final result = await repository.rejectBooking(event.bookingId);

      if (result.isSuccess) {
        emit(BookingRejected(booking: result.data!));
      } else {
        emit(BookingError(message: result.message!));
      }
    } catch (e) {
      emit(BookingError(message: 'An error occurred: ${e.toString()}'));
    }
  }

  Future<void> _onCancelBooking(
    CancelBooking event,
    Emitter<BookingState> emit,
  ) async {
    emit(BookingLoading());

    try {
      final result = await repository.cancelBooking(
        bookingId: event.bookingId,
        cancellationReason: event.cancellationReason,
      );

      if (result.isSuccess) {
        emit(BookingCancelled(booking: result.data!));
      } else {
        emit(BookingError(message: result.message!));
      }
    } catch (e) {
      emit(BookingError(message: 'An error occurred: ${e.toString()}'));
    }
  }

  Future<void> _onGeneratePickupOtp(
    GeneratePickupOtp event,
    Emitter<BookingState> emit,
  ) async {
    emit(BookingLoading());

    try {
      final result = await repository.generatePickupOtp(event.bookingId);

      if (result.isSuccess) {
        emit(PickupOtpGenerated(otp: result.data!));
      } else {
        emit(BookingError(message: result.message!));
      }
    } catch (e) {
      emit(BookingError(message: 'An error occurred: ${e.toString()}'));
    }
  }

  Future<void> _onGenerateDeliveryOtp(
    GenerateDeliveryOtp event,
    Emitter<BookingState> emit,
  ) async {
    emit(BookingLoading());

    try {
      final result = await repository.generateDeliveryOtp(event.bookingId);

      if (result.isSuccess) {
        emit(DeliveryOtpGenerated(otp: result.data!));
      } else {
        emit(BookingError(message: result.message!));
      }
    } catch (e) {
      emit(BookingError(message: 'An error occurred: ${e.toString()}'));
    }
  }

  Future<void> _onVerifyPickupOtp(
    VerifyPickupOtp event,
    Emitter<BookingState> emit,
  ) async {
    emit(BookingLoading());

    try {
      final result = await repository.verifyPickupOtp(
        bookingId: event.bookingId,
        code: event.code,
      );

      if (result.isSuccess) {
        emit(PickupOtpVerified(booking: result.data!));
      } else {
        emit(BookingError(message: result.message!));
      }
    } catch (e) {
      emit(BookingError(message: 'An error occurred: ${e.toString()}'));
    }
  }

  Future<void> _onVerifyDeliveryOtp(
    VerifyDeliveryOtp event,
    Emitter<BookingState> emit,
  ) async {
    emit(BookingLoading());

    try {
      final result = await repository.verifyDeliveryOtp(
        bookingId: event.bookingId,
        code: event.code,
      );

      if (result.isSuccess) {
        emit(DeliveryOtpVerified(booking: result.data!));
      } else {
        emit(BookingError(message: result.message!));
      }
    } catch (e) {
      emit(BookingError(message: 'An error occurred: ${e.toString()}'));
    }
  }

  Future<void> _onRefreshBookings(
    RefreshBookings event,
    Emitter<BookingState> emit,
  ) async {
    try {
      final result = await repository.getBookings(
        status: event.status,
        page: 1,
        limit: 50,
      );

      if (result.isSuccess) {
        emit(BookingsLoaded(
          bookings: result.data!,
          hasMore: false,
          currentPage: 1,
        ));
      } else {
        emit(BookingError(message: result.message!));
      }
    } catch (e) {
      emit(BookingError(message: 'An error occurred: ${e.toString()}'));
    }
  }
}

