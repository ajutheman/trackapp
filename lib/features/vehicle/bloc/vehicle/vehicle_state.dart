import 'package:equatable/equatable.dart';

/// Abstract base class for all vehicle-related states.
abstract class VehicleState extends Equatable {
  const VehicleState();

  @override
  List<Object> get props => [];
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
  List<Object> get props => [error];
}
