// Supporting model classes for trip data
class TripLocation {
  final String address;
  final List<double> coordinates; // [longitude, latitude]

  TripLocation({required this.address, required this.coordinates});

  factory TripLocation.fromJson(Map<String, dynamic> json) {
    return TripLocation(address: json['address'] ?? '', coordinates: List<double>.from(json['coordinates'] ?? []));
  }

  Map<String, dynamic> toJson() {
    return {'address': address, 'coordinates': coordinates};
  }
}

class RouteGeoJSON {
  final String type;
  final List<List<double>> coordinates; // [[longitude, latitude], ...]

  RouteGeoJSON({required this.type, required this.coordinates});

  factory RouteGeoJSON.fromJson(Map<String, dynamic> json) {
    return RouteGeoJSON(type: json['type'] ?? 'LineString', coordinates: (json['coordinates'] as List?)?.map((coord) => List<double>.from(coord)).toList() ?? []);
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
    return Distance(value: (json['value'] ?? 0).toDouble(), text: json['text'] ?? '');
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
    return TripDuration(value: json['value'] ?? 0, text: json['text'] ?? '');
  }

  Map<String, dynamic> toJson() {
    return {'value': value, 'text': text};
  }
}

class Post {
  final String? id;
  final String title;
  final String description;
  final DateTime date;
  final String? imageUrl;
  final String? postType; // 'load' or 'truck'
  final String? pickupLocation;
  final String? dropLocation;
  final String? goodsType;
  final String? vehicleType;
  final String? userId;
  final String? userName;
  final bool? isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // New trip-specific fields
  final TripLocation? tripStartLocation;
  final TripLocation? tripDestination;
  final List<TripLocation>? viaRoutes;
  final RouteGeoJSON? routeGeoJSON;
  final String? vehicle;
  final bool? selfDrive;
  final String? driver;
  final Distance? distance;
  final TripDuration? duration;
  final String? goodsTypeId;
  final double? weight;
  final DateTime? tripStartDate;
  final DateTime? tripEndDate;

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
    this.vehicle,
    this.selfDrive,
    this.driver,
    this.distance,
    this.duration,
    this.goodsTypeId,
    this.weight,
    this.tripStartDate,
    this.tripEndDate,
  });

  // Factory constructor to create Post from API response
  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['_id'] ?? json['id'],
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      date: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
      imageUrl: json['imageUrl'] ?? json['image'],
      postType: json['postType'] ?? json['type'],
      pickupLocation: json['pickupLocation'] ?? json['from'],
      dropLocation: json['dropLocation'] ?? json['to'],
      goodsType: json['goodsType'] ?? json['goods'],
      vehicleType: json['vehicleType'] ?? json['vehicle'],
      userId: json['userId'] ?? json['user']?['_id'],
      userName: json['userName'] ?? json['user']?['name'],
      isActive: json['isActive'] ?? true,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      // Trip-specific fields
      tripStartLocation: json['tripStartLocation'] != null ? TripLocation.fromJson(json['tripStartLocation']) : null,
      tripDestination: json['tripDestination'] != null ? TripLocation.fromJson(json['tripDestination']) : null,
      viaRoutes: json['viaRoutes'] != null ? (json['viaRoutes'] as List).map((route) => TripLocation.fromJson(route)).toList() : null,
      routeGeoJSON: json['routeGeoJSON'] != null ? RouteGeoJSON.fromJson(json['routeGeoJSON']) : null,
      vehicle: json['vehicle'],
      selfDrive: json['selfDrive'],
      driver: json['driver'],
      distance: json['distance'] != null ? Distance.fromJson(json['distance']) : null,
      duration: json['duration'] != null ? TripDuration.fromJson(json['duration']) : null,
      goodsTypeId: json['goodsType'],
      weight: json['weight']?.toDouble(),
      tripStartDate: json['tripStartDate'] != null ? DateTime.parse(json['tripStartDate']) : null,
      tripEndDate: json['tripEndDate'] != null ? DateTime.parse(json['tripEndDate']) : null,
    );
  }

  // Convert Post to JSON for API requests
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
      if (vehicle != null) 'vehicle': vehicle,
      if (selfDrive != null) 'selfDrive': selfDrive,
      if (driver != null) 'driver': driver,
      if (distance != null) 'distance': distance!.toJson(),
      if (duration != null) 'duration': duration!.toJson(),
      if (goodsTypeId != null) 'goodsType': goodsTypeId,
      if (weight != null) 'weight': weight,
      if (tripStartDate != null) 'tripStartDate': tripStartDate!.toIso8601String(),
      if (tripEndDate != null) 'tripEndDate': tripEndDate!.toIso8601String(),
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
    String? vehicle,
    bool? selfDrive,
    String? driver,
    Distance? distance,
    TripDuration? duration,
    String? goodsTypeId,
    double? weight,
    DateTime? tripStartDate,
    DateTime? tripEndDate,
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
      vehicle: vehicle ?? this.vehicle,
      selfDrive: selfDrive ?? this.selfDrive,
      driver: driver ?? this.driver,
      distance: distance ?? this.distance,
      duration: duration ?? this.duration,
      goodsTypeId: goodsTypeId ?? this.goodsTypeId,
      weight: weight ?? this.weight,
      tripStartDate: tripStartDate ?? this.tripStartDate,
      tripEndDate: tripEndDate ?? this.tripEndDate,
    );
  }
}
