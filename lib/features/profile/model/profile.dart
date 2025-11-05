/// Profile model representing user profile data
class Profile {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String? whatsappNumber;
  final String? profilePictureUrl;
  final String? profilePictureId;
  final UserType? userType;
  final bool isActive;
  final bool isPhoneVerified;
  final bool isEmailVerified;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final Vehicle? vehicle; // For drivers

  Profile({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.whatsappNumber,
    this.profilePictureUrl,
    this.profilePictureId,
    this.userType,
    this.isActive = true,
    this.isPhoneVerified = false,
    this.isEmailVerified = false,
    this.createdAt,
    this.updatedAt,
    this.vehicle,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    final userData = json['user'] ?? json;
    
    return Profile(
      id: userData['_id'] ?? '',
      name: userData['name'] ?? '',
      email: userData['email'] ?? '',
      phone: userData['phone'] ?? '',
      whatsappNumber: userData['whatsappNumber'],
      profilePictureUrl: userData['profilePicture'] is Map
          ? userData['profilePicture']['url']
          : null,
      profilePictureId: userData['profilePicture'] is Map
          ? userData['profilePicture']['_id']
          : (userData['profilePicture'] is String
              ? userData['profilePicture']
              : null),
      userType: userData['user_type'] != null
          ? UserType.fromJson(userData['user_type'] is Map
              ? userData['user_type']
              : {'name': userData['user_type']})
          : null,
      isActive: userData['isActive'] ?? true,
      isPhoneVerified: userData['isPhoneVerified'] ?? false,
      isEmailVerified: userData['isEmailVerified'] ?? false,
      createdAt: userData['createdAt'] != null
          ? DateTime.parse(userData['createdAt'])
          : null,
      updatedAt: userData['updatedAt'] != null
          ? DateTime.parse(userData['updatedAt'])
          : null,
      vehicle: json['vehicle'] != null
          ? Vehicle.fromJson(json['vehicle'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'email': email,
      'phone': phone,
      if (whatsappNumber != null) 'whatsappNumber': whatsappNumber,
      if (profilePictureId != null) 'profilePicture': profilePictureId,
      if (userType != null) 'user_type': userType!.toJson(),
      'isActive': isActive,
      'isPhoneVerified': isPhoneVerified,
      'isEmailVerified': isEmailVerified,
    };
  }

  Profile copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? whatsappNumber,
    String? profilePictureUrl,
    String? profilePictureId,
    UserType? userType,
    bool? isActive,
    bool? isPhoneVerified,
    bool? isEmailVerified,
    DateTime? createdAt,
    DateTime? updatedAt,
    Vehicle? vehicle,
  }) {
    return Profile(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      whatsappNumber: whatsappNumber ?? this.whatsappNumber,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      profilePictureId: profilePictureId ?? this.profilePictureId,
      userType: userType ?? this.userType,
      isActive: isActive ?? this.isActive,
      isPhoneVerified: isPhoneVerified ?? this.isPhoneVerified,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      vehicle: vehicle ?? this.vehicle,
    );
  }
}

class UserType {
  final String id;
  final String name;

  UserType({required this.id, required this.name});

  factory UserType.fromJson(Map<String, dynamic> json) {
    return UserType(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
    };
  }
}

class Vehicle {
  final String id;
  final String vehicleNumber;
  final String? vehicleType;
  final String? vehicleBodyType;

  Vehicle({
    required this.id,
    required this.vehicleNumber,
    this.vehicleType,
    this.vehicleBodyType,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json['_id'] ?? '',
      vehicleNumber: json['vehicleNumber'] ?? '',
      vehicleType: json['vehicleType'] is Map
          ? json['vehicleType']['name']
          : json['vehicleType'],
      vehicleBodyType: json['vehicleBodyType'] is Map
          ? json['vehicleBodyType']['name']
          : json['vehicleBodyType'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'vehicleNumber': vehicleNumber,
      if (vehicleType != null) 'vehicleType': vehicleType,
      if (vehicleBodyType != null) 'vehicleBodyType': vehicleBodyType,
    };
  }
}

