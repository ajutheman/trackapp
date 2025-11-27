import 'package:flutter/material.dart';

class TripLocation {
  final String? address;
  final List<double> coordinates; // [longitude, latitude]

  TripLocation({this.address, required this.coordinates});

  factory TripLocation.fromJson(Map<String, dynamic> json) {
    List<double> parseCoordinates(dynamic coords) {
      if (coords == null) return [];
      if (coords is! List) return [];
      try {
        return coords.map((e) {
          if (e is num) return e.toDouble();
          if (e is String) {
            final parsed = double.tryParse(e);
            return parsed ?? 0.0;
          }
          return 0.0;
        }).toList();
      } catch (e) {
        print('Error parsing coordinates: $e, value: $coords');
        return [];
      }
    }

    return TripLocation(
      address: json['address']?.toString(),
      coordinates: parseCoordinates(json['coordinates']),
    );
  }

  Map<String, dynamic> toJson() {
    return {if (address != null) 'address': address, 'coordinates': coordinates};
  }
}

class RouteGeoJSON {
  final String type;
  final List<List<double>> coordinates; // [[longitude, latitude], ...]

  RouteGeoJSON({required this.type, required this.coordinates});

  factory RouteGeoJSON.fromJson(Map<String, dynamic> json) {
    List<List<double>> parseCoordinates(dynamic coords) {
      if (coords == null || coords is! List) return [];
      try {
        return coords.map((coord) {
          if (coord is! List) return <double>[];
          return coord.map((e) {
            if (e is num) return e.toDouble();
            if (e is String) {
              final parsed = double.tryParse(e);
              return parsed ?? 0.0;
            }
            return 0.0;
          }).toList();
        }).toList();
      } catch (e) {
        print('Error parsing route coordinates: $e, value: $coords');
        return [];
      }
    }

    return RouteGeoJSON(
      type: json['type']?.toString() ?? 'LineString',
      coordinates: parseCoordinates(json['coordinates']),
    );
  }

  Map<String, dynamic> toJson() {
    return {'type': type, 'coordinates': coordinates};
  }
}

class Distance {
  final double value;
  final String text;

  Distance({required this.value, required this.text});

  factory Distance.fromJson(Map<String, dynamic> json) {
    return Distance(value: json['value'] != null ? (json['value'] as num).toDouble() : 0.0, text: json['text'] ?? '');
  }

  Map<String, dynamic> toJson() {
    return {'value': value, 'text': text};
  }
}

class TripDuration {
  final int value; // in minutes
  final String text;

  TripDuration({required this.value, required this.text});

  factory TripDuration.fromJson(Map<String, dynamic> json) {
    return TripDuration(value: json['value'] is int ? json['value'] : (json['value'] as num?)?.toInt() ?? 0, text: json['text'] ?? '');
  }

  Map<String, dynamic> toJson() {
    return {'value': value, 'text': text};
  }
}

class User {
  final String id;
  final String name;
  final String phone;
  final String email;
  final String? profilePictureUrl;
  final String? profilePictureId;

  User({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    this.profilePictureUrl,
    this.profilePictureId,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    // Helper to extract string value from string or object
    String extractString(dynamic value, String field) {
      if (value == null) return '';
      if (value is String) return value;
      if (value is Map) return value[field]?.toString() ?? '';
      return value.toString();
    }

    // Helper to extract optional string value
    String? extractOptionalString(dynamic value, String? field) {
      if (value == null) return null;
      if (value is String) return value.isEmpty ? null : value;
      if (value is Map && field != null) {
        final result = value[field]?.toString();
        return result != null && result.isNotEmpty ? result : null;
      }
      return null;
    }

    return User(
      id: extractString(json['_id'], '_id'),
      name: extractString(json['name'], 'name'),
      phone: extractString(json['phone'], 'phone'),
      email: extractString(json['email'], 'email'),
      profilePictureUrl: extractOptionalString(json['profilePicture'], 'url') ??
          (json['profilePictureUrl'] is String ? json['profilePictureUrl'] as String? : null),
      profilePictureId: extractOptionalString(json['profilePicture'], '_id') ??
          (json['profilePictureId'] is String ? json['profilePictureId'] as String? : null),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'phone': phone,
      'email': email,
      if (profilePictureUrl != null) 'profilePictureUrl': profilePictureUrl,
      if (profilePictureId != null) 'profilePictureId': profilePictureId,
    };
  }
}

class Vehicle {
  final String id;
  final String vehicleNumber;
  final String vehicleType;
  final String vehicleBodyType;

