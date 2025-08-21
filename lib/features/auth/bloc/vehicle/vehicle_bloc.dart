import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:truck_app/features/auth/repo/image_upload_repo.dart';

// Assuming app_user_type is not directly needed for vehicle bloc,
// but keep it if there's a dependency for other reasons.
// import 'package:truck_app/core/constants/app_user_type.dart';

import '../../../../services/local/local_services.dart'; // To save token if returned
import '../../repo/vehicle_repo.dart'; // Import the new vehicle repository
import 'vehicle_event.dart'; // Import vehicle events
import 'vehicle_state.dart'; // Import vehicle states

/// BLoC for managing vehicle-related states and events.
class VehicleBloc extends Bloc<VehicleEvent, VehicleState> {
  final VehicleRepository repository;
  final ImageUploadRepository imageRepository;

  /// Constructor for VehicleBloc.
  /// Initializes the BLoC with VehicleInitial state and registers event handlers.
  VehicleBloc({required this.repository, required this.imageRepository}) : super(VehicleInitial()) {
    on<RegisterVehicle>(_onRegisterVehicle);
  }

  /// Event handler for the [RegisterVehicle] event.
  ///
  /// Emits [VehicleRegistrationLoading] state, calls the repository to register
  /// the vehicle, saves the access token if available, and then emits
  /// [VehicleRegistrationSuccess] or [VehicleRegistrationFailure] based on the result.
  void _onRegisterVehicle(RegisterVehicle event, Emitter<VehicleState> emit) async {
    emit(VehicleRegistrationLoading());
    final result = await repository.registerVehicle(
      vehicleNumber: event.vehicleNumber,
      vehicleType: event.vehicleType,
      vehicleBodyType: event.vehicleBodyType,
      vehicleCapacity: event.vehicleCapacity,
      goodsAccepted: event.goodsAccepted,
      // registrationCertificate: event.registrationCertificate,
      // truckImages: event.truckImages,
      registrationCertificate: 'test',
      truckImages: ['test'],
      termsAndConditionsAccepted: event.termsAndConditionsAccepted,
    );

    if (result.isSuccess) {
      emit(VehicleRegistrationSuccess());
    } else {
      emit(VehicleRegistrationFailure(result.message!));
    }
  }
}
