import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:truck_app/core/constants/upload_image_type.dart';
import 'package:truck_app/features/auth/repo/image_upload_repo.dart';

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

    print("image ${(await imageRepository.uploadImage(type: UploadImageType.vehicle, imageFile: event.registrationCertificate))}");

    // final result = await repository.registerVehicle(
    //   vehicleNumber: event.vehicleNumber,
    //   vehicleType: '684aa71cb88048daeaebff8a',
    //   vehicleBodyType: '685ea11cf883dfb6dcf0b900',
    //   vehicleCapacity: event.vehicleCapacity,
    //   goodsAccepted: '684aa71cb88048daeaebff90',
    //   // registrationCertificate: event.registrationCertificate,
    //   // truckImages: event.truckImages,
    //   registrationCertificate: '68abf58c06db05e601466669',
    //   truckImages: ['68ac3247d47a3749fb1ad71d', '68ac3252d47a3749fb1ad71f', '68ac3256d47a3749fb1ad721', '68ac325bd47a3749fb1ad723'],
    //   termsAndConditionsAccepted: event.termsAndConditionsAccepted,
    // );
    //
    // if (result.isSuccess) {
    //   emit(VehicleRegistrationSuccess());
    // } else {
    //   emit(VehicleRegistrationFailure(result.message!));
    // }
    emit(VehicleRegistrationFailure('result.message!'));
  }
}
