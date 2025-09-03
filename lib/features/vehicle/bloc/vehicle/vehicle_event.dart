import 'dart:io';

import 'package:equatable/equatable.dart';

/// Abstract base class for all vehicle-related events.
abstract class VehicleEvent extends Equatable {
  const VehicleEvent();

  @override
  List<Object> get props => [];
}

/// Event to trigger the registration of a new vehicle.
class RegisterVehicle extends VehicleEvent {
  final String vehicleNumber;
  final String vehicleType;
  final String vehicleBodyType;
  final String vehicleCapacity;
  final String goodsAccepted;
  final File drivingLicense;
  final File registrationCertificate;
  final List<File> truckImages;
  final bool termsAndConditionsAccepted;

  /// Constructor for RegisterVehicle event.
  const RegisterVehicle({
    required this.vehicleNumber,
    required this.vehicleType,
    required this.vehicleBodyType,
    required this.vehicleCapacity,
    required this.goodsAccepted,
    required this.drivingLicense,
    required this.registrationCertificate,
    required this.truckImages,
    required this.termsAndConditionsAccepted,
  });

  @override
  List<Object> get props => [
    vehicleNumber,
    vehicleType,
    vehicleBodyType,
    vehicleCapacity,
    goodsAccepted,
    registrationCertificate,
    truckImages,
    termsAndConditionsAccepted,
   ];
}
/// Event to trigger fetching the list of registered vehicles.
class GetVehicles extends VehicleEvent {}