// lib/features/booking/repo/booking_repo.dart

import '../../../core/constants/api_endpoints.dart';
import '../../../model/network/result.dart';
import '../../../services/network/api_service.dart';
import '../model/booking.dart';

class BookingRepository {
  final ApiService apiService;

  BookingRepository({required this.apiService});

  /// Create a new booking
  Future<Result<Booking>> createBooking({
    required String tripId,
    required String customerRequestId,
    required String connectRequestId,
    double? price,
    DateTime? pickupDate,
    String? notes,
  }) async {
    final body = <String, dynamic>{
      'tripId': tripId,
      'customerRequestId': customerRequestId,
      'connectRequestId': connectRequestId,
      if (price != null) 'price': price,
      if (pickupDate != null) 'pickupDate': pickupDate.toIso8601String(),
      if (notes != null) 'notes': notes,
    };

    final result = await apiService.post(
      ApiEndpoints.bookings,
      body: body,
      isTokenRequired: true,
    );

    if (result.isSuccess) {
      try {
        final bookingData = result.data is Map<String, dynamic>
            ? result.data as Map<String, dynamic>
            : <String, dynamic>{};
        final booking = bookingData['booking'] ?? bookingData;
        final bookingMap = booking is Map<String, dynamic>
            ? booking
            : Map<String, dynamic>.from(booking);
        return Result.success(Booking.fromJson(bookingMap));
      } catch (e) {
        return Result.error('Failed to parse booking: ${e.toString()}');
      }
    } else {
      return Result.error(result.message ?? 'Failed to create booking');
    }
  }

  /// Get all bookings
  Future<Result<List<Booking>>> getBookings({
    String? status,
    String? type, // 'driver' or 'customer'
    int? page,
    int? limit,
  }) async {
    final queryParams = <String, dynamic>{};
    if (status != null) queryParams['status'] = status;
    if (type != null) queryParams['type'] = type;
    if (page != null) queryParams['page'] = page;
    if (limit != null) queryParams['limit'] = limit;

    final result = await apiService.get(
      ApiEndpoints.bookings,
      queryParams: queryParams.isNotEmpty ? queryParams : null,
      isTokenRequired: true,
    );

    if (result.isSuccess) {
      try {
        final List<dynamic> bookingsData = result.data is List
            ? result.data
            : (result.data['bookings'] ?? result.data['data'] ?? []);
        final List<Booking> bookings = bookingsData
            .map((bookingJson) => Booking.fromJson(bookingJson as Map<String, dynamic>))
            .toList();
        return Result.success(bookings);
      } catch (e) {
        return Result.error('Failed to parse bookings: ${e.toString()}');
      }
    } else {
      return Result.error(result.message ?? 'Failed to fetch bookings');
    }
  }

  /// Get booking by ID
  Future<Result<Booking>> getBookingById(String bookingId) async {
    final result = await apiService.get(
      '${ApiEndpoints.bookings}/$bookingId',
      isTokenRequired: true,
    );

    if (result.isSuccess) {
      try {
        final bookingData = result.data is Map<String, dynamic>
            ? result.data as Map<String, dynamic>
            : <String, dynamic>{};
        final booking = bookingData['booking'] ?? bookingData;
        final bookingMap = booking is Map<String, dynamic>
            ? booking
            : Map<String, dynamic>.from(booking);
        return Result.success(Booking.fromJson(bookingMap));
      } catch (e) {
        return Result.error('Failed to parse booking: ${e.toString()}');
      }
    } else {
      return Result.error(result.message ?? 'Failed to fetch booking');
    }
  }

  /// Accept booking
  Future<Result<Booking>> acceptBooking(String bookingId) async {
    final result = await apiService.put(
      '${ApiEndpoints.bookings}/$bookingId/accept',
      isTokenRequired: true,
    );

    if (result.isSuccess) {
      try {
        final bookingData = result.data is Map<String, dynamic>
            ? result.data as Map<String, dynamic>
            : <String, dynamic>{};
        final booking = bookingData['booking'] ?? bookingData;
        final bookingMap = booking is Map<String, dynamic>
            ? booking
            : Map<String, dynamic>.from(booking);
        return Result.success(Booking.fromJson(bookingMap));
      } catch (e) {
        return Result.error('Failed to parse booking: ${e.toString()}');
      }
    } else {
      return Result.error(result.message ?? 'Failed to accept booking');
    }
  }

  /// Reject booking
  Future<Result<Booking>> rejectBooking(String bookingId) async {
    final result = await apiService.put(
      '${ApiEndpoints.bookings}/$bookingId/reject',
      isTokenRequired: true,
    );

    if (result.isSuccess) {
      try {
        final bookingData = result.data is Map<String, dynamic>
            ? result.data as Map<String, dynamic>
            : <String, dynamic>{};
        final booking = bookingData['booking'] ?? bookingData;
        final bookingMap = booking is Map<String, dynamic>
            ? booking
            : Map<String, dynamic>.from(booking);
        return Result.success(Booking.fromJson(bookingMap));
      } catch (e) {
        return Result.error('Failed to parse booking: ${e.toString()}');
      }
    } else {
      return Result.error(result.message ?? 'Failed to reject booking');
    }
  }

