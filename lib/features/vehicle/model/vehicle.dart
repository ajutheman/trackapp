import 'package:flutter/material.dart';

// Enum for vehicle types
enum VehicleType { smallTruck, mediumTruck, largeTruck, containerTruck, trailer, miniTruck, other }

// Enum for vehicle body types
enum VehicleBodyType { open, closed, container, flatbed, tipper, other }

// Helper function to get string representation of VehicleType
extension VehicleTypeExtension on VehicleType {
  String get name {
    switch (this) {
      case VehicleType.smallTruck:
        return 'Small Truck';
      case VehicleType.mediumTruck:
        return 'Medium Truck';
      case VehicleType.largeTruck:
        return 'Large Truck';
      case VehicleType.containerTruck:
        return 'Container Truck';
      case VehicleType.trailer:
        return 'Trailer';
      case VehicleType.miniTruck:
        return 'Mini Truck';
      case VehicleType.other:
        return 'Other';
    }
  }

  // Helper to get icon for vehicle type
  IconData get icon {
    switch (this) {
      case VehicleType.smallTruck:
        return Icons.local_shipping;
      case VehicleType.mediumTruck:
        return Icons.fire_truck;
      case VehicleType.largeTruck:
        return Icons.airport_shuttle;
      case VehicleType.containerTruck:
        return Icons.rv_hookup;
      case VehicleType.trailer:
        return Icons.directions_bus;
      case VehicleType.miniTruck:
        return Icons.delivery_dining;
      case VehicleType.other:
        return Icons.help_outline;
    }
  }
}

// Helper function to get string representation of VehicleBodyType
extension VehicleBodyTypeExtension on VehicleBodyType {
  String get name {
    switch (this) {
      case VehicleBodyType.open:
        return 'Open';
      case VehicleBodyType.closed:
        return 'Closed';
      case VehicleBodyType.container:
        return 'Container';
      case VehicleBodyType.flatbed:
        return 'Flatbed';
      case VehicleBodyType.tipper:
        return 'Tipper';
      case VehicleBodyType.other:
        return 'Other';
    }
  }
}

class Vehicle {
  final String id;
  final VehicleType type;
  final VehicleBodyType bodyType;
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

  // Factory constructor to create a Vehicle from a map (e.g., from JSON/Firestore)
  factory Vehicle.fromMap(Map<String, dynamic> map) {
    return Vehicle(
      id: map['id'] as String,
      type: VehicleType.values.firstWhere((e) => e.toString() == 'VehicleType.${map['type']}'),
      bodyType: VehicleBodyType.values.firstWhere((e) => e.toString() == 'VehicleBodyType.${map['bodyType']}'),
      capacity: (map['capacity'] as num).toDouble(),
      vehicleNumber: map['vehicleNumber'] as String,
      rcFileUrl: map['rcFileUrl'] as String?,
      drivingLicenseFileUrl: map['drivingLicenseFileUrl'] as String?,
      truckImageUrls: List<String>.from(map['truckImageUrls'] ?? []),
      goodsAccepted: List<String>.from(map['goodsAccepted'] ?? []),
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
    VehicleType? type,
    VehicleBodyType? bodyType,
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
