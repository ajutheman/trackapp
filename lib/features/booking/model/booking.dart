// lib/features/booking/model/booking.dart

class Booking {
  final String? id;
  final String tripId;
  final String customerRequestId;
  final String driverId;
  final String customerId;
  final String initiatorId;
  final String recipientId;
  final String? connectRequestId;
  final double? price;
  final DateTime? pickupDate;
  final String? notes;
  final BookingStatus status;
  final bool initiatorAccepted;
  final bool recipientAccepted;
  final DateTime? acceptedAt;
  final DateTime? rejectedAt;
  final DateTime? cancelledAt;
  final DateTime? completedAt;
  final bool cancellationPending;
  final String? cancellationRequestedBy;
  final DateTime? cancellationRequestedAt;
  final String? cancellationReason;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final BookingOtp? pickupOtp;
  final BookingOtp? deliveryOtp;

  // Populated fields
  final TripInfo? trip;
  final CustomerRequestInfo? customerRequest;
  final UserInfo? driver;
  final UserInfo? customer;
  final UserInfo? initiator;
  final UserInfo? recipient;

  Booking({
    this.id,
    required this.tripId,
    required this.customerRequestId,
    required this.driverId,
    required this.customerId,
    required this.initiatorId,
    required this.recipientId,
    this.connectRequestId,
    this.price,
    this.pickupDate,
    this.notes,
    this.status = BookingStatus.pending,
    this.initiatorAccepted = true,
    this.recipientAccepted = false,
    this.acceptedAt,
    this.rejectedAt,
    this.cancelledAt,
    this.completedAt,
    this.cancellationPending = false,
    this.cancellationRequestedBy,
    this.cancellationRequestedAt,
    this.cancellationReason,
    this.createdAt,
    this.updatedAt,
    this.trip,
    this.customerRequest,
    this.driver,
    this.customer,
    this.initiator,
    this.recipient,
    this.pickupOtp,
    this.deliveryOtp,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['_id'] ?? json['id'],
      tripId: _extractId(json['trip']),
      customerRequestId: _extractId(json['customerRequest']),
      driverId: _extractId(json['driver']),
      customerId: _extractId(json['customer']),
      initiatorId: _extractId(json['initiator']),
      recipientId: _extractId(json['recipient']),
      connectRequestId:
          json['connectRequest'] != null
              ? _extractId(json['connectRequest'])
              : null,
      price: json['price'] != null ? (json['price'] as num).toDouble() : null,
      pickupDate:
          json['pickupDate'] != null
              ? DateTime.parse(json['pickupDate'])
              : null,
      notes: json['notes'],
      status: _statusFromString(json['status'] ?? 'pending'),
      initiatorAccepted: json['initiatorAccepted'] ?? true,
      recipientAccepted: json['recipientAccepted'] ?? false,
      acceptedAt:
          json['acceptedAt'] != null
              ? DateTime.parse(json['acceptedAt'])
              : null,
      rejectedAt:
          json['rejectedAt'] != null
              ? DateTime.parse(json['rejectedAt'])
              : null,
      cancelledAt:
          json['cancelledAt'] != null
              ? DateTime.parse(json['cancelledAt'])
              : null,
      completedAt:
          json['completedAt'] != null
              ? DateTime.parse(json['completedAt'])
              : null,
      cancellationPending: json['cancellationPending'] ?? false,
      cancellationRequestedBy:
          json['cancellationRequestedBy'] != null
              ? _extractId(json['cancellationRequestedBy'])
              : null,
      cancellationRequestedAt:
          json['cancellationRequestedAt'] != null
              ? DateTime.parse(json['cancellationRequestedAt'])
              : null,
      cancellationReason: json['cancellationReason'],
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      trip:
          json['trip'] is Map
              ? TripInfo.fromJson(Map<String, dynamic>.from(json['trip']))
              : null,
      customerRequest:
          json['customerRequest'] is Map
              ? CustomerRequestInfo.fromJson(
                Map<String, dynamic>.from(json['customerRequest']),
              )
              : null,
      driver:
          json['driver'] is Map
              ? UserInfo.fromJson(Map<String, dynamic>.from(json['driver']))
              : null,
      customer:
          json['customer'] is Map
              ? UserInfo.fromJson(Map<String, dynamic>.from(json['customer']))
              : null,
      initiator:
          json['initiator'] is Map
              ? UserInfo.fromJson(Map<String, dynamic>.from(json['initiator']))
              : null,
      recipient:
          json['recipient'] is Map
              ? UserInfo.fromJson(Map<String, dynamic>.from(json['recipient']))
              : null,
      pickupOtp:
          json['pickupOtp'] != null
              ? BookingOtp.fromJson(
                Map<String, dynamic>.from(json['pickupOtp']),
              )
              : null,
      deliveryOtp:
          json['deliveryOtp'] != null
              ? BookingOtp.fromJson(
                Map<String, dynamic>.from(json['deliveryOtp']),
              )
              : null,
    );
  }

