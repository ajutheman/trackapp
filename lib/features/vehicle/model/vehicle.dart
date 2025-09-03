import 'package:flutter/material.dart';

class Vehicle {
  final String id;
  final String type;
  final String bodyType;
  final double capacity; // in tons
  final String vehicleNumber;
  final String? rcFileUrl; // URL to RC document
  final String? drivingLicenseFileUrl; // URL to Driving License document
  final List<String> truckImageUrls; // URLs to truck images (4 sides)
  final List<String> goodsAccepted; // List of goods the vehicle can transport

  Vehicle({
    required this.id,
    required this.type,
    required this.bodyType,
    required this.capacity,
    required this.vehicleNumber,
    this.rcFileUrl,
    this.drivingLicenseFileUrl,
    this.truckImageUrls = const [],
    this.goodsAccepted = const [],
  });

  factory Vehicle.fromMap(Map<String, dynamic> map) {
    return Vehicle(
      id: map['_id'] as String,
      type: map['vehicleType']['name'],
      bodyType: map['vehicleBodyType']['name'],
      capacity: (map['vehicleCapacity'] as num).toDouble(),
      vehicleNumber: map['vehicleNumber'] as String,
      rcFileUrl: map['rcFileUrl'] as String?,
      drivingLicenseFileUrl: map['drivingLicenseFileUrl'] as String?,
      truckImageUrls: List<String>.from(map['truckImages']?.map((e) => e['url']) ?? []),
      goodsAccepted: [map['goodsAccepted'].toString()],
    );
  }

  // Method to convert a Vehicle to a map (e.g., for JSON/Firestore)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type.toString().split('.').last, // Store enum name as string
      'bodyType': bodyType.toString().split('.').last, // Store enum name as string
      'capacity': capacity,
      'vehicleNumber': vehicleNumber,
      'rcFileUrl': rcFileUrl,
      'drivingLicenseFileUrl': drivingLicenseFileUrl,
      'truckImageUrls': truckImageUrls,
      'goodsAccepted': goodsAccepted,
    };
  }

  // Method to create a copy of the Vehicle with updated values
  Vehicle copyWith({
    String? id,
    String? type,
    String? bodyType,
    double? capacity,
    String? vehicleNumber,
    String? rcFileUrl,
    String? drivingLicenseFileUrl,
    List<String>? truckImageUrls,
    List<String>? goodsAccepted,
  }) {
    return Vehicle(
      id: id ?? this.id,
      type: type ?? this.type,
      bodyType: bodyType ?? this.bodyType,
      capacity: capacity ?? this.capacity,
      vehicleNumber: vehicleNumber ?? this.vehicleNumber,
      rcFileUrl: rcFileUrl ?? this.rcFileUrl,
      drivingLicenseFileUrl: drivingLicenseFileUrl ?? this.drivingLicenseFileUrl,
      truckImageUrls: truckImageUrls ?? this.truckImageUrls,
      goodsAccepted: goodsAccepted ?? this.goodsAccepted,
    );
  }
}

IconData getVehicleTypeIcon(String type) {
  switch (type) {
    case 'Small Truck':
      return Icons.local_shipping;
    case 'Medium Truck':
      return Icons.fire_truck;
    case 'Large Truck':
      return Icons.airport_shuttle;
    case 'Container Truck':
      return Icons.rv_hookup;
    case 'Trailer':
      return Icons.directions_bus;
    case 'Mini Truck':
      return Icons.delivery_dining;
    case 'Other':
      return Icons.help_outline;
    default:
      return Icons.help_outline; // fallback
  }
}