  Vehicle({required this.id, required this.vehicleNumber, required this.vehicleType, required this.vehicleBodyType});

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    // Helper to extract string value from string or object
    String extractString(dynamic value, String field) {
      if (value == null) return '';
      if (value is String) return value;
      if (value is Map) return value[field]?.toString() ?? value['name']?.toString() ?? value['_id']?.toString() ?? '';
      return value.toString();
    }

    return Vehicle(
      id: extractString(json['_id'], '_id'),
      vehicleNumber: extractString(json['vehicleNumber'], 'vehicleNumber'),
      vehicleType: extractString(json['vehicleType'], 'vehicleType'),
      vehicleBodyType: extractString(json['vehicleBodyType'], 'vehicleBodyType'),
    );
  }

  Map<String, dynamic> toJson() {
    return {'_id': id, 'vehicleNumber': vehicleNumber, 'vehicleType': vehicleType, 'vehicleBodyType': vehicleBodyType};
  }
}

class GoodsType {
  final String id;
  final String name;
  final String description;

  GoodsType({required this.id, required this.name, required this.description});

  factory GoodsType.fromJson(Map<String, dynamic> json) {
    // Helper to extract string value from string or object
    String extractString(dynamic value, String field) {
      if (value == null) return '';
      if (value is String) return value;
      if (value is Map) return value[field]?.toString() ?? '';
      return value.toString();
    }

    return GoodsType(
      id: extractString(json['_id'], '_id'),
      name: extractString(json['name'], 'name'),
      description: extractString(json['description'], 'description'),
    );
  }

  Map<String, dynamic> toJson() {
    return {'_id': id, 'name': name, 'description': description};
  }
}

class TripStatus {
  final String id;
  final String name;
  final String description;

  TripStatus({required this.id, required this.name, required this.description});

  factory TripStatus.fromJson(Map<String, dynamic> json) {
    // Helper to extract string value from string or object
    String extractString(dynamic value, String field) {
      if (value == null) return '';
      if (value is String) return value;
      if (value is Map) return value[field]?.toString() ?? '';
      return value.toString();
    }

    return TripStatus(
      id: extractString(json['_id'], '_id'),
      name: extractString(json['name'], 'name'),
      description: extractString(json['description'], 'description'),
    );
  }

  Map<String, dynamic> toJson() {
    return {'_id': id, 'name': name, 'description': description};
  }
}

// Package details for customer requests
class PackageDetails {
  final double? weight; // in kg
  final Dimensions? dimensions;
  final String? description;

  PackageDetails({
    this.weight,
    this.dimensions,
    this.description,
  });

  factory PackageDetails.fromJson(Map<String, dynamic> json) {
    return PackageDetails(
      weight: json['weight'] != null ? (json['weight'] as num).toDouble() : null,
      dimensions: json['dimensions'] != null ? Dimensions.fromJson(json['dimensions']) : null,
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (weight != null) 'weight': weight,
      if (dimensions != null) 'dimensions': dimensions!.toJson(),
      if (description != null) 'description': description,
    };
  }
}

// Dimensions for package details
class Dimensions {
  final double? length;
  final double? width;
  final double? height;

  Dimensions({
    this.length,
    this.width,
    this.height,
  });

  factory Dimensions.fromJson(Map<String, dynamic> json) {
    return Dimensions(
      length: json['length'] != null ? (json['length'] as num).toDouble() : null,
      width: json['width'] != null ? (json['width'] as num).toDouble() : null,
      height: json['height'] != null ? (json['height'] as num).toDouble() : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (length != null) 'length': length,
      if (width != null) 'width': width,
      if (height != null) 'height': height,
    };
  }
}

/// Connection statistics for Customer Requests (Leads)
/// Tracks how many drivers have connected to this customer request
class ConnectStats {
  final int total;      // Total connection attempts
  final int pending;    // Pending connections
  final int accepted;   // Accepted connections
  final int rejected;   // Rejected connections
  final int hold;       // Connections on hold
  final DateTime? updatedAt;

  ConnectStats({
    this.total = 0,
    this.pending = 0,
    this.accepted = 0,
    this.rejected = 0,
    this.hold = 0,
    this.updatedAt,
  });