  static String _extractId(dynamic value) {
    if (value is String) return value;
    if (value is Map) return value['_id'] ?? value['id'] ?? '';
    return '';
  }

  static BookingStatus _statusFromString(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return BookingStatus.confirmed;
      case 'rejected':
        return BookingStatus.rejected;
      case 'cancelled':
        return BookingStatus.cancelled;
      case 'expired':
        return BookingStatus.expired;
      case 'picked_up':
        return BookingStatus.pickedUp;
      case 'delivered':
        return BookingStatus.delivered;
      case 'completed':
        return BookingStatus.completed;
      case 'pending':
      default:
        return BookingStatus.pending;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      'tripId': tripId,
      'customerRequestId': customerRequestId,
      'driverId': driverId,
      'customerId': customerId,
      'initiatorId': initiatorId,
      'recipientId': recipientId,
      if (connectRequestId != null) 'connectRequestId': connectRequestId,
      if (price != null) 'price': price,
      if (pickupDate != null) 'pickupDate': pickupDate!.toIso8601String(),
      if (notes != null) 'notes': notes,
      'status': status.toString().split('.').last,
      'initiatorAccepted': initiatorAccepted,
      'recipientAccepted': recipientAccepted,
    };
  }
}

enum BookingStatus {
  pending,
  confirmed,
  rejected,
  cancelled,
  expired,
  pickedUp,
  delivered,
  completed,
}

class TripInfo {
  final String id;
  final String? title;
  final String? description;

  TripInfo({required this.id, this.title, this.description});

  factory TripInfo.fromJson(Map<String, dynamic> json) {
    return TripInfo(
      id: json['_id'] ?? json['id'] ?? '',
      title: json['title'],
      description: json['description'],
    );
  }
}

class CustomerRequestInfo {
  final String id;
  final String? title;
  final String? description;

  CustomerRequestInfo({required this.id, this.title, this.description});

  factory CustomerRequestInfo.fromJson(Map<String, dynamic> json) {
    return CustomerRequestInfo(
      id: json['_id'] ?? json['id'] ?? '',
      title: json['title'],
      description: json['description'],
    );
  }
}

class UserInfo {
  final String id;
  final String name;
  final String? email;
  final String? phone;

  UserInfo({required this.id, required this.name, this.email, this.phone});

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'],
      phone: json['phone'],
    );
  }
}

class BookingOtp {
  final String? id;
  final String bookingId;
  final OtpKind kind;
  final String code;
  final OtpIssuedTo issuedTo;
  final DateTime expiresAt;
  final DateTime? consumedAt;
  final int attempts;
  final int maxAttempts;
  final bool isActive;
  final DateTime? createdAt;

  BookingOtp({
    this.id,
    required this.bookingId,
    required this.kind,
    required this.code,
    required this.issuedTo,
    required this.expiresAt,
    this.consumedAt,
    this.attempts = 0,
    this.maxAttempts = 5,
    this.isActive = true,
    this.createdAt,
  });

  factory BookingOtp.fromJson(Map<String, dynamic> json) {
    return BookingOtp(
      id: json['_id'] ?? json['id'],
      bookingId: _extractId(json['booking']),
      kind: _kindFromString(json['kind'] ?? 'pickup'),
      code: json['code'] ?? '',
      issuedTo: _issuedToFromString(json['issuedTo'] ?? 'customer'),
      expiresAt: DateTime.parse(json['expiresAt']),
      consumedAt:
          json['consumedAt'] != null
              ? DateTime.parse(json['consumedAt'])
              : null,
      attempts: json['attempts'] ?? 0,
      maxAttempts: json['maxAttempts'] ?? 5,
      isActive: json['isActive'] ?? true,
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
    );
  }

  static String _extractId(dynamic value) {
    if (value is String) return value;
    if (value is Map) return value['_id'] ?? value['id'] ?? '';
    return '';
  }

  static OtpKind _kindFromString(String kind) {
    return kind.toLowerCase() == 'delivery' ? OtpKind.delivery : OtpKind.pickup;
  }

  static OtpIssuedTo _issuedToFromString(String issuedTo) {
    return issuedTo.toLowerCase() == 'driver'
        ? OtpIssuedTo.driver
        : OtpIssuedTo.customer;
  }
}

enum OtpKind { pickup, delivery }

enum OtpIssuedTo { driver, customer }
