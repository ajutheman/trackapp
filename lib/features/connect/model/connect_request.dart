// lib/features/connect/model/connect_request.dart

class ConnectRequest {
  final String? id;
  final String? requesterId;
  final String? recipientId;
  final String? customerRequestId;
  final String? tripId;
  final String? message;
  final ConnectRequestStatus status;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  
  // Populated fields
  final ConnectUser? requester;
  final ConnectUser? recipient;
  final Trip? trip;
  final CustomerRequest? customerRequest;
  final ContactDetails? contactDetails;

  ConnectRequest({
    this.id,
    this.requesterId,
    this.recipientId,
    this.customerRequestId,
    this.tripId,
    this.message,
    this.status = ConnectRequestStatus.pending,
    this.createdAt,
    this.updatedAt,
    this.requester,
    this.recipient,
    this.trip,
    this.customerRequest,
    this.contactDetails,
  });

  factory ConnectRequest.fromJson(Map<String, dynamic> json) {
    return ConnectRequest(
      id: json['_id'] ?? json['id'],
      requesterId: json['requesterId'] is String ? json['requesterId'] : json['requesterId']?['_id'],
      recipientId: json['recipientId'] is String ? json['recipientId'] : json['recipientId']?['_id'],
      customerRequestId: json['customerRequestId'] is String ? json['customerRequestId'] : json['customerRequestId']?['_id'],
      tripId: json['tripId'] is String ? json['tripId'] : json['tripId']?['_id'],
      message: json['message'],
      status: _statusFromString(json['status'] ?? 'pending'),
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      requester: json['requesterId'] is Map ? ConnectUser.fromJson(json['requesterId']) : null,
      recipient: json['recipientId'] is Map ? ConnectUser.fromJson(json['recipientId']) : null,
      trip: json['tripId'] is Map ? Trip.fromJson(json['tripId']) : null,
      customerRequest: json['customerRequestId'] is Map ? CustomerRequest.fromJson(json['customerRequestId']) : null,
      contactDetails: json['contactDetails'] != null ? ContactDetails.fromJson(json['contactDetails']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      if (requesterId != null) 'requesterId': requesterId,
      if (recipientId != null) 'recipientId': recipientId,
      if (customerRequestId != null) 'customerRequestId': customerRequestId,
      if (tripId != null) 'tripId': tripId,
      if (message != null) 'message': message,
      'status': status.toString().split('.').last,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }

  static ConnectRequestStatus _statusFromString(String status) {
    switch (status.toLowerCase()) {
      case 'accepted':
        return ConnectRequestStatus.accepted;
      case 'rejected':
        return ConnectRequestStatus.rejected;
      case 'cancelled':
        return ConnectRequestStatus.cancelled;
      case 'pending':
      default:
        return ConnectRequestStatus.pending;
    }
  }

  ConnectRequest copyWith({
    String? id,
    String? requesterId,
    String? recipientId,
    String? customerRequestId,
    String? tripId,
    String? message,
    ConnectRequestStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    ConnectUser? requester,
    ConnectUser? recipient,
    Trip? trip,
    CustomerRequest? customerRequest,
    ContactDetails? contactDetails,
  }) {
    return ConnectRequest(
      id: id ?? this.id,
      requesterId: requesterId ?? this.requesterId,
      recipientId: recipientId ?? this.recipientId,
      customerRequestId: customerRequestId ?? this.customerRequestId,
      tripId: tripId ?? this.tripId,
      message: message ?? this.message,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      requester: requester ?? this.requester,
      recipient: recipient ?? this.recipient,
      trip: trip ?? this.trip,
      customerRequest: customerRequest ?? this.customerRequest,
      contactDetails: contactDetails ?? this.contactDetails,
    );
  }
}

enum ConnectRequestStatus {
  pending,
  accepted,
  rejected,
  cancelled,
}

class ConnectUser {
  final String id;
  final String name;
  final String? phone;
  final String? email;
  final String? profileImage;

  ConnectUser({
    required this.id,
    required this.name,
    this.phone,
    this.email,
    this.profileImage,
  });

  factory ConnectUser.fromJson(Map<String, dynamic> json) {
    return ConnectUser(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      phone: json['phone'],
      email: json['email'],
      profileImage: json['profileImage'] ?? json['profile_image'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      if (phone != null) 'phone': phone,
      if (email != null) 'email': email,
      if (profileImage != null) 'profileImage': profileImage,
    };
  }
}

class Trip {
  final String id;
  final String? title;
  final String? description;
  final String? startLocation;
  final String? destination;

  Trip({
    required this.id,
    this.title,
    this.description,
    this.startLocation,
    this.destination,
  });

  factory Trip.fromJson(Map<String, dynamic> json) {
    return Trip(
      id: json['_id'] ?? json['id'] ?? '',
      title: json['title'],
      description: json['description'],
      startLocation: json['tripStartLocation']?['address'] ?? json['startLocation'],
      destination: json['tripDestination']?['address'] ?? json['destination'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (startLocation != null) 'startLocation': startLocation,
      if (destination != null) 'destination': destination,
    };
  }
}

class CustomerRequest {
  final String id;
  final String? details;
  final String? requestType;

  CustomerRequest({
    required this.id,
    this.details,
    this.requestType,
  });

  factory CustomerRequest.fromJson(Map<String, dynamic> json) {
    return CustomerRequest(
      id: json['_id'] ?? json['id'] ?? '',
      details: json['details'] ?? json['description'],
      requestType: json['requestType'] ?? json['type'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      if (details != null) 'details': details,
      if (requestType != null) 'requestType': requestType,
    };
  }
}

class ContactDetails {
  final String? phone;
  final String? email;
  final String? name;
  final bool canViewContact;

  ContactDetails({
    this.phone,
    this.email,
    this.name,
    this.canViewContact = false,
  });

  factory ContactDetails.fromJson(Map<String, dynamic> json) {
    return ContactDetails(
      phone: json['phone'],
      email: json['email'],
      name: json['name'],
      canViewContact: json['canViewContact'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (phone != null) 'phone': phone,
      if (email != null) 'email': email,
      if (name != null) 'name': name,
      'canViewContact': canViewContact,
    };
  }
}