  factory ConnectStats.fromJson(Map<String, dynamic> json) {
    return ConnectStats(
      total: json['total'] ?? 0,
      pending: json['pending'] ?? 0,
      accepted: json['accepted'] ?? 0,
      rejected: json['rejected'] ?? 0,
      hold: json['hold'] ?? 0,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total': total,
      'pending': pending,
      'accepted': accepted,
      'rejected': rejected,
      'hold': hold,
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }
}

/// Universal Post model that handles both:
/// 1. TRIPS - Driver postings of available trips (has tripStartLocation, tripAddedBy)
/// 2. CUSTOMER REQUESTS (Leads for drivers) - Customer service requests (has pickupLocationObj, user)
class Post {
  final String? id;
  final String title;
  final String description;
  final DateTime date;
  final String? imageUrl;
  final String? postType;  // 'trip' or 'customer_request'
  final String? pickupLocation;
  final String? dropLocation;
  final String? goodsType;
  final String? vehicleType;
  final String? userId;
  final String? userName;
  final bool? isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // Trip-specific fields (for driver postings)
  final TripLocation? tripStartLocation;
  final TripLocation? tripDestination;
  final List<TripLocation>? viaRoutes;
  final RouteGeoJSON? routeGeoJSON;
  final Vehicle? vehicleDetails;
  final bool? selfDrive;
  final User? driver;
  final Distance? distance;
  final TripDuration? duration;
  final GoodsType? goodsTypeDetails;
  final double? weight;
  final DateTime? tripStartDate;
  final DateTime? tripEndDate;
  final TripLocation? currentLocation;
  final User? tripAddedBy;
  final TripStatus? status;
  final bool? isStarted;

  // Customer request-specific fields (Leads for drivers)
  final TripLocation? pickupLocationObj; // For customer requests (pickupLocation)
  final TripLocation? dropoffLocationObj; // For customer requests (dropoffLocation)
  final PackageDetails? packageDetails;
  final List<String>? images; // Image IDs
  final List<String>? documents; // Document IDs
  final DateTime? pickupTime;
  final ConnectStats? connectStats; // Connection statistics for customer requests

