// lib/features/connect/model/driver_connection.dart

class DriverConnection {
  final String? id;
  final String? requesterId;
  final String? requestedId;
  final DriverConnectionStatus status;
  final DateTime? requestedAt;
  final DateTime? respondedAt;
  final bool isActive;
  
  // Populated fields
  final DriverFriend? requester;
  final DriverFriend? requested;

  DriverConnection({
    this.id,
    this.requesterId,
    this.requestedId,
    this.status = DriverConnectionStatus.pending,
    this.requestedAt,
    this.respondedAt,
    this.isActive = true,
    this.requester,
    this.requested,
  });

  factory DriverConnection.fromJson(Map<String, dynamic> json) {
    return DriverConnection(
      id: json['_id'] ?? json['id'],
      requesterId: json['requester'] is String 
          ? json['requester'] 
          : json['requester']?['_id'],
      requestedId: json['requested'] is String 
          ? json['requested'] 
          : json['requested']?['_id'],
      status: _statusFromString(json['status'] ?? 'pending'),
      requestedAt: json['requestedAt'] != null 
          ? DateTime.parse(json['requestedAt']) 
          : null,
      respondedAt: json['respondedAt'] != null 
          ? DateTime.parse(json['respondedAt']) 
          : null,
      isActive: json['isActive'] ?? true,
      requester: json['requester'] is Map 
          ? DriverFriend.fromJson(json['requester']) 
          : null,
      requested: json['requested'] is Map 
          ? DriverFriend.fromJson(json['requested']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      if (requesterId != null) 'requester': requesterId,
      if (requestedId != null) 'requested': requestedId,
      'status': status.toString().split('.').last,
      if (requestedAt != null) 'requestedAt': requestedAt!.toIso8601String(),
      if (respondedAt != null) 'respondedAt': respondedAt!.toIso8601String(),
      'isActive': isActive,
    };
  }

  static DriverConnectionStatus _statusFromString(String status) {
    switch (status.toLowerCase()) {
      case 'accepted':
        return DriverConnectionStatus.accepted;
      case 'rejected':
        return DriverConnectionStatus.rejected;
      case 'pending':
      default:
        return DriverConnectionStatus.pending;
    }
  }

  DriverConnection copyWith({
    String? id,
    String? requesterId,
    String? requestedId,
    DriverConnectionStatus? status,
    DateTime? requestedAt,
    DateTime? respondedAt,
    bool? isActive,
    DriverFriend? requester,
    DriverFriend? requested,
  }) {
    return DriverConnection(
      id: id ?? this.id,
      requesterId: requesterId ?? this.requesterId,
      requestedId: requestedId ?? this.requestedId,
      status: status ?? this.status,
      requestedAt: requestedAt ?? this.requestedAt,
      respondedAt: respondedAt ?? this.respondedAt,
      isActive: isActive ?? this.isActive,
      requester: requester ?? this.requester,
      requested: requested ?? this.requested,
    );
  }
}

enum DriverConnectionStatus {
  pending,
  accepted,
  rejected,
}

class DriverFriend {
  final String id;
  final String name;
  final String phone;
  final String? connectionId;
  final DateTime? connectedSince;
  final bool? isSelfDrive;

  DriverFriend({
    required this.id,
    required this.name,
    required this.phone,
    this.connectionId,
    this.connectedSince,
    this.isSelfDrive,
  });

  factory DriverFriend.fromJson(Map<String, dynamic> json) {
    return DriverFriend(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      phone: json['phone'] ?? json['mobileNumber'] ?? '',
      connectionId: json['connectionId'],
      connectedSince: json['connectedSince'] != null 
          ? DateTime.parse(json['connectedSince']) 
          : null,
      isSelfDrive: json['isSelfDrive'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'phone': phone,
      if (connectionId != null) 'connectionId': connectionId,
      if (connectedSince != null) 'connectedSince': connectedSince!.toIso8601String(),
      if (isSelfDrive != null) 'isSelfDrive': isSelfDrive,
    };
  }
}

