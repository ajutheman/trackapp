class TripLocation {
  final String? address;
  final List<double> coordinates; // [longitude, latitude]

  TripLocation({this.address, required this.coordinates});

  factory TripLocation.fromJson(Map<String, dynamic> json) {
    return TripLocation(address: json['address'], coordinates: json['coordinates'] != null ? (json['coordinates'] as List).map((e) => (e as num).toDouble()).toList() : []);
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
    return RouteGeoJSON(
      type: json['type'] ?? 'LineString',
      coordinates: (json['coordinates'] as List?)?.map((coord) => (coord as List).map((e) => (e as num).toDouble()).toList()).toList() ?? [],
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

  User({required this.id, required this.name, required this.phone, required this.email});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(id: json['_id'] ?? '', name: json['name'] ?? '', phone: json['phone'] ?? '', email: json['email'] ?? '');
  }

  Map<String, dynamic> toJson() {
    return {'_id': id, 'name': name, 'phone': phone, 'email': email};
  }
}

class Vehicle {
  final String id;
  final String vehicleNumber;
  final String vehicleType;
  final String vehicleBodyType;

  Vehicle({required this.id, required this.vehicleNumber, required this.vehicleType, required this.vehicleBodyType});

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(id: json['_id'] ?? '', vehicleNumber: json['vehicleNumber'] ?? '', vehicleType: json['vehicleType'] ?? '', vehicleBodyType: json['vehicleBodyType'] ?? '');
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
    return GoodsType(id: json['_id'] ?? '', name: json['name'] ?? '', description: json['description'] ?? '');
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
    return TripStatus(id: json['_id'] ?? '', name: json['name'] ?? '', description: json['description'] ?? '');
  }

  Map<String, dynamic> toJson() {
    return {'_id': id, 'name': name, 'description': description};
  }
}

class Post {
  final String? id;
  final String title;
  final String description;
  final DateTime date;
  final String? imageUrl;
  final String? postType;
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
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    try {
      return Post(
        id: json['_id'] ?? json['id'],
        title: json['title'] ?? '',
        description: json['description'] ?? '',
        date: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
        imageUrl: json['imageUrl'] ?? json['image'],
        postType: json['postType'] ?? json['type'],
        pickupLocation: json['pickupLocation'] ?? json['from'] ?? json['tripStartLocation']?['address'],
        dropLocation: json['dropLocation'] ?? json['to'] ?? json['tripDestination']?['address'],
        goodsType: json['goodsType'] is String ? json['goodsType'] : (json['goodsType'] is Map ? json['goodsType']['name'] : json['goods']),
        vehicleType: json['vehicleType'] is String ? json['vehicleType'] : (json['vehicle'] is Map ? json['vehicle']['vehicleNumber'] : null),
        userId: json['userId'] ?? json['user']?['_id'] ?? json['tripAddedBy']?['_id'],
        userName: json['userName'] ?? json['user']?['name'] ?? json['tripAddedBy']?['name'],
        isActive: json['isActive'] ?? true,
        createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
        updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
        tripStartLocation: json['tripStartLocation'] != null ? TripLocation.fromJson(json['tripStartLocation']) : null,
        tripDestination: json['tripDestination'] != null ? TripLocation.fromJson(json['tripDestination']) : null,
        viaRoutes: json['viaRoutes'] != null ? (json['viaRoutes'] as List).map((route) => TripLocation.fromJson(route)).toList() : null,
        routeGeoJSON: json['routeGeoJSON'] != null ? RouteGeoJSON.fromJson(json['routeGeoJSON']) : null,
        vehicleDetails: json['vehicle'] != null && json['vehicle'] is Map ? Vehicle.fromJson(json['vehicle']) : null,
        selfDrive: json['selfDrive'],
        driver: json['driver'] != null ? User.fromJson(json['driver']) : null,
        distance: json['distance'] != null ? Distance.fromJson(json['distance']) : null,
        duration: json['duration'] != null ? TripDuration.fromJson(json['duration']) : null,
        goodsTypeDetails: json['goodsType'] != null && json['goodsType'] is Map ? GoodsType.fromJson(json['goodsType']) : null,
        weight: json['weight'] != null ? (json['weight'] as num).toDouble() : null,
        tripStartDate: json['tripStartDate'] != null ? DateTime.parse(json['tripStartDate']) : null,
        tripEndDate: json['tripEndDate'] != null ? DateTime.parse(json['tripEndDate']) : null,
        currentLocation: json['currentLocation'] != null ? TripLocation.fromJson(json['currentLocation']) : null,
        tripAddedBy: json['tripAddedBy'] != null ? User.fromJson(json['tripAddedBy']) : null,
        status: json['status'] != null && json['status'] is Map ? TripStatus.fromJson(json['status']) : null,
        isStarted: json['isStarted'],
      );
    } catch (e) {
      print('Error parsing Post from JSON: $e');
      print('JSON data: $json');
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
    );
  }
}