  Post({
    this.id,
    required this.title,
    required this.description,
    required this.date,
    this.imageUrl,
    this.postType,
    this.pickupLocation,
    this.dropLocation,
    this.goodsType,
    this.vehicleType,
    this.userId,
    this.userName,
    this.isActive,
    this.createdAt,
    this.updatedAt,
    this.tripStartLocation,
    this.tripDestination,
    this.viaRoutes,
    this.routeGeoJSON,
    this.vehicleDetails,
    this.selfDrive,
    this.driver,
    this.distance,
    this.duration,
    this.goodsTypeDetails,
    this.weight,
    this.tripStartDate,
    this.tripEndDate,
    this.currentLocation,
    this.tripAddedBy,
    this.status,
    this.isStarted,
    this.pickupLocationObj,
    this.dropoffLocationObj,
    this.packageDetails,
    this.images,
    this.documents,
    this.pickupTime,
    this.connectStats,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    try {
      // Helper to extract ID from string or object
      String? extractId(dynamic value) {
        if (value == null) return null;
        if (value is String) return value;
        if (value is Map<String, dynamic>) {
          final id = value['_id'];
          if (id != null) return id.toString();
        }
        return value.toString();
      }

      // Helper to extract list of IDs
      List<String>? extractIdList(dynamic value) {
        if (value == null) return null;
        if (value is! List) return null;
        return value.map((e) => extractId(e) ?? '').where((id) => id.isNotEmpty).toList();
      }

      // Determine if this is a trip or customer request
      final isTrip = json['tripStartLocation'] != null || json['tripDestination'] != null;
      final isCustomerRequest = json['pickupLocation'] != null && json['dropoffLocation'] != null && !isTrip;

      return Post(
        id: extractId(json['_id'] ?? json['id']),
        title: json['title'] ?? '',
        description: json['description'] ?? '',
        date: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
        imageUrl: null, // Not used for trips/customer requests
        postType: isTrip ? 'trip' : (isCustomerRequest ? 'customer_request' : null),
        pickupLocation: isTrip 
            ? (json['tripStartLocation'] is Map ? json['tripStartLocation']['address'] : null)
            : (json['pickupLocation'] is Map ? json['pickupLocation']['address'] : null),
        dropLocation: isTrip
            ? (json['tripDestination'] is Map ? json['tripDestination']['address'] : null)
            : (json['dropoffLocation'] is Map ? json['dropoffLocation']['address'] : null),
        goodsType: json['goodsType'] is Map ? json['goodsType']['name'] : (json['goodsType'] is String ? json['goodsType'] : null),
        vehicleType: json['vehicle'] is Map ? json['vehicle']['vehicleNumber'] : null,
        userId: extractId(
          json['user'] is Map 
            ? json['user']['_id'] 
            : (json['tripAddedBy'] is Map 
                ? json['tripAddedBy']['_id'] 
                : (json['user'] ?? json['tripAddedBy']))),
        userName: json['user'] is Map 
            ? json['user']['name'] 
            : (json['tripAddedBy'] is Map ? json['tripAddedBy']['name'] : null),
        isActive: json['isActive'] ?? true,
        createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
        updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
        // Trip-specific fields
        tripStartLocation: json['tripStartLocation'] != null && json['tripStartLocation'] is Map
            ? TripLocation.fromJson(json['tripStartLocation'] as Map<String, dynamic>)
            : null,
        tripDestination: json['tripDestination'] != null && json['tripDestination'] is Map
            ? TripLocation.fromJson(json['tripDestination'] as Map<String, dynamic>)
            : null,
        viaRoutes: json['viaRoutes'] != null && json['viaRoutes'] is List
            ? (json['viaRoutes'] as List).map((route) {
                if (route is Map) {
                  return TripLocation.fromJson(route as Map<String, dynamic>);
                }
                return TripLocation(address: null, coordinates: []);
              }).toList()
            : null,
        routeGeoJSON: json['routeGeoJSON'] != null && json['routeGeoJSON'] is Map
            ? RouteGeoJSON.fromJson(json['routeGeoJSON'] as Map<String, dynamic>)
            : null,
        vehicleDetails: json['vehicle'] != null && json['vehicle'] is Map
            ? Vehicle.fromJson(json['vehicle'] as Map<String, dynamic>)
            : null,
        selfDrive: json['selfDrive'] is bool ? json['selfDrive'] as bool : null,
        driver: json['driver'] != null && json['driver'] is Map
            ? User.fromJson(json['driver'] as Map<String, dynamic>)
            : null,
        distance: json['distance'] != null && json['distance'] is Map
            ? Distance.fromJson(json['distance'] as Map<String, dynamic>)
            : null,
        duration: json['duration'] != null && json['duration'] is Map
            ? TripDuration.fromJson(json['duration'] as Map<String, dynamic>)
            : null,
        goodsTypeDetails: json['goodsType'] != null && json['goodsType'] is Map
            ? GoodsType.fromJson(json['goodsType'] as Map<String, dynamic>)
            : null,
        weight: json['weight'] != null ? (json['weight'] as num).toDouble() : null,
        tripStartDate: json['tripStartDate'] != null ? DateTime.parse(json['tripStartDate']) : null,
        tripEndDate: json['tripEndDate'] != null ? DateTime.parse(json['tripEndDate']) : null,
        tripAddedBy: json['tripAddedBy'] != null && json['tripAddedBy'] is Map
            ? User.fromJson(json['tripAddedBy'] as Map<String, dynamic>)
            : null,
        status: json['status'] != null && json['status'] is Map
            ? TripStatus.fromJson(json['status'] as Map<String, dynamic>)
            : null,
        // Customer request-specific fields
        pickupLocationObj: json['pickupLocation'] != null && json['pickupLocation'] is Map && !isTrip
            ? TripLocation.fromJson(json['pickupLocation'] as Map<String, dynamic>)
            : null,
        dropoffLocationObj: json['dropoffLocation'] != null && json['dropoffLocation'] is Map && !isTrip
            ? TripLocation.fromJson(json['dropoffLocation'] as Map<String, dynamic>)
            : null,
        packageDetails: json['packageDetails'] != null && json['packageDetails'] is Map
            ? PackageDetails.fromJson(json['packageDetails'] as Map<String, dynamic>)
            : null,
        images: extractIdList(json['images']),
        documents: extractIdList(json['documents']),
        pickupTime: json['pickupTime'] != null ? DateTime.parse(json['pickupTime']) : null,
        connectStats: json['connectStats'] != null && json['connectStats'] is Map
            ? ConnectStats.fromJson(json['connectStats'] as Map<String, dynamic>)
            : null,
      );
    } catch (e) {
      print('Error parsing Post from JSON: $e');
      json.forEach((key, value) {
        debugPrint('$key: $value');
      });
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'description': description,
      if (imageUrl != null) 'imageUrl': imageUrl,
      if (postType != null) 'postType': postType,
      if (pickupLocation != null) 'pickupLocation': pickupLocation,
      if (dropLocation != null) 'dropLocation': dropLocation,
      if (goodsType != null) 'goodsType': goodsType,
      if (vehicleType != null) 'vehicleType': vehicleType,
      if (isActive != null) 'isActive': isActive,
      // Trip-specific fields
      if (tripStartLocation != null) 'tripStartLocation': tripStartLocation!.toJson(),
      if (tripDestination != null) 'tripDestination': tripDestination!.toJson(),
      if (viaRoutes != null) 'viaRoutes': viaRoutes!.map((route) => route.toJson()).toList(),
      if (routeGeoJSON != null) 'routeGeoJSON': routeGeoJSON!.toJson(),
      if (vehicleDetails != null) 'vehicle': vehicleDetails!.toJson(),
      if (selfDrive != null) 'selfDrive': selfDrive,
      if (driver != null) 'driver': driver!.toJson(),
      if (distance != null) 'distance': distance!.toJson(),
      if (duration != null) 'duration': duration!.toJson(),
      if (goodsTypeDetails != null) 'goodsType': goodsTypeDetails!.toJson(),
      if (weight != null) 'weight': weight,
      if (tripStartDate != null) 'tripStartDate': tripStartDate!.toIso8601String(),
      if (tripEndDate != null) 'tripEndDate': tripEndDate!.toIso8601String(),
      if (currentLocation != null) 'currentLocation': currentLocation!.toJson(),
      if (tripAddedBy != null) 'tripAddedBy': tripAddedBy!.toJson(),
      if (status != null) 'status': status!.toJson(),
      if (isStarted != null) 'isStarted': isStarted,
      // Customer request fields
      if (pickupLocationObj != null) 'pickupLocation': pickupLocationObj!.toJson(),
      if (dropoffLocationObj != null) 'dropoffLocation': dropoffLocationObj!.toJson(),
      if (packageDetails != null) 'packageDetails': packageDetails!.toJson(),
      if (images != null) 'images': images,
      if (documents != null) 'documents': documents,
      if (pickupTime != null) 'pickupTime': pickupTime!.toIso8601String(),
      if (connectStats != null) 'connectStats': connectStats!.toJson(),
    };
  }

  // Create a copy with updated fields
  Post copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? date,
    String? imageUrl,
    String? postType,
    String? pickupLocation,
    String? dropLocation,
    String? goodsType,
    String? vehicleType,
    String? userId,
    String? userName,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    TripLocation? tripStartLocation,
    TripLocation? tripDestination,
    List<TripLocation>? viaRoutes,
    RouteGeoJSON? routeGeoJSON,
    Vehicle? vehicleDetails,
    bool? selfDrive,
    User? driver,
    Distance? distance,
    TripDuration? duration,
    GoodsType? goodsTypeDetails,
    double? weight,
    DateTime? tripStartDate,
    DateTime? tripEndDate,
    TripLocation? currentLocation,
    User? tripAddedBy,
    TripStatus? status,
    bool? isStarted,
    TripLocation? pickupLocationObj,
    TripLocation? dropoffLocationObj,
    PackageDetails? packageDetails,
    List<String>? images,
    List<String>? documents,
    DateTime? pickupTime,
  }) {
    return Post(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      imageUrl: imageUrl ?? this.imageUrl,
      postType: postType ?? this.postType,
      pickupLocation: pickupLocation ?? this.pickupLocation,
      dropLocation: dropLocation ?? this.dropLocation,
      goodsType: goodsType ?? this.goodsType,
      vehicleType: vehicleType ?? this.vehicleType,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      tripStartLocation: tripStartLocation ?? this.tripStartLocation,
      tripDestination: tripDestination ?? this.tripDestination,
      viaRoutes: viaRoutes ?? this.viaRoutes,
      routeGeoJSON: routeGeoJSON ?? this.routeGeoJSON,
      vehicleDetails: vehicleDetails ?? this.vehicleDetails,
      selfDrive: selfDrive ?? this.selfDrive,
      driver: driver ?? this.driver,
      distance: distance ?? this.distance,
      duration: duration ?? this.duration,
      goodsTypeDetails: goodsTypeDetails ?? this.goodsTypeDetails,
      weight: weight ?? this.weight,
      tripStartDate: tripStartDate ?? this.tripStartDate,
      tripEndDate: tripEndDate ?? this.tripEndDate,
      currentLocation: currentLocation ?? this.currentLocation,
      tripAddedBy: tripAddedBy ?? this.tripAddedBy,
      status: status ?? this.status,
      isStarted: isStarted ?? this.isStarted,
      pickupLocationObj: pickupLocationObj ?? this.pickupLocationObj,
      dropoffLocationObj: dropoffLocationObj ?? this.dropoffLocationObj,
      packageDetails: packageDetails ?? this.packageDetails,
      images: images ?? this.images,
      documents: documents ?? this.documents,
      pickupTime: pickupTime ?? this.pickupTime,
    );
  }
}
