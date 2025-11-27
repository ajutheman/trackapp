import 'package:equatable/equatable.dart';

import '../../model/vehicle.dart';

/// Abstract base class for all vehicle-related states.
abstract class VehicleState extends Equatable {
  const VehicleState();

  @override
  List<Object?> get props => [];
}

/// Initial state of the VehicleBloc.
class VehicleInitial extends VehicleState {}

/// State indicating that vehicle registration is in progress.
class VehicleRegistrationLoading extends VehicleState {}

/// State indicating that vehicle registration was successful.
class VehicleRegistrationSuccess extends VehicleState {}

/// State indicating that vehicle registration failed.
class VehicleRegistrationFailure extends VehicleState {
  final String error;

  /// Constructor for VehicleRegistrationFailure state.
  const VehicleRegistrationFailure(this.error);

  @override
  List<Object?> get props => [error];
}

class VehicleListLoading extends VehicleState {}

/// State indicating that fetching the vehicle list was successful.
class VehicleListSuccess extends VehicleState {
  final List<Vehicle> vehicles;

  /// Constructor for VehicleListSuccess state.
  const VehicleListSuccess(this.vehicles);

  @override
  List<Object?> get props => [vehicles];
}

/// State indicating that fetching the vehicle list failed.
class VehicleListFailure extends VehicleState {
  final String error;

  /// Constructor for VehicleListFailure state.
  const VehicleListFailure(this.error);

  @override
  List<Object?> get props => [error];
}