  /// Cancel booking
  Future<Result<Booking>> cancelBooking({
    required String bookingId,
    String? cancellationReason,
  }) async {
    final body = <String, dynamic>{};
    if (cancellationReason != null) {
      body['cancellationReason'] = cancellationReason;
    }

    final result = await apiService.put(
      '${ApiEndpoints.bookings}/$bookingId/cancel',
      body: body.isNotEmpty ? body : null,
      isTokenRequired: true,
    );

    if (result.isSuccess) {
      try {
        final bookingData = result.data is Map<String, dynamic>
            ? result.data as Map<String, dynamic>
            : <String, dynamic>{};
        final booking = bookingData['booking'] ?? bookingData;
        final bookingMap = booking is Map<String, dynamic>
            ? booking
            : Map<String, dynamic>.from(booking);
        return Result.success(Booking.fromJson(bookingMap));
      } catch (e) {
        return Result.error('Failed to parse booking: ${e.toString()}');
      }
    } else {
      return Result.error(result.message ?? 'Failed to cancel booking');
    }
  }

  /// Generate pickup OTP
  Future<Result<BookingOtp>> generatePickupOtp(String bookingId) async {
    final result = await apiService.post(
      '${ApiEndpoints.bookings}/$bookingId/otp/pickup/generate',
      isTokenRequired: true,
    );
print(result.toString());
    if (result.isSuccess) {
      try {
        final code = result.data['code'].toString();
        final otpId = result.data['otpId'].toString();
        
        // Create a minimal BookingOtp object with available data
        // expiresAt defaults to 10 minutes from now (matching server behavior)
        final expiresAt = DateTime.now().add(const Duration(minutes: 10));
        
        final bookingOtp = BookingOtp(
          id: otpId.toString(),
          bookingId: bookingId,
          kind: OtpKind.pickup,
          code: code,
          issuedTo: OtpIssuedTo.customer,
          expiresAt: expiresAt,
          attempts: 0,
          maxAttempts: 5,
          isActive: true,
        );
        
        return Result.success(bookingOtp);
      } catch (e) {
        return Result.error('Failed to parse OTP: ${e.toString()}');
      }
    } else {
      return Result.error(result.message ?? 'Failed to generate pickup OTP');
    }
  }

  /// Generate delivery OTP
  Future<Result<BookingOtp>> generateDeliveryOtp(String bookingId) async {
    final result = await apiService.post(
      '${ApiEndpoints.bookings}/$bookingId/otp/delivery/generate',
      isTokenRequired: true,
    );
    if (result.isSuccess) {
      try {
        final responseData = result.data is Map<String, dynamic>
            ? result.data as Map<String, dynamic>
            : <String, dynamic>{};
        
        // Server response structure: { success, statusCode, message, data: { otpId, code }, ... }
        // Extract the actual OTP data from response.data
        final otpData = responseData['data'];
        if (otpData == null || otpData is! Map<String, dynamic>) {
          return Result.error('Invalid OTP response format');
        }
        
        final otpMap = otpData;
        
        // Server only returns otpId and code in the data field
        final otpId = otpMap['otpId'] ?? otpMap['_id'] ?? otpMap['id'];
        final codeValue = otpMap['code'];
        
        if (codeValue == null || codeValue.toString().isEmpty) {
          return Result.error('OTP code not found in response');
        }
        
        final code = codeValue.toString();
        
        // Create a minimal BookingOtp object with available data
        // expiresAt defaults to 10 minutes from now (matching server behavior)
        final expiresAt = DateTime.now().add(const Duration(minutes: 10));
        
        final bookingOtp = BookingOtp(
          id: otpId?.toString(),
          bookingId: bookingId,
          kind: OtpKind.delivery,
          code: code,
          issuedTo: OtpIssuedTo.customer,
          expiresAt: expiresAt,
          attempts: 0,
          maxAttempts: 5,
          isActive: true,
        );
        
        return Result.success(bookingOtp);
      } catch (e) {
        return Result.error('Failed to parse OTP: ${e.toString()}');
      }
    } else {
      return Result.error(result.message ?? 'Failed to generate delivery OTP');
    }
  }

  /// Verify pickup OTP
  Future<Result<Booking>> verifyPickupOtp({
    required String bookingId,
    required String code,
  }) async {
    final result = await apiService.post(
      '${ApiEndpoints.bookings}/$bookingId/pickup/verify-otp',
      body: {'code': code},
      isTokenRequired: true,
    );

    if (result.isSuccess) {
      try {
        final bookingData = result.data is Map<String, dynamic>
            ? result.data as Map<String, dynamic>
            : <String, dynamic>{};
        final booking = bookingData['booking'] ?? bookingData;
        final bookingMap = booking is Map<String, dynamic>
            ? booking
            : Map<String, dynamic>.from(booking);
        return Result.success(Booking.fromJson(bookingMap));
      } catch (e) {
        return Result.error('Failed to parse booking: ${e.toString()}');
      }
    } else {
      return Result.error(result.message ?? 'Failed to verify pickup OTP');
    }
  }

  /// Verify delivery OTP
  Future<Result<Booking>> verifyDeliveryOtp({
    required String bookingId,
    required String code,
  }) async {
    final result = await apiService.post(
      '${ApiEndpoints.bookings}/$bookingId/delivery/verify-otp',
      body: {'code': code},
      isTokenRequired: true,
    );

    if (result.isSuccess) {
      try {
        final bookingData = result.data is Map<String, dynamic>
            ? result.data as Map<String, dynamic>
            : <String, dynamic>{};
        final booking = bookingData['booking'] ?? bookingData;
        final bookingMap = booking is Map<String, dynamic>
            ? booking
            : Map<String, dynamic>.from(booking);
        return Result.success(Booking.fromJson(bookingMap));
      } catch (e) {
        return Result.error('Failed to parse booking: ${e.toString()}');
      }
    } else {
      return Result.error(result.message ?? 'Failed to verify delivery OTP');
    }
  }
}

